from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from google.cloud import firestore
import firebase_admin
import random
from firebase_admin import initialize_app

if not firebase_admin._apps:
    initialize_app()

app = FastAPI()
db = firestore.Client(database="oligarch-firestore-db")


class ConnectionManager:
    def __init__(self):
        self.active_games: dict[str, list[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, gameId: str):
        await websocket.accept()
        if gameId not in self.active_games:
            self.active_games[gameId] = []
        self.active_games[gameId].append(websocket)

    def disconnect(self, websocket: WebSocket, gameId: str):
        self.active_games[gameId].remove(websocket)
        if not self.active_games[gameId]:
            del self.active_games[gameId]

    async def broadcast_to_game(self, message: dict, gameId: str):
        if gameId in self.active_games:
            for connection in self.active_games[gameId]:
                await connection.send_json(message)

    async def broadcast_specific_user(self, message: dict, gameId: str, playerId: str):
        if gameId in self.active_games and playerId in self.active_games[gameId]:
            connection = self.active_games[gameId][playerId]
            await connection.send_json(message)


manager = ConnectionManager()


@app.websocket("/ws/{gameId}/{username}")
async def websocket_endpoint(websocket: WebSocket, gameId: str):
    await manager.connect(websocket, gameId)
    docPlayer = db.collection(gameId).document("players")
    docGameDetails = db.collection(gameId).document("gameDetails")

    try:
        while True:
            data = await websocket.receive_json()
            action = data.get("action")

            match action:
                case "startGame":
                    playersIds = list(docPlayer.get().to_dict().keys())
                    random.shuffle(playersIds)

                    for index in range(len(playersIds)):
                        docPlayer.update(
                            {f"{index+1}.playerTurn": int(playersIds[index])}
                        )

                        docGameDetails.set({"playerOrder": playersIds})

                    await manager.broadcast_to_game(
                        {"event": "gameStarted", "data": playersIds, "statusCode": 201},
                        gameId,
                    )

                case "rolledDice":
                    playerId = action.get("playerId")
                    oldPosition = action.get("oldPosition")
                    newPosition = action.get("newPosition")
                    
                    playerTurn = docPlayer.get(playerId).to_dict().get("playerTurn")
                    playerOrder = docGameDetails.get("playerOrder")

                    docPlayer.update({f"{playerId}.position": newPosition})

                    await manager.broadcast_to_game(
                        {
                            "event": "diceRollCompleted",
                            "data": [playerId, newPosition, oldPosition],
                            "statusCode": 202,
                        },
                        gameId,
                    )

                    await manager.broadcast_specific_user(
                        {"event": "startDiceRoll", "statusCode": 203},
                        gameId,
                        playerOrder[playerTurn],
                    )

    except WebSocketDisconnect:
        manager.disconnect(websocket, gameId)

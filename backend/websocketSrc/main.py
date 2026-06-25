from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from google.cloud import firestore
import firebase_admin
import json
import random
from firebase_admin import initialize_app

if not firebase_admin._apps:
    initialize_app()

app = FastAPI()
db = firestore.Client(database="oligarch-firestore-db")


class ConnectionManager:
    def __init__(self):
        self.active_games: dict[str, dict[str, WebSocket]] = {}

    async def connect(self, websocket: WebSocket, gameId: str, playerId: str):
        await websocket.accept()
        if gameId not in self.active_games:
            self.active_games[gameId] = {}

        self.active_games[gameId][playerId] = websocket

    def disconnect(self, gameId: str, playerId: str):
        if gameId in self.active_games and playerId in self.active_games[gameId]:
            del self.active_games[gameId][playerId]

            if not self.active_games[gameId]:
                del self.active_games[gameId]

    async def broadcast_to_game(self, message: dict, gameId: str):
        if gameId in self.active_games:
            for connection in self.active_games[gameId].values():
                await connection.send_json(message)

    async def broadcast_specific_user(self, message: dict, gameId: str, playerId: str):
        if gameId in self.active_games and playerId in self.active_games[gameId]:
            connection = self.active_games[gameId][playerId]
            await connection.send_json(message)


manager = ConnectionManager()


@app.websocket("/ws/{gameId}/{playerId}")
async def websocket_endpoint(websocket: WebSocket, gameId: str, playerId: str):
    await manager.connect(websocket, gameId, playerId)

    docPlayer = db.collection(gameId).document("players")
    docGameDetails = db.collection(gameId).document("gameDetails")
    docProperty = db.collection(gameId).document("properties")

    try:
        while True:
            data = await websocket.receive_json()
            action = data.get("action")
            print(data)

            match action:
                case "startGame":
                    playersIds = list(docPlayer.get().to_dict().keys())
                    #random.shuffle(playersIds)
                    print(playersIds)

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
                    oldPosition = (data.get("oldPosition"))
                    newPosition = data.get("newPosition")

                    # playerTurn = docPlayer.get().to_dict().get(str(playerId), {}).get("playerTurn")
                    # playerOrder = docGameDetails.get().to_dict().get("playerOrder", [])

                    docPlayer.update({f"{playerId}.position": newPosition})

                    await manager.broadcast_to_game(
                        {
                            "event": "diceRollCompleted",
                            "data": [playerId, newPosition, oldPosition],
                            "statusCode": 202,
                        },
                        gameId,
                    )

                case "buyProperty":
                    propertyId = str(data.get("propertyId"))
                    propertyData = data.get("propertyData")

                    #Properties Datebase Updates

                    docProperty.set(json.dumps({propertyId: propertyData}), merge=True)
                    

                    #Player Datebase Updates
                    currentPlayerDict = docPlayer.get().to_dict().get(str(playerId), {})

                    playerPropertiesOwnership = currentPlayerDict.get("propertiesOwnershipShares")
                    playerPropertiesOwnership[propertyId] = 100

                    playerCash = currentPlayerDict.get("cash")
                    playerCash = playerCash-propertyData["price"]

                    playerPropertiesVoter = currentPlayerDict.get("propertiesVoterShares")
                    playerPropertiesVoter[propertyId] = 100

                    docPlayer.update({f"{playerId}.propertiesOwnershipShares": playerPropertiesOwnership})
                    docPlayer.update({f"{playerId}.propertiesVoterShares": playerPropertiesVoter})
                    docPlayer.update({f"{playerId}.cash": playerCash})


                    await manager.broadcast_to_game(
                        {
                            "event": "PropertyBought",
                            "data": [playerId, propertyId],
                            "statusCode": 203,
                        },
                        gameId,
                    )

    except WebSocketDisconnect:
        manager.disconnect(websocket, gameId)

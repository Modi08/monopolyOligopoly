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

manager = ConnectionManager()

@app.websocket("/ws/{gameId}/{username}")
async def websocket_endpoint(websocket: WebSocket, gameId: str, username: str):
    await manager.connect(websocket, gameId)
    doc = db.collection(gameId).document("players")

    try:
        while True:
            data = await websocket.receive_json()
            action = data.get("action")
            
            match action:
                case "startGame":
                    playersIds = list(doc.get().to_dict().keys())
                    random.shuffle(playersIds)

                    for index in range(len(playersIds)):
                        print(index)
                        print(playersIds, playersIds[index])
                        doc.update({
                            f"{index+1}.playerTurn": int(playersIds[index])
                        })

                    await manager.broadcast_to_game({"event": "gameStarted", "data": playersIds}, gameId)
            
    except WebSocketDisconnect:
        manager.disconnect(websocket, gameId)
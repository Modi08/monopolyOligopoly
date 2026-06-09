from google.cloud import firestore
from firebase_functions import https_fn
import firebase_admin
from firebase_admin import initialize_app

# 1. BULLETPROOF INITIALIZATION
# This prevents a fatal crash if Cloud Run reloads the container and tries to initialize twice.
if not firebase_admin._apps:
    initialize_app()

# 2. LAZY LOADING
# We declare the variable globally, but we do NOT connect to Firestore yet.
_db = None


def get_db():
    global _db
    # The network connection is only made the very first time this is called.
    # Subsequent calls will reuse the existing, fast connection.
    if _db is None:
        _db = firestore.Client(database="oligarch-firestore-db")
    return _db


@https_fn.on_call(enforce_app_check=True)
def join_game(req: https_fn.CallableRequest) -> dict:
    # Safely get the database connection
    db = get_db()

    request = req.data
    gameId = request.get("gameId", "").strip()
    username = request.get("username").strip()

    docRef = db.collection(gameId).document("players")
    doc = docRef.get()

    if doc.exists:
        gameData = doc.to_dict()
        allUsersUnprocessed = list(gameData.items())
        allUsers = []
        highestUserId = 0

        for userId, userData in allUsersUnprocessed:
            if int(userId) > highestUserId:
                highestUserId = int(userId)

            if userData.get("username") == username:
                return {
                    "statusCode": 400,
                    "message": "Username already taken in this game.",
                }

            userData["id"] = int(userId)
            userData["isCurrentPlayer"] = False
            allUsers.append(userData)

        docRef.update(
            {
                str(highestUserId + 1): {
                    "cash": 5000,
                    "netWorth": 5000,
                    "propertiesOwnershipShares": {},
                    "propertiesVotershare": {},
                    "position": 0,
                    "inJail": False,
                    "jailTurns": 0,
                    "activeLoans": {},
                    "playerTurn": 0,
                    "username": username,
                }
            }
        )
        return {
            "statusCode": 200,
            "message": "Successfully joined the game.",
            "players": allUsers,
            "newPlayerId": highestUserId + 1,
        }
    else:
        return {"statusCode": 404, "message": "Game ID does not exist."}


@https_fn.on_call(enforce_app_check=True)
def create_game(req: https_fn.CallableRequest) -> dict:
    # Safely get the database connection
    db = get_db()

    request_json = req.data
    username = request_json.get("username")

    docs = db.collections()
    gameIds = [int(doc.id) for doc in docs]
    gameIds.sort()

    newGameId = gameIds[-1] + 1 if len(gameIds) > 0 else 1
    docRef = db.collection(str(newGameId)).document("players")

    docRef.set(
        {
            "1": {
                "cash": 5000,
                "netWorth": 5000,
                "propertiesOwnershipShares": {},
                "propertiesVotershare": {},
                "position": 0,
                "inJail": False,
                "jailTurns": 0,
                "activeLoans": {},
                "playerTurn": 0,
                "username": username,
            }
        }
    )
    return {
        "statusCode": 200,
        "message": "Successfully created the game.",
        "gameId": newGameId,
    }

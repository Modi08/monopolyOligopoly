terraform {
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "~> 6.0"
        }
    }
}

provider "google" {
  project = "oligarch-498212"
  region  = "europe-west4"
}

# 1. Create a bucket to store the function's source code
# Note: Bucket names must be globally unique across all of Google Cloud!
resource "google_storage_bucket" "function_bucket" {
  name                        = "oligarch-function-joingame-20262008" 
  location                    = "europe-west4"
  uniform_bucket_level_access = true
}

## ==========================================
# Setting up firestore database
# ==========================================
# 1. Enable the Firestore API for the project (required before creating a database)
resource "google_project_service" "firestore_api" {
  project            = "oligarch-498212"
  service            = "firestore.googleapis.com"
  disable_on_destroy = false
}

# 2. Commission the Native Mode Database
resource "google_firestore_database" "native_db" {
  project = "oligarch-498212"
  name = "oligarch-firestore-db" 
  location_id = "europe-west4"

  type = "FIRESTORE_NATIVE" 
  delete_protection_state = "DELETE_PROTECTION_DISABLED" 
  depends_on = [google_project_service.firestore_api]
}

# ==========================================
# 1. Package and Upload the Shared Source Code
# ==========================================

data "archive_file" "backend_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src" # Points to the new shared folder
  output_path = "${path.module}/files/backend.zip"
}

resource "google_storage_bucket_object" "backend_code" {
  name   = "backend-${data.archive_file.backend_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.backend_zip.output_path
}

# ==========================================
# 2. Deploy Join Game Function
# ==========================================

resource "google_cloudfunctions2_function" "joinGameFunction" {
  name        = "joinGameFunction"
  location    = "europe-west4"
  description = "Cloud Function to handle player joining a game"

  build_config {
    runtime     = "python311" 
    entry_point = "join_game" # <--- Matches the Python function name
    
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.backend_code.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "join_public_invoker" {
  project  = google_cloudfunctions2_function.joinGameFunction.project
  location = google_cloudfunctions2_function.joinGameFunction.location
  service  = "joingamefunction"
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# ==========================================
# 3. Deploy Create Game Function
# ==========================================

resource "google_cloudfunctions2_function" "createGameFunction" {
  name        = "createGameFunction"
  location    = "europe-west4"
  description = "Cloud Function to handle game creation"

  build_config {
    runtime     = "python311"
    entry_point = "create_game" # <--- Matches the Python function name
    
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.backend_code.name # Points to the SAME zip file
      }
    }
  }

  service_config {
    max_instance_count = 3
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "create_public_invoker" {
  project  = google_cloudfunctions2_function.createGameFunction.project
  location = google_cloudfunctions2_function.createGameFunction.location
  service  = "creategamefunction"
  role     = "roles/run.invoker"
  member   = "allUsers"
}


# ==========================================
# 3. Deploying Websocket functionality
# ==========================================

resource "google_cloud_run_v2_service" "game_websocket_server" {
  name     = "oligarch-websocket-server"
  location = "europe-west4"
  ingress  = "INGRESS_TRAFFIC_ALL"
  deletion_protection=false 

  template {
    containers {
      image = "europe-west4-docker.pkg.dev/oligarch-498212/oligarch-repo/websocket-image:latest"
      
      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
      
      ports {
        container_port = 8080
      }
    }

    # CRITICAL: WebSockets require multiple connections to hit the same instance.
    max_instance_request_concurrency = 80 
  }
}

resource "google_cloud_run_service_iam_member" "websocket_public" {
  project  = google_cloud_run_v2_service.game_websocket_server.project
  location = google_cloud_run_v2_service.game_websocket_server.location
  service  = google_cloud_run_v2_service.game_websocket_server.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_artifact_registry_repository" "my_repo" {
  location      = "europe-west4"
  repository_id = "oligarch-repo"
  description   = "Docker repository for Oligarch WebSocket server"
  format        = "DOCKER"
}
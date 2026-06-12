# deploy.ps1
# Run this from inside your 'backend' folder

$IMAGE_PATH = "europe-west4-docker.pkg.dev/oligarch-498212/oligarch-repo/websocket-image:latest"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Building and Deploying Oligarch Backend" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Build the Docker Image
Write-Host "`n[1/3] Building Docker Image..." -ForegroundColor Yellow
Set-Location -Path ".\websocketSrc"
docker build -t $IMAGE_PATH .

if ($LASTEXITCODE -ne 0) { 
    Write-Host "Error: Docker build failed! Stopping deployment." -ForegroundColor Red
    Set-Location -Path ".."
    exit 
}

# 2. Push the Docker Image
Write-Host "`n[2/3] Pushing Image to Artifact Registry..." -ForegroundColor Yellow
docker push $IMAGE_PATH

if ($LASTEXITCODE -ne 0) { 
    Write-Host "Error: Docker push failed! Stopping deployment." -ForegroundColor Red
    Set-Location -Path ".."
    exit 
}

# 3. Apply Terraform
Write-Host "`n[3/3] Running Terraform Apply..." -ForegroundColor Yellow
Set-Location -Path ".."

# Note: -auto-approve skips the "yes" confirmation prompt for a true 1-click deploy
terraform apply -auto-approve

if ($LASTEXITCODE -ne 0) { 
    Write-Host "Error: Terraform apply failed!" -ForegroundColor Red
    exit 
}

Write-Host "`n=========================================" -ForegroundColor Green
Write-Host " Deployment Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
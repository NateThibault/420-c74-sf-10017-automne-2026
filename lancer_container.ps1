# lancer-jupyter.ps1
# Lance JupyterLab dans le container Docker du cours

$ImageName = "cours1"
$ContainerName = "cours1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Lancement de JupyterLab - 420-C74-SF" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que Docker fonctionne
Write-Host "Verification de Docker..." -ForegroundColor Yellow

docker info *> $null

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR : Docker Desktop n'est pas lance." -ForegroundColor Red
    Write-Host "Lance Docker Desktop puis reessaie." -ForegroundColor Red
    Read-Host "Appuie sur Enter pour quitter"
    exit 1
}

# Vérifier que l'image existe
$imageExists = docker image inspect $ImageName 2>$null

if (-not $imageExists) {
    Write-Host "L'image '$ImageName' n'existe pas." -ForegroundColor Yellow
    Write-Host "Construction de l'image..." -ForegroundColor Yellow
    Write-Host ""

    docker build -t $ImageName .\docker

    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "ERREUR lors de la construction de l'image." -ForegroundColor Red
        Read-Host "Appuie sur Enter pour quitter"
        exit 1
    }
}

# Vérifier si un ancien container existe encore
$containerExists = docker ps -a --filter "name=^$ContainerName$" --format "{{.Names}}"

if ($containerExists) {
    Write-Host "Un ancien container '$ContainerName' existe." -ForegroundColor Yellow
    Write-Host "Suppression de l'ancien container..." -ForegroundColor Yellow
    docker rm -f $ContainerName 2>$null
}

Write-Host ""
Write-Host "Demarrage de JupyterLab..." -ForegroundColor Green
Write-Host ""
Write-Host "Adresse : http://localhost:8888" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour arreter JupyterLab : Ctrl + C" -ForegroundColor DarkGray
Write-Host ""

# Lancer le container
docker run --rm -it `
    -p 8888:8888 `
    -v "${PWD}:/notebooks" `
    --name $ContainerName `
    $ImageName
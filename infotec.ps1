# ==========================================
# SCRIPT UNIVERSAL DE APPS MICROSOFT STORE
# INFOTEC - POS FORMATACAO
# ==========================================
Clear-Host
Write-Host ""
Write-Host "Preparando sistema..." -ForegroundColor Cyan
Write-Host ""
$ErrorActionPreference = "SilentlyContinue"
#########################################################
# VERIFICAR / INSTALAR WINGET
#########################################################

$winget = Get-Command winget -ErrorAction SilentlyContinue

if (!$winget) {

Write-Host "Winget nao encontrado. Instalando App Installer..." -ForegroundColor Yellow

$url = "https://aka.ms/getwinget"
$file = "$env:TEMP\winget.msixbundle"

Invoke-WebRequest $url -OutFile $file
Add-AppxPackage -Path $file

Start-Sleep 15

}

#########################################################
# REPARAR MICROSOFT STORE
#########################################################

Write-Host "Reparando Microsoft Store..." -ForegroundColor Cyan

Get-AppxPackage -AllUsers Microsoft.WindowsStore | Foreach {
Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
}

Start-Sleep 5

#########################################################
# LIMPAR CACHE DA STORE
#########################################################

Write-Host "Limpando cache da Store..." -ForegroundColor Cyan
wsreset -i

Start-Sleep 10

#########################################################
# ABRIR ATUALIZACOES DA STORE
#########################################################

Write-Host "Sincronizando Microsoft Store..." -ForegroundColor Cyan

Start-Process "ms-windows-store://downloadsandupdates"

Start-Sleep 30
wsreset -i
Start-Sleep 15

#########################################################
# CORRIGIR REPOSITORIOS WINGET
#########################################################

Write-Host "Inicializando Winget..." -ForegroundColor Cyan

winget --version | Out-Null

Start-Sleep 3

Write-Host "Atualizando fontes do Winget..." -ForegroundColor Cyan

winget source update

winget upgrade --all `
--accept-package-agreements `
--accept-source-agreements `
--silent `
--disable-interactivity

Start-Sleep 3

#########################################################
# FUNCAO INSTALACAO SEGURA
#########################################################

function Instalar-App {

param (
[string]$Nome,
[string]$ID
)

$check = winget list --id $ID -e | Out-String

if ($check) {
    Write-Host "$Nome já instalado." -ForegroundColor Yellow
}
else {
    Write-Host "Instalando $Nome..." -ForegroundColor Green

    winget install `
    --id $ID `
    -e `
    --source msstore `
    --silent `
    --accept-package-agreements `
    --accept-source-agreements `
    --disable-interactivity
}

}

#########################################################
# INSTALACAO DOS APLICATIVOS
#########################################################

Write-Host ""
Write-Host "############################################"
Write-Host "# INSTALACAO DOS APLICATIVOS"
Write-Host "############################################"
Write-Host ""

Instalar-App "Esboço e Captura" "9MZ95KL8MR0L"

Instalar-App "Windows Camera" "9WZDNCRFJBBG"

Instalar-App "Microsoft Photos" "9WZDNCRFJBH4"

#########################################################
# INSTALAR WHATSAPP
#########################################################

#########################################################
# INSTALAR / ATUALIZAR WHATSAPP
#########################################################

Write-Host "Verificando WhatsApp..." -ForegroundColor Cyan

# Verifica versão Store (confiável)
$wppStore = Get-AppxPackage *WhatsApp*

# Verifica versão Winget
$wppWinget = winget list --id WhatsApp.WhatsApp -e | Out-String

if ($wppStore -or $wppWinget -match "WhatsApp") {

    Write-Host "WhatsApp já instalado. Verificando atualização..." -ForegroundColor Yellow

    winget upgrade --id WhatsApp.WhatsApp `
    --source winget `
    -e `
    --silent `
    --accept-package-agreements `
    --accept-source-agreements `
    --disable-interactivity

    Write-Host "WhatsApp verificado/atualizado." -ForegroundColor Green

} else {

    Write-Host "WhatsApp não instalado. Instalando via Winget..." -ForegroundColor Green

    winget install --id WhatsApp.WhatsApp `
    --source winget `
    -e `
    --silent `
    --accept-package-agreements `
    --accept-source-agreements `
    --disable-interactivity

    if ($LASTEXITCODE -eq 0) {

        Write-Host "WhatsApp instalado via Winget." -ForegroundColor Green

    } else {

        Write-Host "Falha no Winget. Tentando Microsoft Store..." -ForegroundColor Yellow

        winget install 9NKSQGP7F2NH `
        --source msstore `
        --accept-package-agreements `
        --accept-source-agreements `
        --disable-interactivity

        if ($LASTEXITCODE -eq 0) {

            Write-Host "WhatsApp instalado via Microsoft Store." -ForegroundColor Green

        } else {

            Write-Host "Falha automática. Abrindo Store manual..." -ForegroundColor Red

            Start-Process "ms-windows-store://pdp/?ProductId=9NKSQGP7F2NH"

        }
    }
}
#########################################################

Write-Host ""
Write-Host "Sistema preparado e aplicativos instalados!" -ForegroundColor Green
Write-Host ""

pause

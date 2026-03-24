# ==========================================
# SCRIPT UNIVERSAL DE APPS MICROSOFT STORE
# INFOTEC - POS FORMATACAO
# ==========================================

Write-Host ""
Write-Host "Preparando sistema..." -ForegroundColor Cyan
Write-Host ""

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

Start-Sleep 40

#########################################################
# CORRIGIR REPOSITORIOS WINGET
#########################################################

Write-Host "Inicializando Winget..." -ForegroundColor Cyan

winget --version | Out-Null

Start-Sleep 3

Write-Host "Atualizando fontes do Winget..." -ForegroundColor Cyan

winget source update

Start-Sleep 3

#########################################################
# FUNCAO INSTALACAO SEGURA
#########################################################

function Instalar-App {

param (
[string]$Nome,
[string]$ID
)

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

Write-Host "Instalando WhatsApp..." -ForegroundColor Green

$process = Start-Process winget -ArgumentList @(
"install",
"--id","WhatsApp.WhatsApp",
"-e",
"--silent",
"--accept-package-agreements",
"--accept-source-agreements",
"--disable-interactivity"
) -PassThru

$timeout = 300
$elapsed = 0

while (!$process.HasExited -and $elapsed -lt $timeout) {
    Start-Sleep 2
    $elapsed += 2
}

if (!$process.HasExited) {
    Write-Host "Tempo limite atingido. Continuando script..." -ForegroundColor Yellow
    $process.Kill()
}
else {
    Write-Host "WhatsApp instalado." -ForegroundColor Green
}

#########################################################

Write-Host ""
Write-Host "Sistema preparado e aplicativos instalados!" -ForegroundColor Green
Write-Host ""

pause

# Definir las rutas usando la misma lógica de tu script de bloqueo
$spRoaming = Join-Path $env:APPDATA 'Spotify';
$spotifyexe = "$spRoaming\Spotify.exe";
$exe_bak = "$spRoaming\Spotify.bak";

# Cerrar Spotify por si acaso (usando una simplificación de tu función Kill-Spotify)
Get-Process -Name "Spotify" -ErrorAction SilentlyContinue | Stop-Process -Force;
Get-Process -Name "SpotifyWebHelper" -ErrorAction SilentlyContinue | Stop-Process -Force;

# Lógica de restauración
if (Test-Path $exe_bak) {
    Write-Host "Iniciando restauracion desde Spotify.bak..." -ForegroundColor Cyan;
    
    # 1. Eliminar el archivo .exe modificado
    Remove-Item $spotifyexe -Force -ErrorAction SilentlyContinue;
    
    # 2. Renombrar el .bak a .exe para restaurar el original
    Rename-Item -Path $exe_bak -NewName 'Spotify.exe' -Force;
    
    Write-Host " Restauracion completado. Las actualizaciones de Spotify estan desbloqueadas." -ForegroundColor Green
} else {
    Write-Host " ERROR: No se encontro el archivo de respaldo Spotify.bak en la ruta: $spRoaming. El desbloqueo manual es necesario." -ForegroundColor Red
}



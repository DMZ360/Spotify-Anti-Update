# Definiciones de variables y funciones necesarias para que el código funcione
# Se simplifican las funciones que faltaban en el código original (como Write-Text, Kill-Spotify)

$spRoaming = Join-Path $env:APPDATA 'Spotify'
$spotifyexe = "$spRoaming\Spotify.exe"
$exe_bak = Join-Path $spRoaming 'Spotify.bak'

function Kill-Spotify {
    Get-Process -Name "Spotify" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name "SpotifyWebHelper" -ErrorAction SilentlyContinue | Stop-Process -Force
}

function Write-Text {
    param([string]$txt)
    Write-Host $txt
}

# La función BlockUpdate con la lógica central de tu código
function BlockUpdate {

    Kill-Spotify
    
    if (-not (Test-Path $spotifyexe)) {
        Write-Host "Error: No se encontró Spotify.exe en la ruta: $spotifyexe" -ForegroundColor Red
        return
    }

    # Se usa la codificación 1251 para la manipulación binaria/de texto, según el script original.
    $ANSI = [Text.Encoding]::GetEncoding(1251) 
    $old = [IO.File]::ReadAllText($spotifyexe, $ANSI)
    
    # Patrones de búsqueda
    $natPtrn = "(?<=desktop-update\/.)7(\/update)" # Patrón que indica que ya está bloqueado
    $modPtrn = "(?<=desktop-update\/.)2(\/update)" # Patrón original (se asume 2)

    if ($old -match $natPtrn) {
        Write-Text -txt "Spotify: Las actualizaciones ya están bloqueadas." 
        # NOTA: Se omite la parte interactiva para desbloquear updates para que se ejecute automáticamente.
        return
    }
    elseif ($old -match $modPtrn) {
        # 1. Crear copia de seguridad
        Copy-Item $spotifyexe $exe_bak -Force
        
        # 2. Aplicar el bloqueo: reemplazar la ruta de actualización '2/update' con '7/update'
        $new = $old -replace $modPtrn, '7/update'
        
        # 3. Escribir el archivo modificado
        [IO.File]::WriteAllText($spotifyexe, $new, $ANSI)
        Write-Text -txt "Spotify: ¡Actualizaciones bloqueadas con éxito! Se creó Spotify.bak como respaldo." -ForegroundColor Green
    }
    else {
        # Si no coincide con ninguno de los patrones, se asume que la versión es diferente o el patrón ha cambiado.
        Write-Text -txt "Spotify: Falló al bloquear las actualizaciones. El patrón del archivo no coincide con las versiones conocidas. Es posible que tenga una versión muy nueva." -ForegroundColor Yellow
    }
}

# --- Ejecución del Proceso ---

Write-Host ""
Write-Host "--- Ejecutando el Bloqueador de Actualizaciones ---" -ForegroundColor Cyan
BlockUpdate
Write-Host "Proceso finalizado."
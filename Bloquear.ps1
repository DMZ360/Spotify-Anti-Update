# --- Definiciones de rutas ---
$spRoaming = Join-Path $env:APPDATA 'Spotify'
$spotifyexe = "$spRoaming\Spotify.exe"
$exe_bak = Join-Path $spRoaming 'Spotify.bak'

# --- Funciones ---
function Kill-Spotify {
    Get-Process -Name "Spotify" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name "SpotifyWebHelper" -ErrorAction SilentlyContinue | Stop-Process -Force
}

function Write-Text {
    param([string]$txt)
    Write-Host $txt
}

# --- Función principal ---
function BlockUpdate {
    Kill-Spotify
    
    if (-not (Test-Path $spotifyexe)) {
        Write-Host "Error: No se encontró Spotify.exe en la ruta: $spotifyexe" -ForegroundColor Red
        return
    }

    $ANSI = [Text.Encoding]::GetEncoding(1251)
    $old = [IO.File]::ReadAllText($spotifyexe, $ANSI)

    $natPtrn = "(?<=desktop-update\/.)7(\/update)" # bloqueado
    $modPtrn = "(?<=desktop-update\/.)2(\/update)" # original

    if ($old -match $natPtrn) {
        Write-Text -txt "Spotify: Las actualizaciones ya estan bloqueadas."
        return
    }
    elseif ($old -match $modPtrn) {
        # 1. Crear copia de seguridad solo si no existe
        if (-not (Test-Path $exe_bak)) {
            Copy-Item $spotifyexe $exe_bak
            Write-Text -txt "Se creó la copia de seguridad: Spotify.bak" -ForegroundColor Green
        } else {
            Write-Text -txt "Spotify.bak ya existe. No se sobrescribirá." -ForegroundColor Yellow
        }
        
        # 2. Aplicar el bloqueo
        $new = $old -replace $modPtrn, '7/update'
        [IO.File]::WriteAllText($spotifyexe, $new, $ANSI)
        Write-Text -txt "Spotify: ¡Actualizaciones bloqueadas con éxito!" -ForegroundColor Green
    }
    else {
        Write-Text -txt "Spotify: Fallo al bloquear las actualizaciones. El patrón del archivo no coincide con versiones conocidas." -ForegroundColor Yellow
    }
}

# --- Ejecución ---
Write-Host ""
Write-Host "--- Ejecutando el Bloqueador de Actualizaciones ---" -ForegroundColor Cyan
BlockUpdate
Write-Host "Proceso finalizado."

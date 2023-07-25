# Author: https://github.com/elgordodevops
# Script pensado para correrlo después de las 00:01, ya que busca el log del día anterior y nombra el archivo comprimido con el día anterior a la ejecución

# Obtener fecha anterior a la ejecución del proceso
$fechaAnterior = (Get-Date).AddDays(-1)

# Obtener los posibles formatos de sufijos de fecha
$sufijosFechaArchivo = @($fechaAnterior.ToString("yyyy-MM-dd"), $fechaAnterior.ToString("yyyyMMdd"))

# Obtener la lista de directorios
$listaDirectorios = @("C:\RotacionLOGS\Directorio1", "C:\RotacionLOGS\Directorio2", "C:\RotacionLOGS\Directorio3")

# Recorrer la lista de directorios
foreach ($directorio in $listaDirectorios) {
    # Ruta de la subcarpeta de backup
    $rutaBackup = Join-Path -Path $directorio -ChildPath "OldLogsZip"

    # Verificar si existe la subcarpeta de backup y la crea si no existe
    if (-not (Test-Path $rutaBackup)) {
        New-Item -ItemType Directory -Path $rutaBackup | Out-Null
    }

    # Caso 1: Busca archivos con multiple nombre y formato
    $prefijosNombresArchivo = @("ServiceLayer-", "ServiceLayer")
    $extensionesArchivo = @(".log", ".txt")

    foreach ($prefijo in $prefijosNombresArchivo) {
        foreach ($sufijo in $sufijosFechaArchivo) {
            foreach ($extension in $extensionesArchivo) {
                $archivo = Join-Path -Path $directorio -ChildPath ("$prefijo$sufijo$extension")
                if (Test-Path $archivo) {
                    $nombreArchivoZip = Join-Path -Path $rutaBackup -ChildPath ("$prefijo$sufijo.zip")
                    Compress-Archive -Path $archivo -DestinationPath $nombreArchivoZip -Force
                    Remove-Item -Path $archivo -Force
                    break
                }
            }
        }
    }

    # Caso 2: Busca archivos con nombres predefinidos
    $archivosPredefinidos = @("application.log", "application1.log", "application2.log", "application3.txt", "application4.txt")
    $fechaAnterior2 = (Get-Date).AddDays(-1).ToString('yyyy-MM-dd')
    foreach ($archivoPredefinido in $archivosPredefinidos) {
        $rutaArchivoPredefinido = Join-Path -Path $directorio -ChildPath $archivoPredefinido
        if (Test-Path $rutaArchivoPredefinido) {
            $nombreArchivoZip = Join-Path -Path $rutaBackup -ChildPath ($archivoPredefinido + "_" + $fechaAnterior2 + ".zip")
            Compress-Archive -Path $rutaArchivoPredefinido -DestinationPath $nombreArchivoZip -Force
            Remove-Item -Path $rutaArchivoPredefinido -Force
        }
    }
}

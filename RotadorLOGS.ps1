$sourceDirs = @(
    "C:\Users\RS\OneDrive\Escritorio\Test1",
    "C:\Users\RS\OneDrive\Escritorio\Test2"
)

foreach ($dir in $sourceDirs) {
    $backupDir = Join-Path $dir "BackupZip"
    if (!(Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir | Out-Null
    }
}

for ($j = 0; $j -lt $sourceDirs.Count; $j++) {
    $sourceDir = $sourceDirs[$j]
    $destinationDir = Join-Path $sourceDir "BackupZip"

    #Caso1: todos los dias a las 00:00 se genera un archivo nuevo de log con fecha actual, entonces el el directorio a las 00:00
    #existiran 2 archivos, ejemplo, uno llamado Archivo_20230313 y otro (Archivo_20230314 <--que se genero a las 00:00)
    #Solucion: Buscar el archivo: ( prefijo "Archivo_" + fecha de jecucion del script 7 dias atras por si los findes no genera archivos
    #Codigo: Busca el archivo $prefijo + la fecha anterior a la que se ejecuta el script(7 dias para atras), lo zipea y borra
    $Prefijoarchivo = "ServiceLayer-"
    for ($i = 1; $i -le 7; $i++) {
        $fileDate = (Get-Date).AddDays(-$i).ToString("yyyy-MM-dd")
        $fileName = $Prefijoarchivo + $fileDate + ".log"
        if (Test-Path "$sourceDir\$fileName") {
            $zipName = $fileName + ".zip" # Nombre del archivo ZIP
            $zipFile = Join-Path $destinationDir $zipName # Ruta completa del archivo ZIP en la carpeta de destino
            Compress-Archive -Path "$sourceDir\$fileName" -DestinationPath $zipFile -CompressionLevel Optimal
            Remove-Item "$sourceDir\$fileName" # Elimina el archivo original después de comprimirlo
            break # Detiene el ciclo for si se encuentra y comprime el archivo
        }
    }

    #Caso2: Archivo LOG que siempre tiene el mismo nombre pero incrementa el contenido
    #Solucion: Busca el archivo de la variable $ArchivoCompleto, lo zipea con fecha anterior a la ejecucion y elimina (al la app que logea creara otro)      
    # Busca el archivo a comprimir con nombre genérico
    $NombreCompletoArchivo = "application.log"
    if (Test-Path "$sourceDir\$NombreCompletoArchivo") {
        $zipName = $NombreCompletoArchivo + "_" + (Get-Date).AddDays(-1).ToString("yyyy-MM-dd") + ".zip" # Nombre del archivo ZIP con la fecha actual menos un día
        $zipFile = Join-Path $destinationDir $zipName # Ruta completa del archivo ZIP en la carpeta de destino
        Compress-Archive -Path "$sourceDir\$NombreCompletoArchivo" -DestinationPath $zipFile -CompressionLevel Optimal
        Remove-Item "$sourceDir\$NombreCompletoArchivo"
    }
}

# Elimina los archivos ZIP antiguos de los subdirectorios "Backup"
$maxAge = 30 #días
foreach ($dir in $sourceDirs) {
    $backupDir = Join-Path $dir "Backup"
    Get-ChildItem -Path $backupDir -Filter "*.zip" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$maxAge) } | Remove-Item -Force
}

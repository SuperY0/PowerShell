$sourceDirs = @(
    "C:\Users\RS\OneDrive\Escritorio\Test1",
    "C:\Users\RS\OneDrive\Escritorio\Test2"
)
$destinationDirs = @(
    "C:\Users\RS\OneDrive\Escritorio\Test1\Zipeados_antiguos",
    "C:\Users\RS\OneDrive\Escritorio\Test2\Zipeados_antiguos"
)
$FechaEjecucionMenos1dia = (Get-Date).AddDays(-1).ToString("yyyyMMdd")
$PrefijodelArchivo = "ServiceLayer"

#Caso1: todos los dias a las 00:00 se genera un archivo nuevo de log con fecha actual, entonces el el directorio a las 00:00
#existiran 2 archivos, ejemplo, uno llamado Archivo_20230313 y otro (Archivo_20230314 <--que se genero a las 00:00)
#Solucion: Buscar el archivo: ( prefijo "Archivo_" + fecha de jecucion del script 7 dias atras por si los findes no genera archivos
#Codigo: Busca el archivo $prefijo + la fecha anterior a la que se ejecuta el script(7 dias para atras), lo zipea y borra

for ($j = 0; $j -lt $sourceDirs.Count; $j++) {
    $sourceDir = $sourceDirs[$j]
    $destinationDir = $destinationDirs[$j]

    # Busca el archivo a comprimir con fecha anterior a la actual hasta 7 dias atras
    for ($i = 1; $i -le 7; $i++) {
        $fileDate = (Get-Date).AddDays(-$i).ToString("yyyyMMdd")
        $fileName = $PrefijodelArchivo + $fileDate + ".log"
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

    $ArchivoCompleto = "aplication.log"
    if (Test-Path "$sourceDir\$ArchivoCompleto") {
        $zipName = $ArchivoCompleto + "_" + $FechaEjecucionMenos1dia + ".zip" # Nombre del archivo ZIP con la fecha actual menos un día
        $zipFile = Join-Path $destinationDir $zipName # Ruta completa del archivo ZIP en la carpeta de destino
        Compress-Archive -Path "$sourceDir\$ArchivoCompleto" -DestinationPath $zipFile -CompressionLevel Optimal
        Remove-Item "$sourceDir\$ArchivoCompleto"
    }
}


#Busca en los directorios $destinationDirs los zip que tengan 30 dias de antiguos y los borra
$maxAge = 30 #días
foreach ($dir in $destinationDirs) {
    Get-ChildItem -Path $dir -Filter "*.zip" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$maxAge) } | Remove-Item -Force
}

#============================================================
# BACKUP
#============================================================
$DBaBackupear = "XXX"
$Ambiente = "XXX"
$ArchivoBackupeado = $DBaBackupear+"_"+$Ambiente
$Ruta = "\\XXX\XXX\"
$ServerSQL = "XXXX"
$UsuarioSQL = "XXXXX"
$PassSQL = "XXXXX"
$start1 = [datetime]::Now
# Realizar el backup de la base de datos
$sqlcmd = "sqlcmd -S $ServerSQL -U $UsuarioSQL -P $PassSQL -Q `"BACKUP DATABASE [$DBaBackupear] TO DISK='$Ruta$ArchivoBackupeado.bak' WITH COPY_ONLY, NOINIT`""
Invoke-Expression $sqlcmd

# Comprobar si el backup se realizó correctamente y mostrar un mensaje
if (Test-Path $Ruta$ArchivoBackupeado.bak) {
    Write-Host "RESTORE OK $ArchivoBackupeado.bak"
    $timedurationinseconds = ([datetime]::Now - $start1).TotalSeconds
    "Se backupeo en: $timedurationinseconds"
} else {
    Write-Host "Se ha producido un error al realizar el backup de $ArchivoBackupeado.bak"
}


#============================================================
# RESTORE
#============================================================
$DB_a_Restaurar = $ArchivoBackupeado
$DB_a_RestaurarExt = $ArchivoBackupeado+".bak"
$RutaMDF = "D:\SQLData\"+$DB_a_Restaurar
$RutaLDF = "L:\SQLLogs\"+$DB_a_Restaurar
$server = "XXX"
$start2 = [datetime]::Now

Write-Host "Start: $start2"
Write-Host "Restoring: $DB_a_Restaurar"

$tmp = SQLCMD -S $server -E -Q "RESTORE FILELISTONLY FROM DISK = '$Ruta$DB_a_RestaurarExt' WITH FILE = 1"
$data = $tmp[2]
$log = $tmp[3]
$dbnamedata = $data.Substring(0, $data.Indexof(" "))
$dbnamelog = $log.Substring(0, $log.Indexof(" "))

$sqlCmdOptions = "RESTORE DATABASE [$DB_a_Restaurar] FROM  DISK = N'$Ruta$DB_a_RestaurarExt' WITH FILE = 1,  MOVE N'$dbnamedata' TO N'$RutaMDF.mdf',  MOVE N'$dbnamelog' TO N'$RutaLDF.ldf',  NORECOVERY,  NOUNLOAD,  REPLACE,  STATS = 10"
SQLCMD -S $server -Q $sqlCmdOptions -E

#============================================================
# Restore the Database into normal mode
#============================================================
SQLCMD -S $server -Q "RESTORE LOG [$DB_a_Restaurar]" -E

#============================================================
# Rename Logical Names, DATA & LOG
#============================================================
$dbnamedataNEW = "ALTER DATABASE [$DB_a_Restaurar] MODIFY FILE ( NAME = '$dbnamedata', NEWNAME = '$DB_a_Restaurar' )"
SQLCMD -S $server -Q $dbnamedataNEW -E
$aaa = $DB_a_Restaurar+"_log"
$dbnamelogNEW = "ALTER DATABASE [$DB_a_Restaurar] MODIFY FILE ( NAME = '$dbnamelog', NEWNAME = '$aaa' )"
SQLCMD -S $server -Q $dbnamelogNEW -E

Write-Host "RESTORE OK $DB_a_Restaurar"
$timedurationinseconds = ([datetime]::Now - $start2).TotalSeconds
"Se restauro en: $timedurationinseconds"


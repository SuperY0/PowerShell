
#Este script requiere la utilidad SQLCMD en la maquina donde se ejecuta
#https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility?view=sql-server-ver16
##============================================================
## BACKUP
##============================================================
## Inicia la grabación del log.
Start-Transcript -Path "C:\DB_Backup_Restore_Script.txt"

$ServerSQLBackup_Origen = "xxxxx"  					#Server Origen    
$DB_a_Backupear_Origen = "DBxxx"             		#DB Origen

$ServerSQLRestore_Destino = "servername/ip"  		#Server Destino   
$DB_a_Restaurar_Destino = "DBxxx"   	    		#DB Destino


$ArchivoBackupeado = $DB_a_Backupear_Origen+"_"+(Get-Date -Format yyyyMMdd_hhmm)
$RutadelBackup = "\\xxxxx\Shared\"   
$UsuarioSQL = "xxxxx"
$PassSQL = "xxxx"


# Chequea si la base a restaurar ya existe para evitar pisarla por accidente
$sql = "SELECT COUNT(*) as Count FROM sys.databases WHERE LOWER(name) = LOWER('$DB_a_Restaurar_Destino')"
$comprueba = (sqlcmd -S $ServerSQLRestore_Destino -U $UsuarioSQL -P $PassSQL -d "master" -h -1 -W -Q $sql | Select-String -Pattern '^[0-9]').Line
 
# Si la base de datos ya existe, muestra un mensaje
if ($comprueba -eq 1) {
Write-Host "Guardaaaaa, la base de datos a restaurar/destino ya existe, por seguridad este script no pisa bases existentes"
}
# Si la base de datos no existe, ejecuta el bloque de código
else {

# Realizar el backup de la base de datos
$BackupTiempoInicial = Get-Date
Write-Host "Comienzo: $BackupTiempoInicial"
Write-Host "Backupeando: $DB_a_Backupear_Origen"

SQLCMD -S $ServerSQLBackup_Origen -U $UsuarioSQL -P $PassSQL -Q "BACKUP DATABASE [$DB_a_Backupear_Origen] TO DISK='$RutadelBackup$ArchivoBackupeado.bak' WITH COPY_ONLY, NOINIT"
# Comprobar si el backup se realizó correctamente y mostrar un mensaje
if (Test-Path $RutadelBackup$ArchivoBackupeado.bak) {
    Write-Host "BACKUP OK $RutadelBackup$ArchivoBackupeado.bak"
    $BackupTiempoFinal = Get-Date
    $TiempoTranscurrido = New-TimeSpan $BackupTiempoInicial $BackupTiempoFinal
    $MinutosTranscurridos = [Math]::Floor($TiempoTranscurrido.TotalMinutes)
    $SegundosTranscurridos = $TiempoTranscurrido.Seconds
    Write-Host "El Backup tardo $MinutosTranscurridos minutos y $SegundosTranscurridos segundos en ejecutarse."
} else {
    Write-Host "Se ha producido un error al realizar el backup de $ArchivoBackupeado.bak"
}

#============================================================
# RESTORE
#============================================================
$DB_a_Restaurar_DestinoExt =  $ArchivoBackupeado+".bak" 
$RutaMDF = "D:\SQLData\"+$DB_a_Restaurar_Destino
$RutaLDF = "L:\SQLLogs\"+$DB_a_Restaurar_Destino

$RestoreTiempoInicial = Get-Date
Write-Host "Comienzo: $RestoreTiempoInicial"
Write-Host "Restoreando: $DB_a_Restaurar_Destino"

$tmp = SQLCMD -S $ServerSQLRestore_Destino -U $UsuarioSQL -P $PassSQL -Q "RESTORE FILELISTONLY FROM DISK = '$RutadelBackup$DB_a_Restaurar_DestinoExt' WITH FILE = 1"
$data = $tmp[2]
$log = $tmp[3]
$dbnamedata = $data.Substring(0, $data.Indexof(" "))
$dbnamelog = $log.Substring(0, $log.Indexof(" "))

SQLCMD -S $ServerSQLRestore_Destino -U $UsuarioSQL -P $PassSQL -Q "RESTORE DATABASE [$DB_a_Restaurar_Destino] FROM  DISK = N'$RutadelBackup$DB_a_Restaurar_DestinoExt' WITH FILE = 1,  MOVE N'$dbnamedata' TO N'$RutaMDF.mdf',  MOVE N'$dbnamelog' TO N'$RutaLDF.ldf',  NORECOVERY,  NOUNLOAD, STATS = 10"


#============================================================
# Restore the Database into normal mode
#============================================================
SQLCMD -S $ServerSQLRestore_Destino -U $UsuarioSQL -P $PassSQL -Q "RESTORE LOG [$DB_a_Restaurar_Destino]"

#============================================================
# Rename Logical Names, DATA & LOG
#============================================================
SQLCMD -S $ServerSQLRestore_Destino -U $UsuarioSQL -P $PassSQL -Q "ALTER DATABASE [$DB_a_Restaurar_Destino] MODIFY FILE ( NAME = '$dbnamedata', NEWNAME = '$DB_a_Restaurar_Destino' )"
$dblog = $DB_a_Restaurar_Destino+"_log"
SQLCMD -S $ServerSQLRestore_Destino -U $UsuarioSQL -P $PassSQL -Q "ALTER DATABASE [$DB_a_Restaurar_Destino] MODIFY FILE ( NAME = '$dbnamelog', NEWNAME = '$dblog' )"

$RestoreTiempoFinal = Get-Date
$TiempoTranscurrido = New-TimeSpan $RestoreTiempoInicial $RestoreTiempoFinal
$MinutosTranscurridos = [Math]::Floor($TiempoTranscurrido.TotalMinutes)
$SegundosTranscurridos = $TiempoTranscurrido.Seconds
Write-Host "El RESTORE tardo $MinutosTranscurridos minutos y $SegundosTranscurridos segundos en ejecutarse."

Write-Host "`n`n"


#============================================================
# Posibilidad de aplicar querys segun coincidencia de la base a restaurar/destino
#============================================================
#---SI el nombre de la base destino contiene BDxxx ejecuta bloque de codigo---
if ($DB_a_Restaurar_Destino -like "*BDxxx*") {
	#---Setea xxxx---
	echo "#---Setea xxxx---"
	SQLCMD -S $ServerSQLRestore_Destino -d $DB_a_Restaurar_Destino -U $UsuarioSQL -P $PassSQL -Q "queryxxxxxx para setear xxx"
	echo "#-------------------------------"
	
	Write-Host "`n`n"
	
		
	#---SI el nombre de la base destino contiene AAA ejecuta bloque de codigo---
	if ($DB_a_Restaurar_Destino -like "*AAA*") {
		echo "#---Setea xxxx---"
		SQLCMD -S $ServerSQLRestore_Destino -d $DB_a_Restaurar_Destino -U $UsuarioSQL -P $PassSQL -Q "queryxxxxxx para setear xxx"
		echo "#-------------------------------"
		
		Write-Host "`n`n"
		
	#---SI el nombre de la base destino contiene BBB ejecuta bloque de codigo---	
	} elseif ($DB_a_Restaurar_Destino -like "*BBB*") {
		echo "#---Setea xxxx---"
		SQLCMD -S $ServerSQLRestore_Destino -d $DB_a_Restaurar_Destino -U $UsuarioSQL -P $PassSQL -Q "queryxxxxxx para setear xxx"
		echo "#-------------------------------"
		
		Write-Host "`n`n"
		
	#---SI el nombre de la base destino contiene CCC ejecuta bloque de codigo---	
	} elseif ($DB_a_Restaurar_Destino -like "*CCC*") {
		echo "#---Setea xxxxx---"
		SQLCMD -S $ServerSQLRestore_Destino -d $DB_a_Restaurar_Destino -U $UsuarioSQL -P $PassSQL -Q "queryxxxxxx para setear xxx"
		echo "#-------------------------------"
		
		Write-Host "`n`n"
		
	}
	#---SI el nombre de la base destino no coincide con lo de arriba setea xxx---
	} else {
		echo "#---NO Coincidio con ningun ambiente setea xxxxx---"
		SQLCMD -S $ServerSQLRestore_Destino -d $DB_a_Restaurar_Destino -U $UsuarioSQL -P $PassSQL -Q "queryxxxxxx para setear xxx"
		echo "#-------------------------------"
		
		Write-Host "`n`n"
	}

#---SI el nombre de la base destino no coincide con el if principal ejecuta bloque de codigo---	
} elseif ($DB_a_Restaurar_Destino -like "*BDzzzz*") {
	#--Setea xxxx
	echo "#---Setea xxxx---"
	SQLCMD -S $ServerSQLRestore_Destino -d $DB_a_Restaurar_Destino -U $UsuarioSQL -P $PassSQL -Q "queryxxxxxx para setear xxx"
	echo "#-------------------------------"
	
	Write-Host "`n`n"
}


#============================================================
# agrega usuario y rol userXXX como db_owner
#============================================================
echo "#---se agrega usuario y rol userXXX como db_owner---"
SQLCMD -S $ServerSQLRestore_Destino -d $DB_a_Restaurar_Destino -U $UsuarioSQL -P $PassSQL -Q "DROP USER userXXX"
SQLCMD -S $ServerSQLRestore_Destino -d $DB_a_Restaurar_Destino -U $UsuarioSQL -P $PassSQL -Q "CREATE USER userXXX; EXEC sp_addrolemember 'db_owner', 'userXXX'"
echo "#-------------------------------"

Write-Host "`n`n"

Stop-Transcript
#============================================================
# envia log por mail
#============================================================


$correoDestino = "xxxx@xxx.com"
$correoOrigen = "xxxx@xxx.com"
$smtpServidor = "serverxxx"
$smtpPuerto = 25 
$asunto = "Se restauro " + $DB_a_Restaurar_Destino + " con "+ $DB_a_Backupear_Origen
$cuerpo = Get-Content "C:\DB_Backup_Restore_Script.txt" | Out-String
$adjunto = "C:\DB_Backup_Restore_Script.txt"
Send-MailMessage -To $correoDestino -From $correoOrigen -Subject $asunto -Body $cuerpo -SmtpServer $smtpServidor -Port $smtpPuerto -Attachments $adjunto
}
pause

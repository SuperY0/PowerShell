#SCRIPT INSTALACION DESATENDIDA PHP7.4.30+DriversSQLSRV510_NTS_x64+COMPOSER+variables de entorno + NODEjs


############################################
#Activar Roles and Features IIS + CGI
############################################
#Crear Modulo en IIS a nivel server "Add module Mapping"
#Request Path: *.php
#Module: FastCgiModule
#Executable: C:\php\php-cgi.exe
#Name: FastCGI
############################################


#----DECLARACION DE VARIABLES, OPCION DE ESPECIFICAR urls de VERSIONES A DESCARGAR y directorio de instalacion
#----Link ultima version PHP7.1 -> https://windows.php.net/downloads/releases/archives/php-7.1.9-nts-Win32-VC14-x64.zip
#----Link Microsoft Driver SQL-> https://docs.microsoft.com/en-us/sql/connect/php/release-notes-php-sql-driver?view=sql-server-ver16#previous-releases
$PHP_url = "https://windows.php.net/downloads/releases/php-8.0.20-nts-Win32-vs16-x64.zip"
$PHP_path = "C:\php\"
$TEMP_path = "C:\Windows\Temp\"
#$SQLDriver_url = "https://download.microsoft.com/download/F/1/B/F1B49733-E519-419B-A192-10DCE6E3C35B/SQLSRV561.EXE" #Usar para PHP7.1
$SQLDriver_url = "https://download.microsoft.com/download/f/4/d/f4d95d48-74ae-4d72-a602-02145a5f29c8/SQLSRV510.ZIP"  #Usar para PHP7.4 en adelante
$ODBCDriver_url= "https://download.microsoft.com/download/1/a/4/1a4a49b8-9fe6-4237-be0d-a6b8f2d559b5/en-US/18.0.1.1/x64/msodbcsql.msi"
$COMPOSER_url = "https://getcomposer.org/Composer-Setup.exe"
$NODEJS_url = "https://nodejs.org/dist/v16.15.1/node-v16.15.1-x64.msi"
$SQLDriver_version = "74" #Versiones "71", "74", "80", "81"
##########################################################################################################################################################


#---------Descarga y Descomprime PHP
curl -o $Temp_path'php.zip' $PHP_url
Expand-Archive -LiteralPath $Temp_path'php.zip' -DestinationPath $PHP_path


#---Usar para PHP7.4 en adelante------Descarga y Descomprime Drivers SQL ---USAR esto cuando el archivo es un .zip (paquete drivers SQLSRV510.ZIP)
curl -o $Temp_path'sqldrivers.zip' $SQLDriver_url
Expand-Archive -LiteralPath $Temp_path'sqldrivers.zip' -DestinationPath $Temp_path'sqldrivers'
#---Usar para PHP7.1------Descarga y Descomprime Drivers SQL ---USAR esto cuando el archivo es un .exe (paquete drivers SQLSRV561.EXE(Ultima version para PHP7.1))
#curl -o $Temp_path'sqldrivers.exe' $SQLDriver_url
#Invoke-Expression -Command "$TEMP_path'sqldrivers.exe' /Q /T:C:\Windows\Temp\sqldrivers"


#Copia los Drivers SQL de la version indicada en la variable $SQLDriver_version carpeta al la carpeta "ext" de php
copy $Temp_path'sqldrivers'\'php_sqlsrv_'$SQLDriver_version'_nts_x64.dll' $PHP_path'ext'
copy $Temp_path'sqldrivers'\'php_pdo_sqlsrv_'$SQLDriver_version'_nts_x64.dll' $PHP_path'ext'


#---------Descarga e Instala ODBC Drivers
curl -o $Temp_path'msodbcsql.msi' $ODBC_Driver_url
msiexec.exe /i $Temp_path'msodbcsql.msi' /passive IACCEPTMSODBCSQLLICENSETERMS=YES


#---------Renombra el php.ini-production que viene por default a php.ini
copy $PHP_path'php.ini-production' $PHP_path'php.ini'


#---------Habilita extensiones en php.ini de los drivers sql de la version indicada en la variable $SQLDriver_version
Add-Content -Path $PHP_path'php.ini' -Value '#------------EXTENSIONES CUSTOM-------------------------' 
Add-Content -Path $PHP_path'php.ini' -Value extension='php_sqlsrv_'$SQLDriver_version'_nts_x64.dll'
Add-Content -Path $PHP_path'php.ini' -Value extension='php_pdo_sqlsrv_'$SQLDriver_version'_nts_x64.dll'


#---------Habilita extensiones necesarias para COMPOSER
#Add-Content -Path $PHP_path'php.ini' -Value 'extension_dir = "ext"' #hay que habilitar cuando no se usa la ruta default de extensiones C:\php\ext\
#Add-Content -Path $PHP_path'php.ini' -Value 'allow_url_fopen = On' //ya viene habilitado en el php.ini-production
Add-Content -Path $PHP_path'php.ini' -Value extension=curl
Add-Content -Path $PHP_path'php.ini' -Value extension=mbstring
Add-Content -Path $PHP_path'php.ini' -Value extension=openssl


#---------Descarga e Instala COMPOSER 
curl -o $Temp_path'ComposerSetup.exe' $COMPOSER_url
Invoke-Expression -Command "$Temp_path'ComposerSetup.exe' /VERYSILENT /SUPPRESSMSGBOXES /ALLUSERS"


#---------Descarga e Instala NODEjs 
#Descarga a C:\Windows\Temp
curl -o $Temp_path'node.msi' $NODEJS_url
msiexec.exe /i $Temp_path'node.msi' /passive


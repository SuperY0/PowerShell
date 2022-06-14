############################################
#Pre-Requisitos:Roles and Features IIS + CGI
############################################
#Crear Modulo en IIS a nivel de server "Add module Mapping"
#Request Path: *.php
#Module: FastCgiModule
#Executable: C:\PHP7.4.30\php-cgi.exe
#Name: FastCGI
############################################


#Descarga a C:\Windows\Temp
curl -o C:\Windows\Temp\php-7.4.30-nts-Win32-vc15-x64.zip https://windows.php.net/downloads/releases/php-7.4.30-nts-Win32-vc15-x64.zip

#descomprime a C:\PHP7.4.30
Expand-Archive -LiteralPath C:\Windows\Temp\php-7.4.30-nts-Win32-vc15-x64.zip -DestinationPath C:\PHP7.4.30

#Descarga SQL Drivers a C:\Windows\Temp
curl -o C:\Windows\Temp\SQLSRV510.ZIP https://download.microsoft.com/download/f/4/d/f4d95d48-74ae-4d72-a602-02145a5f29c8/SQLSRV510.ZIP

#descomprime SQL Drivers a C:\Windows\Temp\SQLSRV510
Expand-Archive -LiteralPath C:\Windows\Temp\SQLSRV510.ZIP -DestinationPath C:\Windows\Temp\SQLSRV510

copy C:\Windows\Temp\SQLSRV510\php_pdo_sqlsrv_74_nts_x64.dll C:\PHP7.4.30\ext\php_pdo_sqlsrv_74_nts_x64.dll
copy C:\Windows\Temp\SQLSRV510\php_sqlsrv_74_nts_x64.dll C:\PHP7.4.30\ext\php_sqlsrv_74_nts_x64.dll
copy C:\PHP7.4.30\php.ini-production C:\PHP7.4.30\php.ini

Add-Content -Path C:\PHP7.4.30\php.ini -Value 'extension_dir = "ext"'
Add-Content -Path C:\PHP7.4.30\php.ini -Value 'extension=php_pdo_sqlsrv_74_nts_x64.dll'
Add-Content -Path C:\PHP7.4.30\php.ini -Value 'extension=php_sqlsrv_74_nts_x64.dll'




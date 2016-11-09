@echo off

cd %1
cd..\..

taskkill /F /IM AutoPlayDesign.exe
taskkill /F /IM autorun.exe
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%"

MOVE iTStock @OLD_iTStock_%datestamp%_%timestamp%
git clone --progress https://github.com/ksad/iTStock.git

pause
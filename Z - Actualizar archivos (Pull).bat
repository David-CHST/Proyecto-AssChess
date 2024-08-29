@echo off
setlocal
chcp 65001 > nul
REM -----------------------------------------------------------
REM --------------------- DATOS MODIFICABLES ------------------
REM -----------------------------------------------------------
REM -----------------------------------------------------------
REM -----------------------------------------------------------
REM ninguno
REM -----------------------------------------------------------
REM -----------------------------------------------------------
REM -----------------------------------------------------------
REM -----------------------------------------------------------
REM -----------------------------------------------------------

echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo - - - Se debe aplicar un commit antes de realizar el pull - - -
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

REM PARTE 1: MENSAJE PARA COMMIT
set /p commit_text=Ingrese el mensaje para el commit previo al pull (sin tildes):

REM PARTE 2: AGREGAR TODO EL CONTENIDO DE LA CARPETA
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo - - - Preparando el commit con los archivos presentes - - - - -
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
@echo on
git add . 
@echo off

echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo - - - Si procede se actualizarán los archivos del repositorio en su computadora - - -
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

REM PARTE 3: CONFIRMAR PULL
set /p yes_no=Desea hacer el commit y hacer el pull de los archivos? (y/n) 

if /i "%yes_no%"=="y" (
	goto :yes_script
) else (
	goto :no_script
    pause
)

:yes_script
REM PARTE 4: PULL

echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo - - - - Ejecutando el commit con el mensaje insertado - - - -
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
@echo on
git commit -m "%commit_text%"
git status
@echo off
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo - - - - Seleccione el branch para hacer el pull - - - - - - -
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo.
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo - - - - Por defecto el branch es main - - - - - - - - - - - -
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

set /p branch_name=Inserte el nombre del branch al que desea hacer el pull: 
REM PARTE 5: PULLING ARCHIVOS
echo.
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo - - - - Intentando pull de archivos - - - - - - - - - - - - -
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

@echo on
git pull origin "%branch_name%"
@echo off

if %errorlevel% neq 0 (
	echo Hubo un error al realizar el pull.
	goto :no_script
) else (
	echo - - - - - - - - - - - - - - - - - - - - -
	echo - - - - Fin de Pull - - - - - - - - - - -
	echo - - - - - - - - - - - - - - - - - - - - -
	REM -- FIN DEL PULL --
)
pause

goto :end_script

:no_script
REM -- CANCELADO PULL --
echo - - - - - - - - - - - - - - - - - - -
echo - - - -  Pull fucking died  - - - - -
echo - - - - - - - - - - - - - - - - - - -
echo.
echo.
echo.
goto :end_script

:end_script
endlocal

cmd /k
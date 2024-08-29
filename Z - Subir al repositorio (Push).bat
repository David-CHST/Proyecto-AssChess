@echo off

REM PARTE 1: MENSAJE PARA COMMIT
set /p commit_text=Ingrese el mensaje para el commit (sin tildes):

REM PARTE 2: AGREGAR TODO EL CONTENIDO DE LA CARPETA
echo - - - - - - - - - - - - - - - - - - - - - - - - -
echo - - Agregando todos los cambios de la carpeta - -
echo - - - - - - - - - - - - - - - - - - - - - - - - -
@echo on
git add . 
@echo off

REM PARTE 3: EJECUTAR COMMIT CON EL MENSAJE INGRESADO
echo - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo - - Ejecutando el commit con el mensaje insertado - -
echo - - - - - - - - - - - - - - - - - - - - - - - - - - -
@echo on
git commit -m "%commit_text%"
git status
@echo off
echo - - - - - - - - - - - - - - - - - - - - - - - - -
echo - - Commit realizado (revisar previo al push) - -
echo - - - - - - - - - - - - - - - - - - - - - - - - -

REM PARTE 4: CONFIRMAR PUSH
set /p yes_no=Desea realizar el push a la nube? (y/n) 

if /i "%yes_no%"=="y" (
	echo - - - - - - - - - - - - - - - - - - - - -
    echo - - - - Push Inicializado - - - - - - - -
	echo - - - - - - - - - - - - - - - - - - - - -
    REM PARTE 5: EJECUTANDO PUSH
	echo.
	echo - - - - - - - - - - - - - - - - - - - - -
    echo - - - - Branch principal = main - - - - -
	echo - - - - - - - - - - - - - - - - - - - - -
    set /p branch_name=Ingrese el nombre exacto del branch:
    @echo on
    git push origin %branch_name%
	@echo off
    if %errorlevel% neq 0 (
        echo Hubo un error al realizar el push.
    ) else (
		echo - - - - - - - - - - - - - - - - - -
        echo - - - -  Push Finalizado  - - - - -
		echo - - - - - - - - - - - - - - - - - -
        REM -- FIN DEL PUSH --
    )
    pause
) else (
	echo - - - - - - - - -  - - - - - - - - - -
    echo - - - -  Push ha fallado   - - - - - -
	echo - - - - - - - - -  - - - - - - - - - -
    pause
)

cmd /k
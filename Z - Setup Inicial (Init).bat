@echo off

REM PARTE 1: MENSAJE PARA COMMIT
set /p upstream_text=Ingrese el link del repositorio para --set-upstream (sin tildes):
set /p branch_text=Ingrese el nombre para el master branch (usualmente "master" o "main"):
set /p commit_text=Ingrese el mensaje para el primer commit (sin tildes):


REM PARTE 2: AGREGAR TODO EL CONTENIDO DE LA CARPETA
echo - - - - - - - - - - - - - - - - - - - - - - - - -
echo - - Inicializando el contenido del repo - - - - -
echo - - - - - - - - - - - - - - - - - - - - - - - - -
@echo on
git init
git add . 
git remote add origin %upstream_text%
git branch -M %branch_text%
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
set /p yes_no=Desea vincular y hacer push al repositorio %upstream_text% ? (y/n) 

if /i "%yes_no%"=="y" (
	echo - - - - - - - - - - - - - - - - - - - - -
    echo - - - - Push Inicializado - - - - - - - -
	echo - - - - - - - - - - - - - - - - - - - - -
    REM PARTE 5: VINCULANDO Y HACIENDO PUSH
	echo.
	echo - - - - - - - - - - - - - - - - - - - - -
    echo - - - - Branch principal = %branch_text% - -
	echo - - - - - - - - - - - - - - - - - - - - -
    @echo on
    git push --set-upstream origin %branch_text%
	@echo off
    if %errorlevel% neq 0 (
        echo Hubo un error al realizar el push.
    ) else (
		echo - - - - - - - - - - - - - - - - - -
        echo - - - -  Push Finalizado  - - - - -
		echo - - - - - - - - - - - - - - - - - -
        REM -- FIN DEL PUSH --
    )
) else (
	echo - - - - - - - - -  - - - - - - - - - -
    echo - - - -  Push fucking died   - - - - -
	echo - - - - - - - - -  - - - - - - - - - -
)

REM PARTE 6: BORRAR ARCHIVO
set /p yes_no2=Desea borrar este script para no volver a usarlo? (y/n) 

if /i "%yes_no2%"=="y" (
	echo - - - - - - - - - - - - - - - - - - - - -
    echo - - - -  Borrando archivo - - - - - - - -
	echo - - - - - - - - - - - - - - - - - - - - -
	echo.
	echo - - - - - - - - - - - - - - - - - - - - -
    echo - - - - Goodbye my friend - - - - - - - -
	echo - - - - - - - - - - - - - - - - - - - - -
	set /p lastwords=Got anything you wanted to say before I die?
	del %0
) else (
	echo - - - - - - - - -  - - - - - - - - - -
    echo - - - -  Thank you so much   - - - - -
	echo - - - - - - - - -  - - - - - - - - - -
	echo - - - - - - - - -  - - - - - - - - - -
    echo - - - -  You saved my life   - - - - -
	echo - - - - - - - - -  - - - - - - - - - -
    pause
)

cmd /k
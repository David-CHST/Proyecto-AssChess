import time
import random  # para los números random
from supabase import create_client, Client
from datetime import datetime

SUPABASE_URL = 'https://abtayeggwvptdvolqnki.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFidGF5ZWdnd3ZwdGR2b2xxbmtpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY0NTA3NzAsImV4cCI6MjA0MjAyNjc3MH0.sefl8kqy-ZiO2vaRT40c_5p0OW4uR24bbeynZtOg23s'  

# Se inicializa el cliente de Supabase
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

BUCKET_NAME = "chessBucket" 
ASM_API_FILE = "asmCustomAPI.txt"

def descargarArchivo(nombreUno, nombreDos):
    # Descargar el archivo TXT
    # Genera una marca de tiempo con el formato AñoMesDíaHoraMinutoSegundo
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    # Descarga el archivo desde Supabase usando la URL con el parámetro
    print(f'game-{nombreUno}-{nombreDos}.txt?{timestamp}')
    respuesta = supabase.storage.from_(BUCKET_NAME).download(f'game-{nombreUno}-{nombreDos}.txt')
    
    # Decodificar el archivo TXT e Imprimir sus Contenidos
    return respuesta.decode('utf-8')

# Función para crear y subir un archivo TXT, sobrescribiéndolo si ya existe
def subirArchivo(nombreUno, nombreDos, contenido, permitirCrear=False):
    if permitirCrear:
        try:
            # Definir el nombre del archivo usando las variables
            nombreArchivo = f'game-{nombreUno}-{nombreDos}.txt'
            
            # Crear o sobrescribir el archivo localmente con el contenido dado
            with open(nombreArchivo, 'w') as f:
                f.write(contenido)
            
            print(f"Archivo creado/actualizado: {nombreArchivo}")

            # Leer el archivo como binario para poder subirlo
            with open(nombreArchivo, 'rb') as f:
                contenidoArchivo = f.read()

            # Subir el archivo al bucket en Supabase, sobrescribiéndolo si ya existe ('upsert': True)
            # Intentar eliminar el archivo en caso de que ya exista
            try:
                supabase.storage.from_(BUCKET_NAME).remove([nombreArchivo])
                print(f"Archivo existente eliminado en Supabase: {nombreArchivo}")
            except Exception as e:
                print(f"No se pudo eliminar el archivo (puede que no exista): {e}")


            supabase.storage.from_(BUCKET_NAME).upload(nombreArchivo, contenidoArchivo)
            print(f"Archivo subido/actualizado en Supabase: {nombreArchivo}")

        except Exception as e:
            # Manejar errores durante la creación o subida del archivo
            print(f"Error creando o subiendo el archivo: \n {e}")
    else:
        try:
            contenidoEnNube = descargarArchivo(nombreUno, nombreDos)
            # Crear o sobrescribir el archivo localmente con el contenido dado
            nombreArchivo = f'game-{nombreUno}-{nombreDos}.txt'
            with open(nombreArchivo, 'w') as f:
                f.write(contenido)
            
            print(f"Archivo creado/actualizado: {nombreArchivo}")

            # Leer el archivo como binario para poder subirlo
            with open(nombreArchivo, 'rb') as f:
                contenidoArchivo = f.read()

            # Subir el archivo al bucket en Supabase, sobrescribiéndolo si ya existe ('upsert': True)
            # Intentar eliminar el archivo en caso de que ya exista
            try:
                supabase.storage.from_(BUCKET_NAME).remove([nombreArchivo])
                print(f"Archivo existente eliminado en Supabase: {nombreArchivo}")
            except Exception as e:
                print(f"No se pudo eliminar el archivo (puede que no exista): {e}")


            supabase.storage.from_(BUCKET_NAME).upload(nombreArchivo, contenidoArchivo)
            print(f"Archivo subido/actualizado en Supabase: {nombreArchivo}")
        except Exception as e:
            print(e)
            try:
                contenidoEnNube = descargarArchivo(nombreDos, nombreUno)
                nombreArchivo = f'game-{nombreDos}-{nombreUno}.txt'
                # Crear o sobrescribir el archivo localmente con el contenido dado
                with open(nombreArchivo, 'w') as f:
                    f.write(contenido)
                
                print(f"Archivo creado/actualizado: {nombreArchivo}")

                # Leer el archivo como binario para poder subirlo
                with open(nombreArchivo, 'rb') as f:
                    contenidoArchivo = f.read()

                # Subir el archivo al bucket en Supabase, sobrescribiéndolo si ya existe ('upsert': True)
                # Intentar eliminar el archivo en caso de que ya exista
                try:
                    supabase.storage.from_(BUCKET_NAME).remove([nombreArchivo])
                    print(f"Archivo existente eliminado en Supabase: {nombreArchivo}")
                except Exception as e:
                    print(f"No se pudo eliminar el archivo (puede que no exista): {e}")


                supabase.storage.from_(BUCKET_NAME).upload(nombreArchivo, contenidoArchivo)
                print(f"Archivo subido/actualizado en Supabase: {nombreArchivo}")
            except Exception as e:
                print(e)

def modificarASMAPI(contenidoNuevo):
    with open(ASM_API_FILE, 'w') as f:
        f.write(contenidoNuevo)
    
# Funciones para el accionar segun comunicacion con archivo asm
# esto se ejecuta si el archivo empieza con 0
def cuandoNumEs0():
    print("DETECTA 0")
    if colorOponente == 0: # En caso de tratarse de una movida del oponente, se ignora por el py y es procesada por el ASM
        print(colorOponente, "... es enemigo, esperando procesamiento de ASM")
        return
    
    print("-- Subiendo Movida Local")
    with open(ASM_API_FILE, 'r') as f:
        contenidoLocal = f.read()

    contenidoLocal = contenidoLocal.split()
    print(contenidoLocal)
    jugActual = contenidoLocal[1]
    jugOponente = contenidoLocal[2]
    piezaMovida = contenidoLocal[3]
    casillaDestino = contenidoLocal[4]

    nuevaEscritura = f'0 {jugActual} {jugOponente}'
    try:
        contenidoEnNube = descargarArchivo(jugActual, jugOponente)
    except Exception as e:
        print(e)
        try:
            contenidoEnNube = descargarArchivo(jugOponente, jugActual)
        except Exception as e:
            print(e)

    global archivoEnNubeReferencia
    archivoEnNubeReferencia = contenidoEnNube
    
    # Se añade el historial de movidas al archivo a guardar en la nube
    print("Split Cloud: ", contenidoEnNube.split())
    print("Split Cloud with spaces: ", contenidoEnNube.split(" "))
    for elemento in contenidoEnNube.split():
        if elemento in ['1', '0', jugActual, jugOponente, colorJugador, colorOponente]:
            pass
        else:
            nuevaEscritura += f' {elemento}'
    nuevaEscritura += f' {piezaMovida} {casillaDestino}'

    # Se sube el archivo con la movida a enviar
    print("Archivo a subir: ", nuevaEscritura)
    subirArchivo(jugActual, jugOponente, nuevaEscritura)

    
    
    # Se sobreescribe el archivo ASM para iniciar en 7 (Esperar nuevo movimiento)
    modificarASMAPI(f'7 {colorOponente} {jugActual} {jugOponente}')
    print("-- Esperando Respuesta de Turno Jugador")

# esto se ejecuta si el archivo empieza con 1
def cuandoNumEs1():
    print("DETECTA 1")
    if colorOponente == 1: # En caso de tratarse de una movida del oponente, se ignora por el py y es procesada por el ASM
        print(colorOponente, "... es enemigo, esperando procesamiento de ASM")
        return
    
    print("-- Subiendo Movida Local")
    with open(ASM_API_FILE, 'r') as f:
        contenidoLocal = f.read()

    contenidoLocal = contenidoLocal.split()
    print(contenidoLocal)
    jugActual = contenidoLocal[1]
    jugOponente = contenidoLocal[2]
    piezaMovida = contenidoLocal[3]
    casillaDestino = contenidoLocal[4]

    nuevaEscritura = f'1 {jugOponente} {jugActual}'
    try:
        contenidoEnNube = descargarArchivo(jugOponente, jugActual)
    except Exception as e:
        print(e)
        try:
            contenidoEnNube = descargarArchivo(jugOponente, jugActual)
        except Exception as e:
            print(e)
    
    global archivoEnNubeReferencia
    archivoEnNubeReferencia = contenidoEnNube
    
    # Se añade el historial de movidas al archivo a guardar en la nube
    print("Split Cloud: ", contenidoEnNube.split())
    print("Split Cloud with spaces: ", contenidoEnNube.split(" "))
    for elemento in contenidoEnNube.split():
        if elemento in ['0', '1', jugActual, jugOponente, colorJugador, colorOponente]:
            pass
        else:
            nuevaEscritura += f' {elemento}'
    nuevaEscritura += f' {piezaMovida} {casillaDestino}'

    # Se sube el archivo con la movida a enviar
    print("Archivo a subir: ", nuevaEscritura)
    subirArchivo(jugOponente, jugActual, nuevaEscritura)

    
    # Se sobreescribe el archivo ASM para iniciar en 7 (Esperar nuevo movimiento)
    modificarASMAPI(f'7 {colorOponente} {jugOponente} {jugActual}')
    print("-- Esperando Respuesta de Turno Jugador")

# si el archivo empieza con 2, crea un archivo nuevo con el nombre de los jugadores
def cuandoNumEs2():
    print("DETECTA 2")
    global colorJugador, colorOponente
    colorJugador = 0
    colorOponente = 1


    with open(ASM_API_FILE, 'r') as f:
        contenidoLocal = f.read()

    contenidoLocal = contenidoLocal.split()
    print(contenidoLocal)
    jugActual = contenidoLocal[1]
    jugOponente = contenidoLocal[2]
    piezaMovida = contenidoLocal[3]
    casillaDestino = contenidoLocal[4]

    # Se sube el archivo con la movida a enviar
    subirArchivo(jugActual, jugOponente, f'0 {jugActual} {jugOponente} {piezaMovida} {casillaDestino}', True)
    
    global archivoEnNubeReferencia
    archivoEnNubeReferencia = ""
    
    # Se sobreescribe el archivo ASM para iniciar en 7 (Esperar nuevo movimiento)
    modificarASMAPI(f'7 {colorOponente} {jugActual} {jugOponente}')
    print("-- Enviando Solicitud de Sincronizacion")


# esto se ejecuta si el archivo empieza con 3
def cuandoNumEs3():
    print("DETECTA 3")
    global colorJugador, colorOponente
    colorJugador = 1
    colorOponente = 0

    with open(ASM_API_FILE, 'r') as f:
        contenidoLocal = f.read()

    contenidoLocal = contenidoLocal.split()
    print(contenidoLocal)
    jugActual = contenidoLocal[1]
    jugOponente = contenidoLocal[2]

    while True:
        # Se revisan los archivos con el nombre al revés porque es para color negro
        time.sleep(1)
        try:
            contenidoNuevo = descargarArchivo(jugOponente, jugActual)
            if contenidoNuevo[0] == "0":
                modificarASMAPI(contenidoNuevo)
                print("-- Partida Sincronizada Con Exito")
                return
        except Exception as e:
            print(e)

# esto se ejecuta si el archivo empieza con 4 se coloca el archivo completo del historial en el txt
# el assembly se encarga de cargar de par en par los movimientos
def cuandoNumEs4():
    print("DETECTA 4")
    with open(ASM_API_FILE, 'r') as f:
        contenidoLocal = f.read()

    contenidoLocal = contenidoLocal.split()
    print(contenidoLocal)
    jugActual = contenidoLocal[1]
    jugOponente = contenidoLocal[2]

    try:
        contenidoEnNube = descargarArchivo(jugOponente, jugActual)
    except Exception as e:
        print(e)

    # Se sobreescribe el archivo ASM con todo el historial de la nube
    modificarASMAPI(f'{contenidoEnNube}')
    print("-- Esperando Respuesta de Turno Jugador")

# esto se ejecuta si el archivo empieza con 6
def cuandoNumEs6():
    print("-- Archivo Offline")

# si empieza con 7 se espera a que el archivo en la nube cambie, se colocan los cambios en el archivo de ASM
def cuandoNumEs7():
    print("DETECTA 7")
    
    while True:
        time.sleep(0.5)  # pausa entre lecturas
        print("Ciclando en 7: Esperando movida enemiga en nube")

        with open(ASM_API_FILE, 'r') as f:
            contenidoLocal = f.read()

        contenidoLocal = contenidoLocal.split()
        print(contenidoLocal)

        if contenidoLocal[1] == '1':   # Procesamiento para blancas
            jugActual = contenidoLocal[2]
            jugOponente = contenidoLocal[3]
        else:                           # Procesamiento para negras
            jugActual = contenidoLocal[3]
            jugOponente = contenidoLocal[2]

        try:
            contenidoEnNube = descargarArchivo(jugActual, jugOponente)
        except Exception as e:
            print(e)
            try:
                contenidoEnNube = descargarArchivo(jugOponente, jugActual)
            except Exception as e:
                print(e)

        print("Checking if changed:", f'{archivoEnNubeReferencia} : \n                      {contenidoEnNube}')
        if archivoEnNubeReferencia != contenidoEnNube:    
            print("Cloud: ", contenidoEnNube)
            print(f"comparison: {str(contenidoEnNube[0])} but has to be {str(colorOponente)}")
            if str(contenidoEnNube[0]) == str(colorOponente):
                print("- - recibido movimiento enemigo!")
                break

    contenidoEnNube = contenidoEnNube.split()
    print(contenidoEnNube)
    colorMovida = contenidoEnNube[0]
    piezaMovida = contenidoEnNube[-2]
    casillaDestino = contenidoEnNube[-1]
    
    nuevaEscritura = f'{colorMovida} {jugActual} {jugOponente} {piezaMovida} {casillaDestino}'

    # Se sobreescribe el archivo ASM para iniciar en 7 (Esperar nuevo movimiento)
    modificarASMAPI(nuevaEscritura)

# diccionario que conecta el primer carácter con la acción que debe hacer
actions = {
    '0': cuandoNumEs0,
    '1': cuandoNumEs1,
    '2': cuandoNumEs2,
    '3': cuandoNumEs3,
    '4': cuandoNumEs4,
    '6': cuandoNumEs6,
    '7': cuandoNumEs7
}

# esta función abre el archivo y ejecuta la acción correspondiente
def process_file():
    try:
        # abre el archivo y lee el primer carácter
        with open(ASM_API_FILE, 'r') as file:
            primerChar = file.read(1)  # lee solo el primer carácter
            # si el carácter tiene acción, la ejecuta
            if primerChar in actions:
                actions[primerChar]()
            else:
                print(f"No hay acción para el carácter: {primerChar}")
    except Exception as e:
        print(f"Error al leer el archivo: {e}")

# bucle infinito que lee el archivo cada cierto tiempo
def constant_loop(intervalo):
    while True:
        process_file()  # lee el archivo en cada ciclo
        time.sleep(intervalo)  # pausa entre lecturas (por default 1 segundo)


# correr el programa
with open(ASM_API_FILE, 'w') as f:
    f.write('6')

constant_loop(1) 

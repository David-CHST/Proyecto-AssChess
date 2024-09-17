from supabase import create_client, Client
import time

SUPABASE_URL = 'https://abtayeggwvptdvolqnki.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFidGF5ZWdnd3ZwdGR2b2xxbmtpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY0NTA3NzAsImV4cCI6MjA0MjAyNjc3MH0.sefl8kqy-ZiO2vaRT40c_5p0OW4uR24bbeynZtOg23s'  

# Initialize the Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

BUCKET_NAME = "chessBucket" 

def descargarArchivo(nombreBucket, nombreUno, nombreDos):
    try:
        # Comentado: Imprimir todos los archivos del bucket
        # files_list = supabase.storage.from_(BUCKET_NAME).list()
        # print(f"Files in bucket '{BUCKET_NAME}': {files_list}")

        # Descargar el archivo TXT
        respuesta = supabase.storage.from_(BUCKET_NAME).download(f'game-{nombreUno}-{nombreDos}')
        
        # Decodificar el archivo TXT e Imprimir sus Contenidos
        file_contents = respuesta.decode('utf-8')
        print(file_contents) 
    except Exception as e:
        print(f"Error descargando el archivo: \n {e}")

while True:
    descargarArchivo()
    time.sleep(2)


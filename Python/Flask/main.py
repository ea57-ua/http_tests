from flask import Flask,request
import json

app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    return "Hello world!\n"

@app.route('/p', methods=['GET', 'POST'])
def pagina1():
    if request.method == "GET":
        print("Hola desde el GET")
    if request.method == 'POST':
        data = json.dumps(request.form)
        print(f"Recibido el mensaje: {data}")
    return 'Estas en la página 1\n'

if __name__=='__main__':
    app.run(debug=True, host="127.0.0.1", port=8080) 
from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return "Hello world!\n"

@app.route('/pagina1')
def pagina1():
    return 'Estas en la página 1'

if __name__=='__main__':
    app.run(debug=True, host="127.0.0.1") # TODO change port (now 5000)
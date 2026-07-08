from machpoint import MachPoint

app = MachPoint()

@app.get("/")
def hello():
    return "Hello MachPoint"

@app.get("/ping")
def ping():
    return "pong"

@app.get("/hello")
def sayHello():
    return "Hello, World!"

if __name__ == "__main__":
    print("Starting MachPoint server...")
    app.start()
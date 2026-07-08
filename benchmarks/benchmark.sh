#!/bin/bash

# Benchmark tool selection menu
echo "Choose benchmarking tool:"
echo "1) autocannon (Node.js-based)"
echo "2) wrk (C-based, lower overhead)"
read -p "Enter choice (1 or 2): " TOOL_CHOICE

case $TOOL_CHOICE in
  1)
    TOOL="autocannon"
    npm install autocannon --save
    ;;
  2)
    TOOL="wrk"
    # Check if wrk is installed
    if ! command -v wrk &> /dev/null; then
      echo "wrk not found. Install it with: sudo apt-get install wrk (or brew install wrk on macOS)"
      exit 1
    fi
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

# Benchmark config
TIME=15     # duration of each test (seconds)
CONNECTIONS=100 # concurrent users
THREADS=4   # for wrk only
PORTS=(8001 8002 8003 8004 8005 8007)
NAMES=("FastAPI" "Starlette" "Sanic" "Tornado" "Flask" "MachPoint")
FILES=("fastapi_app.py" "starlette_app.py" "sanic_app.py" "tornado_app.py" "flask_app.py" "machpoint_app.py")

echo ""
echo "Benchmarking APIs for $TIME seconds with $CONNECTIONS connections using $TOOL..."
echo ""

for i in "${!NAMES[@]}"; do
  NAME=${NAMES[$i]}
  FILE=${FILES[$i]}
  PORT=${PORTS[$i]}

  echo
  echo "Running $NAME on port $PORT..."

    if [[ "$NAME" == "FastAPI" ]]; then
  uvicorn fastapi_app:app --port=$PORT > /dev/null 2>&1 &

    elif [[ "$NAME" == "Starlette" ]]; then
    uvicorn starlette_app:app --port=$PORT > /dev/null 2>&1 &

    elif [[ "$NAME" == "Sanic" ]]; then
    python3 "$FILE" > /dev/null 2>&1 &

    elif [[ "$NAME" == "Tornado" ]]; then
    python3 "$FILE" > /dev/null 2>&1 &

    elif [[ "$NAME" == "Flask" ]]; then
    gunicorn flask_app:app -b 0.0.0.0:$PORT --workers 4 > /dev/null 2>&1 &

    elif [[ "$NAME" == "MachPoint" ]]; then
    (cd .. && python3 -m benchmarks.machpoint_app) > /dev/null 2>&1 &

fi

  PID=$!
  sleep 10

  echo "⚡ Benchmarking $NAME..."
  
  if [ "$TOOL" = "autocannon" ]; then
    npx autocannon -c $CONNECTIONS -d $TIME http://localhost:$PORT/hello
  elif [ "$TOOL" = "wrk" ]; then
    wrk -t $THREADS -c $CONNECTIONS -d "${TIME}s" http://localhost:$PORT/hello
  fi

  echo "Stopping $NAME..."
  kill $PID
  wait $PID 2>/dev/null
done

echo
echo "All benchmarks complete!"
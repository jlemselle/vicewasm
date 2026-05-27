#!/bin/bash

# Script to serve the src folder and open x64.html in the browser

set -e

# Configuration
PORT=${1:-8000}
SRC_DIR="./src"

# Check if src directory exists
if [ ! -d "$SRC_DIR" ]; then
    echo "Error: $SRC_DIR directory not found"
    exit 1
fi

# Check if x64.html exists
if [ ! -f "$SRC_DIR/x64.html" ]; then
    echo "Error: x64.html not found in $SRC_DIR"
    exit 1
fi

echo "Starting HTTP server on port $PORT..."
echo "Serving from: $(cd $SRC_DIR && pwd)"

# Change to src directory and start HTTP server
cd "$SRC_DIR"

# Copy x64.html to index.html
echo "Copying x64.html to index.html..."
cp x64.html index.html

# Use Python's built-in HTTP server
python3 -m http.server $PORT &
SERVER_PID=$!

# Give the server a moment to start
sleep 1

# Open browser
echo "Opening browser to http://localhost:$PORT/..."
"$BROWSER" "http://localhost:$PORT/" 2>/dev/null || echo "Browser could not be opened automatically. Visit http://localhost:$PORT/ manually."

# Keep the server running
echo ""
echo "Server is running (PID: $SERVER_PID)"
echo "Press Ctrl+C to stop the server"

wait $SERVER_PID

#!/bin/bash

# Script to serve the src folder and open x64.html in the browser

set -e

# Configuration
PORT=${1:-8000}
SRC_DIR="./src"
PYTHON_BIN=${PYTHON_BIN:-python3}

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

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
    echo "Error: $PYTHON_BIN is required to run the HTTP server"
    exit 1
fi

# Serve with COOP/COEP headers required for Emscripten pthreads.
"$PYTHON_BIN" - "$PORT" <<'PY' &
import http.server
import sys

port = int(sys.argv[1])


class WasmPthreadsHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cross-Origin-Resource-Policy", "cross-origin")
        super().end_headers()

    def guess_type(self, path):
        if path.endswith(".wasm"):
            return "application/wasm"
        return super().guess_type(path)


http.server.ThreadingHTTPServer(("", port), WasmPthreadsHandler).serve_forever()
PY
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

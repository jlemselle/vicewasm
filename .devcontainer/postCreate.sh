#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y \
  build-essential \
  autoconf automake libtool pkg-config m4 \
  bison flex gperf texinfo \
  cmake ninja-build \
  python3 python3-pip \
  git git-lfs curl wget ca-certificates \
  dos2unix xa65

EMSDK_DIR="$HOME/emsdk"
EMSDK_VERSION="4.0.10"

if [[ ! -d "$EMSDK_DIR" ]]; then
  git clone https://github.com/emscripten-core/emsdk.git "$EMSDK_DIR"
fi

cd "$EMSDK_DIR"
git fetch --tags --prune
./emsdk install "$EMSDK_VERSION"
./emsdk activate "$EMSDK_VERSION"

# Ensure every new shell in the Codespace gets emsdk on PATH.
if ! grep -Fq 'source "$HOME/emsdk/emsdk_env.sh" >/dev/null 2>&1' "$HOME/.bashrc"; then
  echo 'source "$HOME/emsdk/emsdk_env.sh" >/dev/null 2>&1' >> "$HOME/.bashrc"
fi

# Apply for this run too.
# shellcheck disable=SC1090
source "$HOME/emsdk/emsdk_env.sh"

for tool in emcc em++ emconfigure emmake emar emnm emranlib; do
  command -v "$tool" >/dev/null
done

echo "Codespace setup complete: build prerequisites and Emscripten are installed."

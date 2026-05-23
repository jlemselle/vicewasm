set -e  # Exit on error
set -x  # Log commands being run (optional, remove for production)

./autogen.sh

# Clear any previous failed attempts
make distclean || echo "Already clean"

# Set these explicitly
export CC=emcc
export CXX=em++
export AR=emar
export NM=emnm
export RANLIB=emranlib

# emconfigure ./configure 
#     --host=wasm32-unknown-emscripten 
#     --enable-sdlui2 
#     --with-sdlsound 
#     --without-oss 
#     --without-alsa 
#     --without-pulse 
#     --disable-ffmpeg 
#     --disable-realdevice 
#     --disable-rs232 
#     CFLAGS="-O3 -s USE_SDL=2" 
#     LDFLAGS="-O3 -s USE_SDL=2 -s WASM=1 -s ALLOW_MEMORY_GROWTH=1"

emconfigure ./configure \
    --host=wasm32-unknown-emscripten \
    --enable-sdl2ui \
    --with-sdlsound \
    --with-fastsid \
    --without-resid \
    --without-residfp \
    --disable-cpuhistory \
    --disable-openmp \
    --disable-largefile \
    --disable-dependency-tracking \
    --without-alsa \
    --without-oss \
    --without-pulse \
    --without-portaudio \
    --without-libcurl \
    --without-x \
    --without-png \
    --without-flac \
    --without-mpg123 \
    --without-vorbis \
    --without-lame \
    --without-gif \
    --disable-realdevice \
    --disable-rs232 \
    --disable-html-docs \
    --disable-external-ffmpeg \
    --disable-ipv6 \
    CFLAGS="-O3 -s USE_SDL=2" 
    LDFLAGS="-O3 -s USE_SDL=2 -s WASM=1 -s ALLOW_MEMORY_GROWTH=1"

export NODE_OPTIONS="--max-old-space-size=8192"


emmake make -j$(nproc)

cd src

# emcc -o x64sc.html \
#     $(find . -name "*.o" | grep -vE "cbm2|c128|pet|plus4|vic20|c64dtv|scpu64|stubs|vsid|tools|resid-dtv|c1541.o|vicii/|viciidtv/|/c64cpu.o$|/c64mem.o$|/c64model.o$") \
#     -O2 \
#     -s USE_SDL=1 \
#     -s TOTAL_MEMORY=134217728 \
#     -s ALLOW_MEMORY_GROWTH=1 \
#     -s WARN_ON_UNDEFINED_SYMBOLS=1 \
#     -s EXPORTED_FUNCTIONS="['_main']" \
#     --shell-file x64sc_custom.html \
#     --embed-file ../data/C64@/usr/local/share/vice/C64

emcc -O2 -o x64sc.html \
    $(find . -name "*.o" | grep -vE "cbm2|c128|pet|plus4|vic20|c64dtv|scpu64|stubs|vsid|tools|resid-dtv|c1541.o|vicii/|viciidtv/|/c64cpu.o$|/c64mem.o$|/c64model.o$") \
    ./userport/userport_petscii_snespad.o \
    -s INITIAL_MEMORY=256MB \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s EXPORTED_FUNCTIONS="['_main', '_machine_trigger_reset']" \
    -s EXPORTED_RUNTIME_METHODS="['ccall', 'cwrap']" \
    -s USE_SDL=2 \
    -s USE_SDL_IMAGE=2 \
    -s USE_ZLIB=1 \
    -s USE_LIBPNG=1 \
    -s ASYNCIFY \
    -s ASSERTIONS=2 \
    --preload-file ../data/C64@/usr/local/share/vice/C64
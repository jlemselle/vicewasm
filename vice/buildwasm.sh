set -e  # Exit on error

if [ "${WASM_TRACE:-0}" = "1" ]; then
    set -x  # Log commands when explicitly requested
fi

"$HOME/emsdk/emsdk" activate
. "$HOME/emsdk/emsdk_env.sh"

if command -v nproc >/dev/null 2>&1; then
    make_jobs=$(nproc)
else
    make_jobs=$(sysctl -n hw.ncpu 2>/dev/null || echo 1)
fi

# Recursive autotools rechecks can race under parallel make in this tree.
# Use a stable default and allow explicit override when needed.
make_jobs=${WASM_MAKE_JOBS:-1}

if [ "${RUN_AUTOGEN:-0}" = "1" ]; then
    ./autogen.sh
fi

if [ ! -x ./configure ]; then
    ./autogen.sh
fi

# Clear any previous failed attempts when a prior configure/make exists.
if [ -f Makefile ]; then
    make distclean || echo "Already clean"
fi

# Set these explicitly
export CC=emcc
export CXX=em++
export AR=emar
export NM=emnm
export RANLIB=emranlib
export YACC='/usr/bin/bison -y'

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
    CFLAGS="-O3 -s USE_SDL=2" \
    LDFLAGS="-O3 -s USE_SDL=2 -s WASM=1 -s ALLOW_MEMORY_GROWTH=1" \
    SDL2_IMAGE_CFLAGS="-I$HOME/emsdk/upstream/emscripten/cache/sysroot/include/SDL2" \
    SDL2_IMAGE_LIBS="-s USE_SDL_IMAGE=2 -s USE_ZLIB=1 -s USE_LIBPNG=1"

export NODE_OPTIONS="--max-old-space-size=8192"


emmake make -j"$make_jobs"

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

emcc -O2 -o x64.html \
  alarm.o attach.o autostart.o autostart-prg.o cbmdos.o cbmimage.o charset.o clipboard.o cmdline.o color.o crc32.o crt.o debug.o dma.o event.o findpath.o fliplist.o gcr.o info.o init.o initcmdline.o interrupt.o kbdbuf.o keyboard.o keymap.o lib.o log.o machine-bus.o machine.o main.o mainlock.o m3u.o network.o opencbmlib.o palette.o profiler.o ram.o rawfile.o rawnet.o resources.o romset.o screenshot.o sha1.o snapshot.o socket.o sound.o sysfile.o traps.o util.o vicefeatures.o vsync.o zfile.o zipcode.o midi.o ../src/arch/shared/libarchdep.a ../src/tapeport/libtapeport.a ../src/c64/libc64.a ../src/c64/cart/libc64cartsystem.a ../src/c64/cart/libc64cart.a ../src/c64/cart/libc64commoncart.a ../src/datasette/libdatasette.a ../src/drive/iec/libdriveiec.a ../src/drive/iecieee/libdriveiecieee.a ../src/drive/iec/c64exp/libdriveiecc64exp.a ../src/drive/ieee/libdriveieee.a ../src/drive/libdrive.a ../src/drive/tcbm/libdrivetcbm.a ../src/iecbus/libiecbus.a ../src/lib/p64/libp64.a ../src/parallel/libparallel.a ../src/vdrive/libvdrive.a ../src/sid/libsid.a ../src/monitor/libmonitor.a ../src/joyport/libjoyport.a ../src/samplerdrv/libsamplerdrv.a ../src/arch/shared/sounddrv/libsounddrv.a ../src/arch/shared/mididrv/libmididrv.a ../src/arch/shared/socketdrv/libsocketdrv.a ../src/arch/shared/hwsiddrv/libhwsiddrv.a ../src/gfxoutputdrv/libgfxoutputdrv.a ../src/printerdrv/libprinterdrv.a ../src/diskimage/libdiskimage.a ../src/fsdevice/libfsdevice.a ../src/tape/libtape.a ../src/fileio/libfileio.a ../src/serial/libserial.a ../src/core/libcore.a   ../src/rs232drv/librs232drv.a ../src/vicii/libvicii.a ../src/raster/libraster.a ../src/userport/libuserport.a ../src/diag/libdiag.a ../src/core/rtc/librtc.a ../src/video/libvideo.a ../src/arch/sdl/libarch.a  ../src/imagecontents/libimagecontents.a ../src/c64/libc64stubs.a  ../src/hvsc/libhvsc.a ../src/arch/shared/hotkeys/libhotkeys.a ../src/lib/libzmbv/libzmbv.a -lz  ../src/arch/sdl/libarch.a ../src/arch/shared/libarchdep.a ../src/lib/linenoise-ng/liblinenoiseng.a \
  -s INITIAL_MEMORY=256MB \
  -s ALLOW_MEMORY_GROWTH=1 \
  -s EXPORTED_FUNCTIONS="[ \
    '_autostart_autodetect', \
    '_cmdline_options_string', \
    '_file_system_attach_disk', \
    '_file_system_detach_disk', \
    '_file_system_get_disk_name', \
    '_joystick_set_value_and', \
    '_joystick_set_value_or', \
    '_keyboard_key_pressed', \
    '_keyboard_key_released', \
    '_machine_trigger_reset', \
    '_main', \
    '_resources_set_int' \
  ]" \
  -s EXPORTED_RUNTIME_METHODS="['ccall', 'cwrap']" \
  -s USE_SDL=2 \
  -s USE_SDL_IMAGE=2 \
  -s USE_ZLIB=1 \
  -s USE_LIBPNG=1 \
  -s ASYNCIFY \
  --shell-file x64sc_custom.html \
  --preload-file ../data/C64@/usr/local/share/vice/C64 \
  --preload-file ../data/DRIVES@/usr/local/share/vice/DRIVES

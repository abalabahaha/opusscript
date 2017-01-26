OPUS_NATIVE_DIR=./opus-native

EMCC_OPTS=-O3 --llvm-lto 1 -s NO_FILESYSTEM=1 -s ALLOW_MEMORY_GROWTH=1 --memory-init-file 0 -s EXPORTED_RUNTIME_METHODS="['setValue', 'getValue']" -s EXPORTED_FUNCTIONS="['_malloc', '_opus_strerror', '_opus_encoder_create', '_opus_encoder_ctl', '_opus_encoder_destroy', '_opus_decoder_create', '_opus_decoder_ctl', '_opus_decoder_destroy']"

all: init compile
autogen:
	cd $(OPUS_NATIVE_DIR); \
	./autogen.sh
configure:
	cd $(OPUS_NATIVE_DIR); \
	emconfigure ./configure --disable-extra-programs --disable-doc --disable-intrinsics
bind:
	cd $(OPUS_NATIVE_DIR); \
	emmake make; \
	rm a.out; \
	rm a.out.js
init: autogen configure bind
compile:
	mkdir -p ./build; \
	em++ ${EMCC_OPTS} --bind src/opusscript_encoder.cpp ${OPUS_NATIVE_DIR}/.libs/libopus.a -o build/opusscript_native.js; \
    sed -i -e 's/process\["on"\]("uncaughtException",(function(ex){if(\!(ex instanceof ExitStatus)){throw ex}}));//g' build/opusscript_native.js; \
	cp -f opus-native/COPYING build/COPYING.libopus;

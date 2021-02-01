OPUS_NATIVE_DIR=./opus-native

EMCC_OPTS=-Wall -O3 --llvm-lto 3 -flto --closure 1 -s ALLOW_MEMORY_GROWTH=1 --memory-init-file 0 -s NO_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS="['setValue', 'getValue']" -s EXPORTED_FUNCTIONS="['_malloc', '_opus_strerror']" -s MODULARIZE=1

EMCC_NASM_OPTS=-s WASM=0 -s WASM_ASYNC_COMPILATION=0
EMCC_WASM_OPTS=-s WASM=1 -s WASM_ASYNC_COMPILATION=0 -s WASM_BIGINT

all: init compile
autogen:
	cd $(OPUS_NATIVE_DIR); \
	./autogen.sh
configure:
	cd $(OPUS_NATIVE_DIR); \
	emconfigure ./configure --disable-extra-programs --disable-doc --disable-intrinsics --disable-stack-protector
bind:
	cd $(OPUS_NATIVE_DIR); \
	emmake make; \
	rm -f a.wasm
init: autogen configure bind
compile:
	rm -rf ./build; \
	mkdir -p ./build; \
	em++ ${EMCC_OPTS} ${EMCC_NASM_OPTS} --bind -o build/opusscript_native_nasm.js src/opusscript_encoder.cpp ${OPUS_NATIVE_DIR}/.libs/libopus.a; \
	em++ ${EMCC_OPTS} ${EMCC_WASM_OPTS} --bind -o build/opusscript_native_wasm.js src/opusscript_encoder.cpp ${OPUS_NATIVE_DIR}/.libs/libopus.a; \
	sed -i'' -e 's/,process.on("uncaughtException",function([A-Za-z0-9]\+){throw [A-Za-z0-9]\+;}),process.on("unhandledRejection",[A-Za-z0-9]\+)//g' build/opusscript_native_nasm.js; \
	sed -i'' -e 's/,process.on("uncaughtException",function([A-Za-z0-9]\+){throw [A-Za-z0-9]\+;}),process.on("unhandledRejection",[A-Za-z0-9]\+)//g' build/opusscript_native_wasm.js; \
	cp -f opus-native/COPYING build/COPYING.libopus;

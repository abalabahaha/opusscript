#include <emscripten/bind.h>

#include "../opus-native/include/opus.h"

#define APPLICATION OPUS_APPLICATION_AUDIO
#define MAX_PACKET_SIZE 1276 * 3
#define MAX_FRAME_SIZE 960 * 6

using namespace emscripten;

class OpusScriptHandler {
    private:
        int application;
        int channels;
        opus_int32 sampling_rate;

        OpusEncoder* encoder;
        OpusDecoder* decoder;

        opus_int16* out_pcm;
    public:
        OpusScriptHandler(opus_int32 sampling_rate, int channels, int application):
            sampling_rate(sampling_rate), channels(channels), application(application) {

            out_pcm = new opus_int16[MAX_FRAME_SIZE * channels * 2];

            int encoder_error;
            encoder = opus_encoder_create(sampling_rate, channels, application, &encoder_error);
            if(encoder_error < 0) {
                throw encoder_error;
            }

            int decoder_error;
            decoder = opus_decoder_create(sampling_rate, channels, &decoder_error);
            if(decoder_error < 0) {
                throw decoder_error;
            }
        }

        ~OpusScriptHandler() {
            opus_encoder_destroy(encoder);
            opus_decoder_destroy(decoder);
        }

        int _encode(int input_buffer, int bytes, int output_buffer, int frame_size) {
            opus_int16* input = reinterpret_cast<opus_int16*>(input_buffer);
            unsigned char* output = reinterpret_cast<unsigned char*>(output_buffer);

            for(int i = 0; i < bytes; i++) {
                input[i] = input[2 * i + 1] << 8 | input[2 * i];
            }

            return opus_encode(encoder, input, frame_size, output, MAX_PACKET_SIZE);
        }

        int _decode(int input_buffer, int bytes, int output_buffer) {
            unsigned char* input = reinterpret_cast<unsigned char*>(input_buffer);
            short* pcm = reinterpret_cast<short*>(output_buffer);

            int len = opus_decode(decoder, input, bytes, out_pcm, MAX_FRAME_SIZE, 0);

            for(int i = 0; i < len * channels; i++) {
                pcm[2 * i] = out_pcm[i] & 0xFF;
                pcm[2 * i + 1] = (out_pcm[i] >> 8) & 0xFF;
            }

            return len;
        }
};

EMSCRIPTEN_BINDINGS(OpusScriptHandler) {
    class_<OpusScriptHandler>("OpusScriptHandler")
        .constructor<opus_int32, int, int>()
        .function("_encode", &OpusScriptHandler::_encode)
        .function("_decode", &OpusScriptHandler::_decode);
}
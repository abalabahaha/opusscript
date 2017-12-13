declare module 'opusscript' {
    enum OpusApplication {
        VOIP = 2048,
        AUDIO = 2049,
        RESTRICTED_LOWDELAY = 2051
    }
    enum OpusError {
        "OK" = 0,
        "Bad argument" = -1,
        "Buffer too small" = -2,
        "Internal error" = -3,
        "Invalid packet" = -4,
        "Unimplemented" = -5,
        "Invalid state" = -6,
        "Memory allocation fail" = -7
    }
    type VALID_SAMPLING_RATES = 8000 | 12000 | 16000 | 24000 | 48000;
    type MAX_FRAME_SIZE = 2880;
    type MAX_PACKET_SIZE = 3828;
    class OpusScript {
        static Application: typeof OpusApplication;
        static Error: typeof OpusError;
        static VALID_SAMPLING_RATES: [8000, 12000, 16000, 24000, 48000];
        static MAX_PACKET_SIZE: MAX_PACKET_SIZE;

        constructor(samplingRate: VALID_SAMPLING_RATES, channels?: number, application?: OpusApplication);
        encode(buffer: Buffer, frameSize: number): Buffer;
        decode(buffer: Buffer): Buffer;
        encoderCTL(ctl: any, arg: any): void;
        decoderCTL(ctl: any, arg: any): void;
        delete(): void;
    }
    export = OpusScript;
}

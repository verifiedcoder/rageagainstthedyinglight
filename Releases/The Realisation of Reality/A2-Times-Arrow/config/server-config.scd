// Server Configuration
// This file sets up audio server parameters

(
// Audio settings
s.options.sampleRate = 48000;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;
s.options.memSize = 131072;          // 128MB
s.options.maxNodes = 2048;
s.options.numAudioBusChannels = 512;
s.options.blockSize = 64;

// Recording settings
s.recHeaderFormat = "wav";
s.recSampleFormat = "int24";         // 24-bit

"Server configured: 48kHz, 24-bit, WAV format".postln;
"Ready for boot".postln;
)
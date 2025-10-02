// Melodic Synthesis SynthDefs
"Loading melodic synths...".postln;

SynthDef(\bpfsaw, {
    arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
        freq=500, detune=0.2, pan=0,
        cfhzmin=0.1, cfhzmax=0.3, cfmin=500, cfmax=2000,
        rqmin=0.1, rqmax=0.2, lsf=200, ldb=0,
        amp=1, out=0;
    var sig, env;
    env = EnvGen.kr(Env([0,1,1,0], [atk,sus,rel], [c1, 0, c2]), doneAction:2);
    sig = Saw.ar(freq * LFNoise1.kr(0.5, detune).midiratio ! 2);
    sig = BPF.ar(
        sig,
        LFNoise1.kr(LFNoise1.kr(4).exprange(cfhzmin, cfhzmax)).exprange(cfmin, cfmax) ! 2,
        LFNoise1.kr(0.1).exprange(rqmin, rqmax) ! 2
    );
    sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
    sig = Balance2.ar(sig[0], sig[1], pan);
    sig = sig * env * amp;
    Out.ar(out, sig);
}).add;

// Buffer playback synth for mono samples
SynthDef(\rbuf, {
    arg buf=0, rate=1, pan=0, amp=1, out=0;
    var sig;
    // Play mono buffer with automatic cleanup when done
    sig = PlayBuf.ar(1, buf, rate*BufRateScale.ir(buf), doneAction:2);
    sig = Pan2.ar(sig, pan) * amp;
    Out.ar(out, sig);
}).add;

// Buffer playback synth for stereo samples
SynthDef(\rbuf2, {
    arg buf=0, rate=1, pan=0, amp=1, out=0;
    var sig;
    // Play stereo buffer with automatic cleanup when done
    sig = PlayBuf.ar(2, buf, rate*BufRateScale.ir(buf), doneAction:2);
    sig = Balance2.ar(sig[0], sig[1], pan) * amp;
    Out.ar(out, sig);
}).add;

// Smooth gliding pad synth with warm analog character
SynthDef(\glidePad, {
    arg freq=440, amp=0.1, gate=1,
        detune=0.01, glideTime=0.8,
        cfmin=400, cfmax=1200, cfhz=0.1,
        atk=4, rel=6, out=0;
    var sig, env, smoothFreq, filterFreq;

    // Smooth frequency glides
    smoothFreq = Lag.kr(freq, glideTime);

    // 5 detuned sawtooth oscillators for thick analog sound
    sig = Mix.fill(5, {|i|
        Saw.ar(
            smoothFreq * (1 + LFNoise1.kr(0.1 + (i*0.03)).range(detune.neg, detune)),
            0.2
        )
    });

    // Slow evolving filter
    filterFreq = LFNoise1.kr(cfhz).exprange(cfmin, cfmax);
    sig = RLPF.ar(sig, filterFreq, 0.7);

    // Long envelope for pad sustain
    env = EnvGen.kr(Env.asr(atk, 1, rel, \sine), gate, doneAction: 2);

    // Subtle stereo movement
    sig = Pan2.ar(sig, LFNoise1.kr(0.2).range(-0.3, 0.3));

    Out.ar(out, sig * env * amp);
}).add;

// Deep bass synth with sub-oscillator and Moog-style filtering
SynthDef(\deepBass, {
    arg freq=50, amp=0.5, gate=1,
        subLevel=0.35,       // Sub-oscillator mix (0-1)
        cutoff=500,          // Filter cutoff frequency
        resonance=0.5,       // Filter resonance (0-4, sweet spot 0.3-0.8)
        drive=1.8,           // Saturation/drive amount (1.0-3.0)
        atk=3, rel=4,
        out=0;
    var main, sub, mixed, filtered, env, filterEnv, cutoffMod;

    // Main oscillator: Blended Saw (60%) + Square (40%) for harmonic richness
    main = (Saw.ar(freq) * 0.6) + (Pulse.ar(freq, 0.5) * 0.4);

    // Sub-oscillator: Pure sine wave, one octave down for deep foundation
    sub = SinOsc.ar(freq * 0.5);

    // Mix oscillators (main + sub)
    mixed = (main * (1 - subLevel)) + (sub * subLevel);

    // Filter envelope - opens filter over attack, closes during release
    filterEnv = EnvGen.kr(Env.asr(atk * 0.7, 1, rel * 0.5));

    // Modulate cutoff with envelope (starts at cutoff, opens to cutoff*3)
    cutoffMod = cutoff * (1 + (filterEnv * 2));

    // MoogFF: Moog-style ladder filter for warm analog character and punch
    filtered = MoogFF.ar(
        mixed,
        cutoffMod.clip(20, 12000),    // Envelope-modulated cutoff
        resonance.clip(0, 4)           // Resonance adds punch and character
    );

    // Saturation/drive using tanh for warm harmonic distortion
    filtered = (filtered * drive).tanh;

    // Main amplitude envelope
    env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction: 2);

    // Stereo output with slight width from phase-shifted copies
    Out.ar(out, Pan2.ar(filtered, 0) * env * amp);
}).add;

"Melodic synths loaded".postln;
// Drum Synthesis SynthDefs
"Loading drum synths...".postln;

SynthDef(\synthKick, {
    arg out=0, amp=0.5, pan=0;
    var sig, env;
    env = EnvGen.kr(Env.perc(0.001, 0.5, 1, -4), doneAction:2);
    sig = SinOsc.ar(XLine.kr(120, 30, 0.1)) * env;
    sig = (sig + (WhiteNoise.ar(0.05) * EnvGen.kr(Env.perc(0.001, 0.01))));
    sig = sig.tanh * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\synthSnare, {
    arg out=0, amp=0.5, pan=0;
    var sig, env, noise, tone;
    env = EnvGen.kr(Env.perc(0.001, 0.15, 1, -3), doneAction:2);
    noise = WhiteNoise.ar * env * 0.4;
    tone = SinOsc.ar(200) * env * 0.6;
    sig = (noise + tone) * amp;
    sig = HPF.ar(sig, 200);
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\synthHat, {
    arg out=0, amp=0.5, pan=0, rel=0.1;
    var sig, env;
    env = EnvGen.kr(Env.perc(0.001, rel, 1, -4), doneAction:2);
    sig = WhiteNoise.ar * env * amp;
    sig = HPF.ar(sig, 4000);
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\synthClap, {
    arg out=0, amp=0.5, pan=0;
    var sig, env, envs;
    envs = EnvGen.kr(Env([0,1,0,1,0,1,0], [0.001,0.009,0.001,0.008,0.001,0.04], -4), doneAction:2);
    sig = WhiteNoise.ar * envs * amp;
    sig = BPF.ar(sig, 1200, 0.3);
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\synthPerc, {
    arg out=0, amp=0.5, pan=0, freq=300;
    var sig, env;
    env = EnvGen.kr(Env.perc(0.001, 0.1, 1, -6), doneAction:2);
    sig = SinOsc.ar(freq * [1, 1.51, 2.13]) * env;
    sig = Mix.ar(sig) * 0.3 * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\synthFx, {
    arg out=0, amp=0.5, pan=0;
    var sig, env;
    env = EnvGen.kr(Env.linen(0.2, 0.6, 0.2), doneAction:2);
    sig = SinOsc.ar(XLine.kr(2000, 100, 1)) * env * amp;
    sig = sig + (Resonz.ar(WhiteNoise.ar(0.1), XLine.kr(8000, 800, 1), 0.05) * env);
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

"Drum synths loaded".postln;
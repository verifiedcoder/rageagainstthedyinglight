// FX
"Loading FX patterns...".postln;

Pdef(\fx, Pbind(
    \dur, Prand([Rest(8), Rest(12), Rest(16), 1, Rest(10), Rest(6)], inf),
    \bufInfo, Pfunc({ ~fxSounds.choose }),
    \instrument, Pfunc({ |e| if(e.bufInfo[1] == 2, \rbuf2, \rbuf) }),
    \buf, Pfunc({ |e| e.bufInfo[0] }),
    \rate, Pwhite(0.8, 1.2),
    \amp, 0.4,
    \pan, Pwhite(-0.3, 0.3),
    \out, ~masterBus
));

"FX patterns loaded".postln;
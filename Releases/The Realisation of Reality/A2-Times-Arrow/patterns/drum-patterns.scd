// Drum Patterns
"Loading drum patterns...".postln;

// Kick
Pdef(\kick, Pbind(
    \dur, Pseq([1, 1, 0.5, 0.5, 1], inf),
    \bufInfo, Pfunc({ ~kicks.choose }),
    \instrument, Pfunc({ |e| if(e.bufInfo[1] == 2, \rbuf2, \rbuf) }),
    \buf, Pfunc({ |e| e.bufInfo[0] }),
    \rate, Pwhite(0.98, 1.02),
    \amp, 0.5,
    \pan, Prand([-0.2, 0, 0.2], inf),
    \out, ~masterBus
));

// Snare
Pdef(\snare, Pbind(
    \dur, Pseq([Rest(1), 1, Rest(0.5), 0.5, Rest(1), 1], inf),
    \bufInfo, Pfunc({ ~snares.choose }),
    \instrument, Pfunc({ |e| if(e.bufInfo[1] == 2, \rbuf2, \rbuf) }),
    \buf, Pfunc({ |e| e.bufInfo[0] }),
    \rate, Pwhite(0.95, 1.05),
    \amp, 0.4,
    \pan, Prand([-0.3, 0.3], inf),
    \out, ~masterBus
));

// Closed hi-hat
Pdef(\hat, Pbind(
    \dur, Pseq([0.5, 0.5, 0.5, 0.5], inf),
    \bufInfo, Pfunc({ ~closedHats.choose }),
    \instrument, Pfunc({ |e| if(e.bufInfo[1] == 2, \rbuf2, \rbuf) }),
    \buf, Pfunc({ |e| e.bufInfo[0] }),
    \rate, Pwhite(0.98, 1.02),
    \amp, 0.25,
    \pan, Pwhite(-0.4, 0.4),
    \out, ~masterBus
));

// Open hi-hat
Pdef(\openHat, Pbind(
    \dur, Pseq([Rest(1), 1, Rest(1), 1, Rest(1), 1, Rest(1), 1], inf),
    \bufInfo, Pfunc({ ~openHats.choose }),
    \instrument, Pfunc({ |e| if(e.bufInfo[1] == 2, \rbuf2, \rbuf) }),
    \buf, Pfunc({ |e| e.bufInfo[0] }),
    \rate, Pwhite(0.97, 1.03),
    \amp, 0.2,
    \pan, Pwhite(-0.6, 0.6),
    \out, ~masterBus
));

// Clap
Pdef(\clap, Pbind(
    \dur, Pseq([Rest(2), 2, Rest(2), 2], inf),
    \bufInfo, Pfunc({ ~claps.choose }),
    \instrument, Pfunc({ |e| if(e.bufInfo[1] == 2, \rbuf2, \rbuf) }),
    \buf, Pfunc({ |e| e.bufInfo[0] }),
    \rate, Pwhite(0.98, 1.02),
    \amp, 0.3,
    \pan, Prand([-0.2, 0.2], inf),
    \out, ~masterBus
));

// Percussion
Pdef(\perc, Pbind(
    \dur, Prand([Rest(1), 0.25, Rest(2), 0.5, Rest(1.5), 0.75], inf),
    \bufInfo, Pfunc({ ~percs.choose }),
    \instrument, Pfunc({ |e| if(e.bufInfo[1] == 2, \rbuf2, \rbuf) }),
    \buf, Pfunc({ |e| e.bufInfo[0] }),
    \rate, Pwhite(0.9, 1.1),
    \amp, 0.2,
    \pan, Pwhite(-0.8, 0.8),
    \out, ~masterBus
));

"Drum patterns loaded".postln;
// Audio Effects SynthDefs
"Loading effects...".postln;

SynthDef(\masterLimiter, {
    arg in=0, out=0, amp=0.7, thresh=0.95, lookahead=0.01;
    var sig = In.ar(in, 2);
    sig = Limiter.ar(sig, thresh, lookahead) * amp;
    Out.ar(out, sig);
}).add;

"Effects loaded".postln;
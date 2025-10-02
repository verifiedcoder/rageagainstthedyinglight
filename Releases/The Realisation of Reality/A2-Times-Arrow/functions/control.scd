// Pattern Control Functions
"Loading control functions...".postln;

~startPattern = { |key|
    if(key.isNil) {
        // Don't quantise Ptpar - it has its own internal timing
        Pdef(\composition).play;
        "Started composition".postln;
    } {
        Pdef(key).play(quant: 1);
        "Started %".format(key).postln;
    };
};

~stopPattern = { |key|
    if(key.isNil) {
        Pdef.all.do(_.stop);
        "Stopped all".postln;
    } {
        Pdef(key).stop;
        "Stopped %".format(key).postln;
    };
};

~cleanup = {
    ~stopPattern.();
    if(~limiter.notNil) { ~limiter.free };
    s.freeAll;
    Pdef.clear;
    "Cleanup complete".postln;
};

// Play only pads
~playPads = {
    ~stopPattern.();
    Pdef(\pad).play(quant: 1);
    "Playing pads only".postln;
};

// Play only lead
~playLead = {
    ~stopPattern.();
    Pdef(\lead).play(quant: 1);
    "Playing lead only".postln;
};

// Play pads + lead together
~playPadsLead = {
    ~stopPattern.();
    Pdef(\pad).play(quant: 1);
    Pdef(\lead).play(quant: 1);
    "Playing pads + lead".postln;
};

// Play pads + bass
~playPadsBass = {
    ~stopPattern.();
    Pdef(\pad).play(quant: 1);
    Pdef(\bass).play(quant: 1);
    "Playing pads + bass".postln;
};

"Control functions loaded".postln;
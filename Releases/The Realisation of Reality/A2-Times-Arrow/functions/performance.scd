// Performance Macros
"Loading performance macros...".postln;

// DROP - remove everything except bass
~drop = {
    // Stop the main composition if it's running
    Pdef(\composition).stop;

    // Stop all individual patterns except bass
    [\kick, \snare, \hat, \openHat, \clap, \perc, \lead, \pad, \fx].do { |key|
        Pdef(key).stop;
    };

    // Start bass if not already playing
    Pdef(\bass).play(quant: 1);

    ">>> DROP <<<".postln;
};

// Gradually add elements back
~build = {
    fork {
        ">>> BUILD <<<".postln;
        Pdef(\kick).play(quant: 1);
        4.wait;
        Pdef(\hat).play(quant: 1);
        4.wait;
        Pdef(\snare).play(quant: 1);
        4.wait;
        Pdef(\clap).play(quant: 1);
        4.wait;
        Pdef(\lead).play(quant: 1);
        4.wait;
        Pdef(\pad).play(quant: 1);
    };
};

"Performance macros loaded".postln;
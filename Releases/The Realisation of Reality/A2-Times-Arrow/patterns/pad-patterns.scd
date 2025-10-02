// Pad
"Loading pad patterns...".postln;

// 5 independent voices with staggered evolution rates
// Voice 1: 8 beats, Voice 2: 6 beats, Voice 3: 5 beats, Voice 4: 4 beats, Voice 5: 3 beats
// LCM(8,6,5,4,3) = 120 beats for full cycle

// Voice motion sequences - each follows voice leading principles
~voice1Sequence = Pseq([
    // Start: scale degree 0 (root)
    0, 0, 2, 2, 4, 4, 2, 0,  // Moves up through triad and back
    0, -2, 0, 2, 4, 5, 4, 2  // Explores below and above
], inf).asStream;

~voice2Sequence = Pseq([
    // Start: scale degree 2 (third)
    2, 4, 5, 4, 2, 0, 2, 4,  // Stepwise motion, common tone with voice 1
    5, 7, 5, 4, 2, 4, 5, 7   // Higher exploration
], inf).asStream;

~voice3Sequence = Pseq([
    // Start: scale degree 4 (fifth)
    4, 5, 7, 5, 4, 2, 4, 5,  // Contrary motion to voice 1
    7, 9, 7, 5, 4, 5, 7, 9   // Wider intervals
], inf).asStream;

~voice4Sequence = Pseq([
    // Start: scale degree 7 (octave)
    7, 9, 7, 5, 7, 9, 11, 9,  // Upper register movement
    7, 5, 7, 9, 11, 12, 11, 9 // Climbs to high register
], inf).asStream;

~voice5Sequence = Pseq([
    // Start: scale degree 9 (ninth)
    9, 11, 9, 7, 9, 11, 12, 11,  // High atmospheric layer
    9, 7, 9, 11, 12, 14, 12, 11  // Floats above other voices
], inf).asStream;

Pdef(\pad,
    Ppar([
        // Voice 1: Lowest voice, changes every 8 beats
        Pmono(\glidePad,
            \degree, Pfunc({
                var deg = ~voice1Sequence.next;
                ~voicePositions[0] = deg;  // Update global tracking
                deg;
            }),
            \midinote, Pfunc({|e| ~scale.at(e.degree + ~middleOfScale - 7) }),  // Low octave
            \dur, 8,
            \glideTime, 1.0,  // 1 second glide
            \detune, 0.008,
            \cfmin, 200,
            \cfmax, 600,
            \cfhz, 0.05,
            \atk, 4,
            \rel, 6,
            \amp, 0.26,
            \out, ~masterBus
        ),

        // Voice 2: Changes every 6 beats
        Pmono(\glidePad,
            \degree, Pfunc({
                var deg = ~voice2Sequence.next;
                ~voicePositions[1] = deg;
                deg;
            }),
            \midinote, Pfunc({|e| ~scale.at(e.degree + ~middleOfScale - 3) }),  // Mid-low
            \dur, 6,
            \glideTime, 0.8,
            \detune, 0.01,
            \cfmin, 300,
            \cfmax, 800,
            \cfhz, 0.08,
            \atk, 3.5,
            \rel, 5,
            \amp, 0.22,
            \out, ~masterBus
        ),

        // Voice 3: Changes every 5 beats
        Pmono(\glidePad,
            \degree, Pfunc({
                var deg = ~voice3Sequence.next;
                ~voicePositions[2] = deg;
                // Update current pad notes for lead reference
                ~currentPadNotes = [~voicePositions[0], ~voicePositions[1], ~voicePositions[2]];
                deg;
            }),
            \midinote, Pfunc({|e| ~scale.at(e.degree + ~middleOfScale) }),  // Middle voice
            \dur, 5,
            \glideTime, 0.7,
            \detune, 0.012,
            \cfmin, 400,
            \cfmax, 1000,
            \cfhz, 0.1,
            \atk, 3,
            \rel, 4.5,
            \amp, 0.20,
            \out, ~masterBus
        ),

        // Voice 4: Changes every 4 beats
        Pmono(\glidePad,
            \degree, Pfunc({
                var deg = ~voice4Sequence.next;
                ~voicePositions[3] = deg;
                deg;
            }),
            \midinote, Pfunc({|e| ~scale.at(e.degree + ~middleOfScale + 3) }),  // Mid-high
            \dur, 4,
            \glideTime, 0.6,
            \detune, 0.015,
            \cfmin, 500,
            \cfmax, 1200,
            \cfhz, 0.12,
            \atk, 2.5,
            \rel, 4,
            \amp, 0.17,
            \out, ~masterBus
        ),

        // Voice 5: Changes every 3 beats (fastest evolution)
        Pmono(\glidePad,
            \degree, Pfunc({
                var deg = ~voice5Sequence.next;
                ~voicePositions[4] = deg;
                deg;
            }),
            \midinote, Pfunc({|e| ~scale.at(e.degree + ~middleOfScale + 7) }),  // High octave
            \dur, 3,
            \glideTime, 0.5,
            \detune, 0.018,
            \cfmin, 600,
            \cfmax, 1500,
            \cfhz, 0.15,
            \atk, 2,
            \rel, 3.5,
            \amp, 0.15,
            \out, ~masterBus
        ),
    ])
);

"Pad patterns loaded - 5 independent polyrhythmic voices (8,6,5,4,3 beat cycles)".postln;
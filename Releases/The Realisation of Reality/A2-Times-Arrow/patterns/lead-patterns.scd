// Lead
"Loading lead patterns...".postln;

// Initialise
~currentLeadNote = 21;  // Start higher in scale (was 14)

// Weighted random decision maker
~leadEvolution = Pfunc({
    var action, newNote, padNotes, consonantNotes, safePadNotes;

    // Safely get current pad chord tones
    // Use default [0,2,4] if not set
    safePadNotes = ~currentPadNotes ? [0,2,4];
    padNotes = safePadNotes.collect({|deg| deg + ~middleOfScale});

    // Add octave extensions and nearby scale degrees for consonance
    consonantNotes = padNotes ++ (padNotes + 7) ++ (padNotes - 7) ++
                     (padNotes + 2) ++ (padNotes - 2);

    // Probabilistic action selection:
    // 40% sustain, 30% step, 20% chord leap, 10% register jump
    action = [0,0,0,0, 1,1,1, 2,2, 3].choose;

    newNote = case
        // Action 0: Sustain current note (40% probability)
        {action == 0} {
            ~currentLeadNote;
        }

        // Action 1: Stepwise motion (30% probability)
        {action == 1} {
            var step = [-2, -1, 1, 2].choose;  // Small intervals
            (~currentLeadNote + step).clip(~middleOfScale + 7, ~middleOfScale + 28);  // Higher range
        }

        // Action 2: Leap to consonant note (20% probability)
        {action == 2} {
            // Choose from current pad chord tones, transposed up an octave
            (consonantNotes.choose + 7).clip(~middleOfScale + 7, ~middleOfScale + 28);
        }

        // Action 3: Register jump (10% probability)
        {action == 3} {
            var jump = [-7, 7, 12].choose;  // Fifth or octave, mostly upward
            (~currentLeadNote + jump).clip(~middleOfScale + 7, ~middleOfScale + 28);
        };

    ~currentLeadNote = newNote;  // Update state
    newNote;
});

// Evolving timbral presets - brighter, more present
~leadTimbreIndex = 0;
~leadTimbrePresets = [
    // Preset 0: Bright and cutting
    [\detune, 0.003, \cfmin, 1500, \cfmax, 3500, \cfhz, 0.4],
    // Preset 1: Clear and articulate
    [\detune, 0.005, \cfmin, 1200, \cfmax, 3000, \cfhz, 0.3],
    // Preset 2: Wide and prominent
    [\detune, 0.008, \cfmin, 1400, \cfmax, 3200, \cfhz, 0.5],
    // Preset 3: Piercing and focused
    [\detune, 0.002, \cfmin, 1800, \cfmax, 3800, \cfhz, 0.35],
    // Preset 4: Shimmering
    [\detune, 0.01, \cfmin, 1600, \cfmax, 4000, \cfhz, 0.45]
];

Pdef(\lead,
    Pbind(
        \instrument, \glidePad,
        \degree, ~leadEvolution,
        \midinote, Pfunc({|e| ~scale.at(e.degree) }),
        \dur, Pwrand(
            [3/4, 1, 5/4, 2, 3],      // Creates cross-rhythms with pad voices
            [0.3, 0.25, 0.2, 0.15, 0.1],  // Weighted toward shorter values
            inf
        ),

        // Evolving timbre parameters
        \detune, Pfunc({
            var preset = ~leadTimbrePresets.wrapAt(~leadTimbreIndex.div(16));
            preset[1];
        }),
        \cfmin, Pfunc({
            var preset = ~leadTimbrePresets.wrapAt(~leadTimbreIndex.div(16));
            preset[3];
        }),
        \cfmax, Pfunc({
            var preset = ~leadTimbrePresets.wrapAt(~leadTimbreIndex.div(16));
            preset[5];
        }),
        \cfhz, Pfunc({
            var preset = ~leadTimbrePresets.wrapAt(~leadTimbreIndex.div(16));
            ~leadTimbreIndex = ~leadTimbreIndex + 1;  // Increment counter
            preset[7];
        }),

        \glideTime, Prand([0.2, 0.4, 0.6], inf),  // Shorter glides for clarity
        \atk, Prand([0.05, 0.1, 0.2], inf),  // Faster attacks for definition
        \rel, Prand([0.8, 1.2, 1.8], inf),
        \legato, 1.1,  // Slight overlap between notes for smooth flow
        \amp, Pwhite(0.28, 0.38),  // Significantly louder (was 0.15-0.22)
        \out, ~masterBus
    )
);

"Lead patterns loaded - probabilistic generative melody with harmonic awareness".postln;
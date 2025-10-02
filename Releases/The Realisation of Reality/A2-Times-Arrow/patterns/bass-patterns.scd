// Bass Patterns - Two-Phase Harmonic System
"Loading bass patterns...".postln;

// Phase 1 (bars 0-56): Simple pedal/oscillation for foundation
// Phase 2 (bars 56+): Follows lowest pad voice for harmonic support

// Timing constants
~padEnterBar = 56;
~beatsAtPadEntry = ~padEnterBar * ~beatsPerBar;  // 224 beats

Pdef(\bass, Pbind(
    \instrument, \bpfsaw,

    // Duration: longer notes throughout
    \dur, Pfunc({
        var currentBeat = thisThread.beats;
        if(currentBeat < ~beatsAtPadEntry, {
            // Phase 1: Longer pedal tones (16 beats = 4 bars)
            16;
        }, {
            // Phase 2: Follow pads with sustained notes (8 beats = 2 bars)
            8;
        });
    }),

    // Degree selection: changes based on phase
    \degree, Pfunc({
        var currentBeat = thisThread.beats;
        var degree;

        if(currentBeat < ~beatsAtPadEntry, {
            // Phase 1: Simple two-note oscillation (tonic and dominant)
            // Alternates between scale degree 0 (root) and 4 (dominant)
            degree = if((currentBeat / 16).asInteger.even, { 0 }, { 4 });
        }, {
            // Phase 2: Follow lowest pad voice
            // Use voice 1 position from pads, transposed down for bass register
            degree = ~voicePositions[0];  // Lowest pad voice
        });

        // Update global root for other instruments to reference
        ~currentRoot = degree;

        degree;
    }),

    // MIDI note: bass register (down 12-24 semitones from scale position)
    \midinote, Pfunc({|e|
        var currentBeat = thisThread.beats;
        if(currentBeat < ~beatsAtPadEntry, {
            // Phase 1: Deep bass register
            ~scale.at(e.degree) - 24;
        }, {
            // Phase 2: Follow pads but in bass octave
            ~scale.at(e.degree + ~middleOfScale - 7) - 12;
        });
    }),

    \detune, 0.015,
    \cfmin, 40,
    \cfmax, 300,
    \rqmin, 0.8,
    \rqmax, 1.2,
    \lsf, 150,
    \ldb, 10,
    \cfhzmin, 0.02,
    \cfhzmax, 0.08,

    // Envelope: smooth, sustained
    \atk, 3,      // Long attack for smooth entry
    \sus, Pfunc({|e| e.dur - 5 }),  // Sustain most of the duration
    \rel, 4,      // Long release for smooth decay

    \amp, 0.35,   // Consistent volume
    \pan, 0,
    \out, ~masterBus
));

"Bass patterns loaded".postln;
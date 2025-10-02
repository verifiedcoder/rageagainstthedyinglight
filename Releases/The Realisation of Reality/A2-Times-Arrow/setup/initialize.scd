// Global Initialisation
"Initializing composition...".postln;

// Create master bus
~masterBus = Bus.audio(s, 2);

// ============ GLOBAL COMPOSITION SETTINGS ============
// All timing calculations derive from these values
~tempo = 130;                    // BPM (beats per minute)
~beatsPerBar = 4;                // Time signature (4/4 time)
~barsPerSection = 8;             // Each section is 8 bars
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath+/+ "..";
~projectRoot = PathName(~projectRoot).fullPath;  // Resolve to absolute path
~recordingsPath = ~projectRoot +/+ "recordings/";
~stemsPath = ~recordingsPath +/+ "stems/";

("Project root: " ++ ~projectRoot).postln;

// Create folders if needed
if(File.exists(~recordingsPath).not) {
    File.mkdir(~recordingsPath);
    ("Created recordings folder: " ++ ~recordingsPath).postln;
};
if(File.exists(~stemsPath).not) {
    File.mkdir(~stemsPath);
    ("Created stems folder: " ++ ~stemsPath).postln;
};

// Derived timing calculations (DO NOT EDIT)
TempoClock.default.tempo = ~tempo / 60;  // Convert to beats per second
~beatsPerSecond = ~tempo / 60.0;         // 2.167 beats/sec at 130 BPM
~secondsPerBeat = 60.0 / ~tempo;         // 0.462 seconds per beat at 130 BPM
~secondsPerBar = ~secondsPerBeat * ~beatsPerBar;  // 1.846 seconds per bar
~beatsPerSection = ~beatsPerBar * ~barsPerSection;  // 32 beats per section

("Tempo: " ++ ~tempo ++ " BPM").postln;
("Time signature: " ++ ~beatsPerBar ++ "/4").postln;
("Seconds per bar: " ++ ~secondsPerBar.round(0.01) ++ "s").postln;
("Beats per section: " ++ ~beatsPerSection ++ " beats (" ++ ~barsPerSection ++ " bars)").postln;

// Generate scale
~scaleType = Scale.minor;
~key = 0;
~rootNote = 60;
~scale = ~scaleType.degrees + ~rootNote;
~scale = (~scale - 24) ++ (~scale - 12) ++ ~scale ++ (~scale + 12) ++ (~scale + 24);
~middleOfScale = 14;

// Global harmonic coordination variables
~currentRoot = 0;              // Current bass root (scale degree)
~currentPadNotes = [0,2,4];    // Current pad chord tones (for lead reference)
~voicePositions = [0,2,4,7,9]; // 5 pad voice positions (scale degrees)

// COMPOSITION STRUCTURE
// Format: [section_number, pattern_name, display_name]
// Each section = 8 bars = 32 beats at 4/4 time
~compositionStructure = [
    [0, \bass, "Bass"],          // Section 0 = Bar 0
    [1, \kick, "Kick"],          // Section 1 = Bar 8
    [2, \snare, "Snare"],        // Section 2 = Bar 16
    [3, \hat, "Hi-hats"],        // Section 3 = Bar 24
    [4, \clap, "Claps"],         // Section 4 = Bar 32
    [5, \openHat, "Open hats"],  // Section 5 = Bar 40
    [6, \perc, "Percussion"],    // Section 6 = Bar 48
    [7, \pad, "Pad"],            // Section 7 = Bar 56
    [8, \lead, "Lead"],          // Section 8 = Bar 64
    [9, \fx, "FX"]               // Section 9 = Bar 72
];

// Calculate beat offsets from section numbers
~getBeatsFromSection = { |section|
    section * ~beatsPerSection;
};

// Calculate seconds from section number
~getSecondsFromSection = { |section|
    section * ~beatsPerSection * ~secondsPerBeat;
};

// Build Ptpar array from structure (converts sections to beats)
~buildPtparArray = {
    ~compositionStructure.collect({|entry|
        var section = entry[0];
        var beats = ~getBeatsFromSection.(section);
        [beats, Pdef(entry[1])]
    }).flatten;
};

// Define composition structure using single source of truth
Pdef(\composition,
    Ptpar(~buildPtparArray.())
);

// Start master limiter
~limiter = Synth.tail(s, \masterLimiter, [\in, ~masterBus, \out, 0, \amp, 0.8]);

"Initialization complete".postln;
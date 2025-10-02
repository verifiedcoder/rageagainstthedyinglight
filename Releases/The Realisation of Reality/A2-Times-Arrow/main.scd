//================== TIME'S ARROW ==================
// Main entry point
// Boot this block to load everything

(
// Load server configuration
"Loading server configuration...".postln;
"config/server-config.scd".loadRelative;

// Boot server and load composition
s.waitForBoot {
    fork {
        // Stop any existing patterns first
        Pdef.all.do(_.stop);
        "Stopped any existing patterns".postln;

        "".postln;
		"=== LOADING TIME'S ARROW ===".postln;
        "".postln;

        // 1. Load SynthDefs
        "Loading SynthDefs...".postln;
        "synthdefs/drum-synths.scd".loadRelative;
        0.2.wait;
        "synthdefs/melodic-synths.scd".loadRelative;
        0.2.wait;
        "synthdefs/effects.scd".loadRelative;
        0.5.wait;

        // 2. Load audio buffers
        "Loading audio buffers...".postln;
        (thisProcess.nowExecutingPath.dirname +/+ "setup/load-buffers.scd").load;
        s.sync; // Wait for server to finish loading buffers

        // 3. Initialize globals
        "Initializing setup...".postln;
        "setup/initialize.scd".loadRelative;
        0.5.wait;

        // 4. Load Patterns
        "Loading patterns...".postln;
        "patterns/drum-patterns.scd".loadRelative;
        0.2.wait;
        "patterns/bass-patterns.scd".loadRelative;
        0.2.wait;
        "patterns/lead-patterns.scd".loadRelative;
        0.2.wait;
        "patterns/pad-patterns.scd".loadRelative;
        0.2.wait;
        "patterns/fx-patterns.scd".loadRelative;
        0.5.wait;

        // 5. Load Functions
        "Loading functions...".postln;
        "functions/control.scd".loadRelative;
        0.2.wait;
        "functions/recording.scd".loadRelative;
        0.2.wait;
        "functions/performance.scd".loadRelative;
        0.5.wait;

        "".postln;
        "=== READY TO PLAY ===".postln;
        "".postln;
        "PLAYBACK:".postln;
        "  ~startPattern.()     - Play full composition".postln;
        "  ~stopPattern.()      - Stop all".postln;
        "  ~playPads.()         - Play pads only".postln;
        "  ~playLead.()         - Play lead only".postln;
        "  ~playPadsLead.()     - Play pads + lead".postln;
        "  ~playPadsBass.()     - Play pads + bass".postln;
        "".postln;
        "RECORDING:".postln;
        "  ~record.()           - Record full mix (330s)".postln;
        "  ~recordStems.()      - Record all stems (drums, bass, pads, lead, fx)".postln;
        "  ~quickTest.()        - Quick test (30s)".postln;
        "".postln;
        "INDIVIDUAL STEMS:".postln;
        "  ~recordBass.()       - Record bass stem only".postln;
        "  ~recordPads.()       - Record pads stem only".postln;
        "  ~recordLead.()       - Record lead stem only".postln;
        "  ~recordDrums.()      - Record drums stem only".postln;
        "  ~recordFX.()         - Record FX stem only".postln;
        "".postln;
        "PERFORMANCE:".postln;
        "  ~drop.()             - Drop to bass".postln;
        "  ~build.()            - Build back up".postln;
        "".postln;
        "COMPOSITION TIMING:".postln;
        ("  Tempo: " ++ ~tempo ++ " BPM").postln;
        ("  Time signature: " ++ ~beatsPerBar ++ "/4").postln;
        ("  Section length: " ++ ~barsPerSection ++ " bars = " ++ ~beatsPerSection ++ " beats = " ++ ~getSecondsFromSection.(1).round(0.1) ++ "s").postln;
        ("  Full intro: " ++ (~compositionStructure.last[0] + 1) ++ " sections = " ++ (~getSecondsFromSection.(~compositionStructure.last[0] + 1).round(0.1)) ++ "s").postln;
        "".postln;
        "RECORDING PATHS:".postln;
        ("  Main recordings: " ++ ~recordingsPath).postln;
        ("  Stems: " ++ ~stemsPath).postln;
        "".postln;
    };
};

// Boot the server
s.boot;
)
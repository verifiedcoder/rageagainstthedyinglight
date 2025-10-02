// Recording Functions
"Loading recording functions...".postln;

// Helper function to get elapsed time since recording start
~getElapsedTime = { |startTime|
    var elapsed = Main.elapsedTime - startTime;
    "[" ++ elapsed.round(0.01) ++ "s]";
};

// Full mix recording
~record = { |name="times-arrow-composition", duration=300, tail=30|
    fork({
        var timestamp = Date.localtime.stamp;
        var filename = name ++ "-" ++ timestamp ++ ".wav";
        var folderPath, filepath;
        var totalDuration = duration + tail;
        var introTime, introBeats;
        var lastSectionNum = 0;
        var startTime;
        var remainingSeconds, remainingBeats, tailBeats;

        // Determine save location - prefer local folder
        if(thisProcess.nowExecutingPath.notNil) {
            // Save next to the .scd file
            folderPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "recordings/";
        } {
            // Fallback to user folder
            folderPath = Platform.userAppSupportDir ++ "/recordings/";
        };

        // Create folder if needed
        if(File.exists(folderPath).not) {
            File.mkdir(folderPath);
            ("Created folder: " ++ folderPath).postln;
        };

        filepath = folderPath ++ filename;

        "Recording composition with tail capture...".postln;
        ("Sample Rate: " ++ s.sampleRate ++ "Hz").postln;
        ("Bit Depth: " ++ s.recSampleFormat).postln;
        ("Composition Duration: " ++ duration ++ " seconds").postln;
        ("Tail Capture Time: " ++ tail ++ " seconds").postln;
        ("Total Recording Duration: " ++ totalDuration ++ " seconds").postln;
        ("Output file: " ++ filename).postln;
        ("Full path: " ++ filepath).postln;
        ("Timestamp: " ++ timestamp).postln;
        "".postln;

        s.record(filepath);
        startTime = Main.elapsedTime;
        (~getElapsedTime.(startTime) ++ " Recording started").postln;
        1.wait;

        // Use composition structure (single source of truth)
        (~getElapsedTime.(startTime) ++ " Starting composition with staggered entries...").postln;

        ~compositionStructure.do({|entry, i|
            var sectionNum = entry[0];
            var patternName = entry[1];
            var displayName = entry[2];
            var beatOffset = ~getBeatsFromSection.(sectionNum);
            var waitSections = sectionNum - lastSectionNum;
            var expectedSeconds = ~getSecondsFromSection.(sectionNum);

            // Wait in beats - .wait uses TempoClock
            if(waitSections > 0) {
                var waitBeats = waitSections * ~beatsPerSection;
                waitBeats.wait;
            };

            // Start the pattern immediately (no quantisation during recording)
            Pdef(patternName).play;
            (~getElapsedTime.(startTime) ++ " Recording: " ++ displayName ++
                " added (section " ++ sectionNum ++ " = beat " ++ beatOffset ++
                " = expected " ++ expectedSeconds.round(0.1) ++ "s)").postln;

            lastSectionNum = sectionNum;
        });

        // Calculate intro in beats
        introBeats = ~compositionStructure.last[0] * ~beatsPerSection;
        introTime = ~getSecondsFromSection.(~compositionStructure.last[0]);
        (~getElapsedTime.(startTime) ++ " All patterns started, intro took " ++
            introTime.round(0.1) ++ "s").postln;

        // Continue for remaining duration - convert seconds to beats
        remainingSeconds = duration - introTime;
        remainingBeats = remainingSeconds * ~beatsPerSecond;
        remainingBeats.wait;

        // Stop all patterns
        (~getElapsedTime.(startTime) ++ " Composition patterns stopped - capturing " ++
            tail ++ " seconds of decay...").postln;
        Pdef.all.do(_.stop);
        tailBeats = tail * ~beatsPerSecond;
        tailBeats.wait;

        s.stopRecording;
        (~getElapsedTime.(startTime) ++ " Recording complete with full tail capture: " ++
            filename).postln;
        ("Total duration: " ++ totalDuration ++ " seconds").postln;
        ("File saved to: " ++ filepath).postln;
    }, TempoClock.default);
};

// Multi-track stem recording
~recordStems = { |name="times-arrow-stems", duration=300, tail=30|
    fork({
        var timestamp = Date.localtime.stamp;
        var folderPath, stemsPath;
        var totalStemDuration = duration + tail;
        var drumPatterns = [\kick, \snare, \hat, \clap, \openHat, \perc];
        var soloPatterns = [\bass, \pad, \lead, \fx];
        var numStems = 1 + soloPatterns.size;  // 1 drums stem + individual stems
        var totalTime = (totalStemDuration + 5) * numStems;

        // Determine save location
        if(thisProcess.nowExecutingPath.notNil) {
            folderPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "recordings/";
        } {
            folderPath = Platform.userAppSupportDir ++ "/recordings/";
        };

        stemsPath = folderPath ++ "stems/";

        // Create folders
        if(File.exists(folderPath).not) {
            File.mkdir(folderPath);
        };
        if(File.exists(stemsPath).not) {
            File.mkdir(stemsPath);
            ("Created stems folder: " ++ stemsPath).postln;
        };

        "Starting multi-track stems recording with tail capture...".postln;
        ("Sample Rate: " ++ s.sampleRate ++ "Hz, Bit Depth: " ++ s.recSampleFormat).postln;
        ("Stem Duration: " ++ duration ++ " seconds + " ++ tail ++ " seconds tail = " ++ totalStemDuration ++ " seconds total per stem").postln;
        ("Total recording time: approximately " ++ (totalTime / 60).round(0.1) ++ " minutes").postln;
        ("Timestamp: " ++ timestamp).postln;
        ("Saving stems to: " ++ stemsPath).postln;
        "".postln;

        // 1. DRUMS STEM - Progressive layering
        {
            var lastSectionNum = 0;
            var startTime;
            var lastDrumSeconds, remainingSeconds, remainingBeats, tailBeats;

            "Recording DRUMS stem (all drums combined with progressive layering)...".postln;
            ("Filename: " ++ name ++ "-drums-" ++ timestamp ++ ".wav").postln;
            s.record(stemsPath ++ name ++ "-drums-" ++ timestamp ++ ".wav");
            startTime = Main.elapsedTime;
            (~getElapsedTime.(startTime) ++ " DRUMS stem recording started").postln;
            1.wait;

            // Get drum patterns from composition structure
            ~compositionStructure.do({|entry|
                var sectionNum = entry[0];
                var patternName = entry[1];
                var displayName = entry[2];
                var beatOffset = ~getBeatsFromSection.(sectionNum);
                var waitSections = sectionNum - lastSectionNum;
                var expectedSeconds = ~getSecondsFromSection.(sectionNum);

                if(drumPatterns.includes(patternName)) {
                    if(waitSections > 0) {
                        var waitBeats = waitSections * ~beatsPerSection;
                        waitBeats.wait;
                    };

                    Pdef(patternName).play;
                    (~getElapsedTime.(startTime) ++ " Drums Stem: " ++ displayName ++
                        " added (section " ++ sectionNum ++ " = beat " ++ beatOffset ++
                        " = expected " ++ expectedSeconds.round(0.1) ++ "s)").postln;
                    lastSectionNum = sectionNum;
                };
            });

            // Continue for remaining duration in beats
            (~getElapsedTime.(startTime) ++ " All drum patterns started").postln;
            lastDrumSeconds = ~getSecondsFromSection.(lastSectionNum);
            remainingSeconds = duration - lastDrumSeconds;
            remainingBeats = remainingSeconds * ~beatsPerSecond;
            remainingBeats.wait;

            // Stop drums
            drumPatterns.do { |key| Pdef(key).stop };
            (~getElapsedTime.(startTime) ++ " Drums patterns stopped - capturing " ++
                tail ++ " seconds of decay...").postln;
            tailBeats = tail * ~beatsPerSecond;
            tailBeats.wait;
            s.stopRecording;
            (~getElapsedTime.(startTime) ++ " Finished recording drums stem: " ++
                name ++ "-drums-" ++ timestamp ++ ".wav").postln;
            ("Total duration: " ++ totalStemDuration ++ " seconds").postln;
            "".postln;

            5.wait; // Gap between recordings
        }.value;

        // 2. INDIVIDUAL STEMS - Record each solo pattern using composition structure
        soloPatterns.do({|patternName|
            var entry = ~compositionStructure.detect({|e| e[1] == patternName});
            var sectionNum = entry[0];
            var displayName = entry[2];
            var stemName = patternName.asString;
            var beatOffset = ~getBeatsFromSection.(sectionNum);
            var expectedSeconds = ~getSecondsFromSection.(sectionNum);
            var startTime;
            var remainingSeconds, remainingBeats, tailBeats;

            ("Recording " ++ displayName.toUpper ++ " stem (silence until section " ++
                sectionNum ++ " = beat " ++ beatOffset ++ ", then enters)...").postln;
            ("Filename: " ++ name ++ "-" ++ stemName ++ "-" ++ timestamp ++ ".wav").postln;
            s.record(stemsPath ++ name ++ "-" ++ stemName ++ "-" ++ timestamp ++ ".wav");
            startTime = Main.elapsedTime;
            (~getElapsedTime.(startTime) ++ " " ++ displayName.toUpper ++
                " stem recording started").postln;
            1.wait;

            // Record silence for initial section in beats
            if(beatOffset > 0) {
                (~getElapsedTime.(startTime) ++ " " ++ displayName ++
                    " Stem: Recording silence (section 0 to " ++ sectionNum ++
                    " = " ++ expectedSeconds.round(0.1) ++ "s)...").postln;
                beatOffset.wait;  // Wait in beats
            };

            // Start pattern immediately (no quantisation during recording)
            Pdef(patternName).play;
            (~getElapsedTime.(startTime) ++ " " ++ displayName ++ " Stem: " ++
                displayName ++ " started at section " ++ sectionNum ++
                " (beat " ++ beatOffset ++ ")").postln;

            // Continue for remaining duration in beats
            remainingSeconds = duration - expectedSeconds;
            remainingBeats = remainingSeconds * ~beatsPerSecond;
            remainingBeats.wait;

            // Stop and capture tail
            Pdef(patternName).stop;
            (~getElapsedTime.(startTime) ++ " " ++ displayName ++
                " pattern stopped - capturing " ++ tail ++ " seconds of decay...").postln;
            tailBeats = tail * ~beatsPerSecond;
            tailBeats.wait;

            s.stopRecording;
            (~getElapsedTime.(startTime) ++ " Finished recording " ++ stemName ++
                " stem: " ++ name ++ "-" ++ stemName ++ "-" ++ timestamp ++ ".wav").postln;
            ("Total duration: " ++ totalStemDuration ++ " seconds (includes initial silence)").postln;
            "".postln;

            5.wait; // Gap between recordings
        });

        "=== ALL STEMS RECORDED ===".postln;
        ("Stem base name: " ++ name).postln;
        ("Timestamp: " ++ timestamp).postln;
        ("All stems are EXACTLY " ++ totalStemDuration ++ " seconds").postln;
        ("Total recording session time: " ++ (totalTime / 60).round(0.1) ++ " minutes").postln;
        ("Files saved to: " ++ stemsPath).postln;
    }, TempoClock.default);
};

// Individual stem recording functions with proper timing
~recordBass = { |duration=300, tail=30|
    var name = "times-arrow-stems-bass";
    fork({
        var timestamp = Date.localtime.stamp;
        var filename = name ++ "-" ++ timestamp ++ ".wav";
        var stemsPath = ~stemsPath;
        var startTime;
        var remainingBeats, tailBeats;

        ("Recording BASS stem (" ++ (duration + tail) ++ "s total)...").postln;
        ("Filename: " ++ filename).postln;

        s.record(stemsPath ++ filename);
        startTime = Main.elapsedTime;
        (~getElapsedTime.(startTime) ++ " Bass recording started").postln;
        1.wait;

        // Bass enters at section 0 immediately
        Pdef(\bass).play;
        (~getElapsedTime.(startTime) ++ " Bass started").postln;

        // Record for full duration
        remainingBeats = duration * ~beatsPerSecond;
        remainingBeats.wait;

        // Stop and capture tail
        Pdef(\bass).stop;
        (~getElapsedTime.(startTime) ++ " Bass stopped - capturing tail...").postln;
        tailBeats = tail * ~beatsPerSecond;
        tailBeats.wait;

        s.stopRecording;
        (~getElapsedTime.(startTime) ++ " Bass recording complete: " ++ filename).postln;
    }, TempoClock.default);
};

~recordPads = { |duration=300, tail=30|
    var name = "times-arrow-stems-pad";
    fork({
        var timestamp = Date.localtime.stamp;
        var filename = name ++ "-" ++ timestamp ++ ".wav";
        var stemsPath = ~stemsPath;
        var padSection = 7;  // Pads enter at section 7
        var padBeats = ~getBeatsFromSection.(padSection);
        var padSeconds = ~getSecondsFromSection.(padSection);
        var startTime;
        var remainingSeconds, remainingBeats, tailBeats;

        ("Recording PADS stem with silence until section " ++ padSection ++ "...").postln;
        ("Filename: " ++ filename).postln;

        s.record(stemsPath ++ filename);
        startTime = Main.elapsedTime;
        (~getElapsedTime.(startTime) ++ " Pads recording started").postln;
        1.wait;

        // Record silence until pads enter
        (~getElapsedTime.(startTime) ++ " Recording silence (0 to " ++ padSeconds.round(0.1) ++ "s)...").postln;
        padBeats.wait;

        // Start pads
        Pdef(\pad).play;
        (~getElapsedTime.(startTime) ++ " Pads started at section " ++ padSection).postln;

        // Record for remaining duration
        remainingSeconds = duration - padSeconds;
        remainingBeats = remainingSeconds * ~beatsPerSecond;
        remainingBeats.wait;

        // Stop and capture tail
        Pdef(\pad).stop;
        (~getElapsedTime.(startTime) ++ " Pads stopped - capturing tail...").postln;
        tailBeats = tail * ~beatsPerSecond;
        tailBeats.wait;

        s.stopRecording;
        (~getElapsedTime.(startTime) ++ " Pads recording complete: " ++ filename).postln;
    }, TempoClock.default);
};

~recordLead = { |duration=300, tail=30|
    var name = "times-arrow-stems-lead";
    fork({
        var timestamp = Date.localtime.stamp;
        var filename = name ++ "-" ++ timestamp ++ ".wav";
        var stemsPath = ~stemsPath;
        var leadSection = 8;  // Lead enters at section 8
        var leadBeats = ~getBeatsFromSection.(leadSection);
        var leadSeconds = ~getSecondsFromSection.(leadSection);
        var startTime;
        var remainingSeconds, remainingBeats, tailBeats;
        var checkInterval, totalBeats, elapsed, waitTime;

        ("Recording LEAD stem with silence until section " ++ leadSection ++ "...").postln;
        ("Filename: " ++ filename).postln;

        s.record(stemsPath ++ filename);
        startTime = Main.elapsedTime;
        (~getElapsedTime.(startTime) ++ " Lead recording started").postln;
        1.wait;

        // Record silence until lead enters
        (~getElapsedTime.(startTime) ++ " Recording silence (0 to " ++ leadSeconds.round(0.1) ++ "s)...").postln;
        leadBeats.wait;

        // Reset lead state to ensure fresh start
        ~currentLeadNote = 21;
        ~leadTimbreIndex = 0;
        ~currentPadNotes = [0, 2, 4];  // Initialize pad harmony reference
        (~getElapsedTime.(startTime) ++ " Lead state reset").postln;

        // Clear any existing lead pattern state and start fresh
        Pdef(\lead).clear;
        Pdef(\lead).quant = nil;  // No quantisation during recording
        "patterns/lead-patterns.scd".loadRelative;  // Reload lead pattern
        0.1.wait;
        (~getElapsedTime.(startTime) ++ " Lead pattern reloaded").postln;

        // Start lead
        Pdef(\lead).play;
        (~getElapsedTime.(startTime) ++ " Lead pattern started, should play for " ++
            (duration - leadSeconds).round(0.1) ++ " seconds").postln;

        // Log every 30 seconds to verify lead is still playing
        checkInterval = 30 * ~beatsPerSecond;  // 30 seconds in beats
        totalBeats = (duration - leadSeconds) * ~beatsPerSecond;
        elapsed = 0;

        while({ elapsed < totalBeats }, {
            waitTime = min(checkInterval, totalBeats - elapsed);
            waitTime.wait;
            elapsed = elapsed + waitTime;
            if(elapsed < totalBeats, {
                (~getElapsedTime.(startTime) ++ " Lead still recording... (" ++
                    (elapsed / ~beatsPerSecond).round(0.1) ++ "s elapsed)").postln;
            });
        });

        // Stop and capture tail
        Pdef(\lead).stop;
        (~getElapsedTime.(startTime) ++ " Lead stopped - capturing tail...").postln;
        tailBeats = tail * ~beatsPerSecond;
        tailBeats.wait;

        s.stopRecording;
        (~getElapsedTime.(startTime) ++ " Lead recording complete: " ++ filename).postln;
    }, TempoClock.default);
};

~recordDrums = { |duration=300, tail=30|
    var name = "times-arrow-stems-drums";
    fork({
        var timestamp = Date.localtime.stamp;
        var filename = name ++ "-" ++ timestamp ++ ".wav";
        var stemsPath = ~stemsPath;
        var drumPatterns = [\kick, \snare, \hat, \clap, \openHat, \perc];
        var lastSectionNum = 0;
        var startTime;
        var lastDrumSeconds, remainingSeconds, remainingBeats, tailBeats;

        ("Recording DRUMS stem with progressive layering...").postln;
        ("Filename: " ++ filename).postln;

        s.record(stemsPath ++ filename);
        startTime = Main.elapsedTime;
        (~getElapsedTime.(startTime) ++ " Drums recording started").postln;
        1.wait;

        // Get drum patterns from composition structure
        ~compositionStructure.do({|entry|
            var sectionNum = entry[0];
            var patternName = entry[1];
            var displayName = entry[2];
            var beatOffset = ~getBeatsFromSection.(sectionNum);
            var waitSections = sectionNum - lastSectionNum;
            var expectedSeconds = ~getSecondsFromSection.(sectionNum);

            if(drumPatterns.includes(patternName)) {
                if(waitSections > 0) {
                    var waitBeats = waitSections * ~beatsPerSection;
                    waitBeats.wait;
                };

                Pdef(patternName).play;
                (~getElapsedTime.(startTime) ++ " " ++ displayName ++
                    " added (section " ++ sectionNum ++ ")").postln;
                lastSectionNum = sectionNum;
            };
        });

        // Continue for remaining duration
        (~getElapsedTime.(startTime) ++ " All drums started").postln;
        lastDrumSeconds = ~getSecondsFromSection.(lastSectionNum);
        remainingSeconds = duration - lastDrumSeconds;
        remainingBeats = remainingSeconds * ~beatsPerSecond;
        remainingBeats.wait;

        // Stop drums
        drumPatterns.do { |key| Pdef(key).stop };
        (~getElapsedTime.(startTime) ++ " Drums stopped - capturing tail...").postln;
        tailBeats = tail * ~beatsPerSecond;
        tailBeats.wait;

        s.stopRecording;
        (~getElapsedTime.(startTime) ++ " Drums recording complete: " ++ filename).postln;
    }, TempoClock.default);
};

~recordFX = { |duration=300, tail=30|
    var name = "times-arrow-stems-fx";
    fork({
        var timestamp = Date.localtime.stamp;
        var filename = name ++ "-" ++ timestamp ++ ".wav";
        var stemsPath = ~stemsPath;
        var fxSection = 9;  // FX enters at section 9
        var fxBeats = ~getBeatsFromSection.(fxSection);
        var fxSeconds = ~getSecondsFromSection.(fxSection);
        var startTime;
        var remainingSeconds, remainingBeats, tailBeats;

        ("Recording FX stem with silence until section " ++ fxSection ++ "...").postln;
        ("Filename: " ++ filename).postln;

        s.record(stemsPath ++ filename);
        startTime = Main.elapsedTime;
        (~getElapsedTime.(startTime) ++ " FX recording started").postln;
        1.wait;

        // Record silence until FX enters
        (~getElapsedTime.(startTime) ++ " Recording silence (0 to " ++ fxSeconds.round(0.1) ++ "s)...").postln;
        fxBeats.wait;

        // Start FX
        Pdef(\fx).play;
        (~getElapsedTime.(startTime) ++ " FX started at section " ++ fxSection).postln;

        // Record for remaining duration
        remainingSeconds = duration - fxSeconds;
        remainingBeats = remainingSeconds * ~beatsPerSecond;
        remainingBeats.wait;

        // Stop and capture tail
        Pdef(\fx).stop;
        (~getElapsedTime.(startTime) ++ " FX stopped - capturing tail...").postln;
        tailBeats = tail * ~beatsPerSecond;
        tailBeats.wait;

        s.stopRecording;
        (~getElapsedTime.(startTime) ++ " FX recording complete: " ++ filename).postln;
    }, TempoClock.default);
};

// Quick test recording
~quickTest = {
    fork({
        var filename = "test-" ++ Date.localtime.stamp ++ ".wav";
        var filepath;
        var startTime;

        if(thisProcess.nowExecutingPath.notNil) {
            filepath = PathName(thisProcess.nowExecutingPath).parentPath ++ "recordings/" ++ filename;
        } {
            filepath = Platform.userAppSupportDir ++ "/recordings/" ++ filename;
        };

        "Quick test recording (30 seconds)...".postln;
        s.record(filepath);
        startTime = Main.elapsedTime;
        (~getElapsedTime.(startTime) ++ " Test recording started").postln;
        1.wait;

        // Quick version with faster entries
        Pdef(\kick).play(quant: 1);
        Pdef(\bass).play(quant: 1);
        (~getElapsedTime.(startTime) ++ " Kick + Bass started").postln;
        2.wait;
        Pdef(\snare).play(quant: 1);
        (~getElapsedTime.(startTime) ++ " Snare added").postln;
        2.wait;
        Pdef(\hat).play(quant: 1);
        (~getElapsedTime.(startTime) ++ " Hi-hats added").postln;
        2.wait;
        Pdef(\lead).play(quant: 1);
        (~getElapsedTime.(startTime) ++ " Lead added").postln;

        20.wait;

        Pdef.all.do(_.stop);
        (~getElapsedTime.(startTime) ++ " All patterns stopped").postln;
        2.wait;
        s.stopRecording;
        (~getElapsedTime.(startTime) ++ " Test saved: " ++ filename).postln;
    }, TempoClock.default);
};

"Recording functions loaded".postln;
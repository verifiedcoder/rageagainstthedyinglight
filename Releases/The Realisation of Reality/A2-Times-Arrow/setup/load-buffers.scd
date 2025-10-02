// Load audio samples
"Loading audio buffers...".postln;

// Get path to buffers folder relative to this file (../buffers)
~buffersPath = PathName(thisProcess.nowExecutingPath).pathOnly +/+ ".." +/+ "buffers";
~buffersPath = PathName(~buffersPath).fullPath;  // Resolve relative path to absolute
("Buffers path: " ++ ~buffersPath).postln;

// Verify path exists
if(PathName(~buffersPath).isFolder) {
    "Buffers folder found!".postln;
} {
    "ERROR: Buffers folder not found at path above!".postln;
};

// Initialize buffer arrays - store [buffer, numChannels] pairs
~kicks = List.new;
~snares = List.new;
~claps = List.new;
~closedHats = List.new;
~openHats = List.new;
~percs = List.new;
~fxSounds = List.new;

// Helper function to add buffer with channel info
~addBuffer = { |list, path|
    var buf = Buffer.read(s, path.fullPath);
    s.sync;  // Wait for buffer to load so we can query channels
    list.add([buf, buf.numChannels]);
    ("Loaded: " ++ path.fileName ++ " (" ++ buf.numChannels ++ " ch)").postln;
};

// Load kicks
PathName(~buffersPath +/+ "kicks").files.do({ |path|
    ~addBuffer.(~kicks, path);
});

// Load snares
PathName(~buffersPath +/+ "snares").files.do({ |path|
    ~addBuffer.(~snares, path);
});

// Load claps
PathName(~buffersPath +/+ "claps").files.do({ |path|
    ~addBuffer.(~claps, path);
});

// Load closed hats
PathName(~buffersPath +/+ "closedHats").files.do({ |path|
    ~addBuffer.(~closedHats, path);
});

// Load open hats
PathName(~buffersPath +/+ "openHats").files.do({ |path|
    ~addBuffer.(~openHats, path);
});

// Load percs
PathName(~buffersPath +/+ "percs").files.do({ |path|
    ~addBuffer.(~percs, path);
});

// Load fx
PathName(~buffersPath +/+ "fx").files.do({ |path|
    ~addBuffer.(~fxSounds, path);
});

// Store counts for random selection
~kicksCount = ~kicks.size;
~snaresCount = ~snares.size;
~clapsCount = ~claps.size;
~closedHatsCount = ~closedHats.size;
~openHatsCount = ~openHats.size;
~percsCount = ~percs.size;
~fxSoundsCount = ~fxSounds.size;

"".postln;
("Buffers loaded: " ++ ~kicksCount ++ " kicks, " ++ ~snaresCount ++ " snares, " ++
    ~clapsCount ++ " claps, " ++ ~closedHatsCount ++ " closed hats, " ++
    ~openHatsCount ++ " open hats, " ++ ~percsCount ++ " percs, " ++
    ~fxSoundsCount ++ " fx").postln;
"Buffers ready".postln;
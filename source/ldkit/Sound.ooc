
// third-party
use bleep
import bleep

use deadlogger
import deadlogger/[Log, Logger]

// sdk
import math/Random
import structs/[HashMap]

BoomboxConfig: class {

    musicPath := "assets/ogg"
    sfxPath := "assets/wav"
    mute := false

    init: func

}

// a sound system :D
Boombox: class {

    // composition
    bleep: Bleep
    config := BoomboxConfig new()
    logger := static Log getLogger("boombox")

    // state
    samples := HashMap<String, Sample> new()
    currentMusic: String

    init: func {
        bleep = Bleep new()
    }

    // Music code
    playMusic: func (name: String, loops := 0) {
        // abide by the mute
        if (config mute) return

        bleep playMusic("%s/%s.ogg" format(config musicPath, name), loops)
        currentMusic = name
    }

    onMusicStops: func {
        currentMusic = null
    }

    musicPlays?: func -> Bool {
        currentMusic != null
    }

    // SFX code
    playSound: func (name: String, loops := 0) {
        // abide by the mute
        if (config mute) return

        if (samples contains?(name)) {
            samples get(name) play(loops)
        } else {
            path := "%s/%s.wav" format(config sfxPath, name)
            sample := bleep loadSample(path)
            if (sample) {
                samples put(name, sample)
                sample play(loops)
            } else {
                logger warn("Couldn't load sfx %s", path)
            }
        }
    }

    playRandomSound: func (name: String, variants := 2, loops := 0) {
        variant := Random randInt(1, variants)
        playSound("%s%d" format(name, variant), loops)
    }

    destroy: func {
        bleep destroy()
    }

}


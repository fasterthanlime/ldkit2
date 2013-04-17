
// ours
import ldkit/[Display, Sprites, Sound, Engine, Pass, FlashMessages]

// third-party
use deadlogger
import deadlogger/Log

use zombieconfig
import zombieconfig

use dye
import dye/[math, input]

use sdl
import sdl/Core

// sdk
import os/Time

UI: class {

    // note to viewers: 'This' refers to the current class in ooc.
    logger := static Log getLogger(This name)

    // our dye context
    dye: DyeContext

    // something we can read events from
    input: Input

    // something we can make noise with
    boombox: Boombox

    // something we can control level loading with
    engine: Engine

    escQuits := true

    /*
     * Constructors
     */
    init: func (=engine, config: ZombieConfig) {
        // note: all config entries are String, so we just have to cheat a bit ;)
        width  := config["screenWidth"]  toInt()
        height := config["screenHeight"] toInt()
        fullScreen := (config["fullScreen"] == "true")
        title := config["title"]

        dye = Display new(width, height, title, fullScreen)
        dye hideCursor()

        input = SdlInput new()

        initSound()
        initPasses()
        initEvents()
    }

    initSound: func {
        logger info("Initializing sound system")
        boombox = Boombox new()
    }

    // different UI passes
    rootPass := GlGroup new()

    // name passes for later profiling
    bgPass := GlGroup new() // clear
    levelPass := GlGroup new() // level terrain etc.
    hudPass := GlGroup new()  // human interface (windows/dialogs etc.)

    // status pass
    statusPass := GlGroup new()

    // mouse pass (cursor)
    mousePass := GlGroup new()
    cursor: GlGroup

    flashMessages: FlashMessages

    initPasses: func {
        flashMessages = FlashMessages new(this)

        // offset to make the hand correspond with the actual mouse
        cursorImage := ImageSprite new(vec2(-12, -10), "assets/png/cursor.png") 
        cursor = GroupSprite new()
        cursor add(cursorImage)

        mousePass addSprite(cursor)

        input onMouseMove(||
            cursor pos set!(input mousepos)
        )

        reset()
    }
    
    reset: func {
        // flashMessages reset()

        rootPass reset()

        // nothing to reset
        rootPass addPass(bgPass)

        // everything will be re-created when loading the level
        levelPass reset()
        rootPass addPass(levelPass)

        // close all windows
        hudPass reset()
        rootPass addPass(hudPass)

        // status is just a few text fields, no need to recreate
        rootPass addPass(statusPass)

        // no need to recreate either
        rootPass addPass(mousePass)
    }

    flash: func (msg: String) {
        flashMessages push(msg)
    }

    update: func {
        flashMessages update()

        display clear()
        rootPass draw()
        display blit()

        input _poll()
    }

    initEvents: func {
        // it's a better practice to turn on debug locally
        //input debug = true

	input onKeyPress(Keys ESC, ||
	    if (escQuits) engine quit()
	)

        input onExit(||
	    engine quit()
        )
    }

}



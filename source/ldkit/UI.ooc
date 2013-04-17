
// ours
import ldkit/[Sound, Engine, FlashMessages]

// third-party
use deadlogger
import deadlogger/Log

use zombieconfig
import zombieconfig

use dye
import dye/[core, math, input, sprite]

UI: class {

    fontPath := "assets/ttf/font.ttf"

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

        dye = DyeContext new(width, height, title, fullScreen)
        dye setShowCursor(false)

        input = dye input

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
        cursorImage := GlSprite new("assets/png/cursor.png") 
        cursorImage pos set!(-12, -10)
        cursor = GlGroup new()
        cursor add(cursorImage)

        mousePass add(cursor)

        input onMouseMove(|mm|
            cursor pos set!(input mousepos)
        )

        reset()
    }
    
    reset: func {
        // flashMessages reset()

        rootPass clear()

        // nothing to reset
        rootPass add(bgPass)

        // everything will be re-created when loading the level
        levelPass clear()
        rootPass add(levelPass)

        // close all windows
        hudPass clear()
        rootPass add(hudPass)

        // status is just a few text fields, no need to recreate
        rootPass add(statusPass)

        // no need to recreate either
        rootPass add(mousePass)
    }

    flash: func (msg: String) {
        flashMessages push(msg)
    }

    update: func {
        flashMessages update()

        dye draw()
        dye poll()
    }

    initEvents: func {
        // it's a better practice to turn on debug locally
        //input debug = true

	input onKeyPress(KeyCode ESC, |kp|
	    if (escQuits) engine quit()
	)

        input onExit(||
	    engine quit()
        )
    }

}



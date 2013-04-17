
// third-party

/* ************************
 * BEGIN - TODO GET RID OF
 *************************/
use gobject
import gobject

use cairo
import cairo/[Cairo] 

use sdl
import sdl/[Core, Event]
/* ************************
 * END - TODO GET RID OF
 *************************/

use deadlogger
import deadlogger/Log

use zombieconfig
import zombieconfig

use dye
import dye/[math]

// sdk
import structs/[ArrayList]

Display: class {

    screen, sdlSurface: SdlSurface*
    cairoSurface: CairoImageSurface
    cairoContext: CairoContext

    width, height: Int

    logger := static Log getLogger(This name)

    init: func (=width, =height, fullScreen: Bool, title: String) {
        g_type_init() // needed for librsvg to work
        
        logger info("Initializing SDL...")
        SDL init(SDL_INIT_EVERYTHING) // SHUT... DOWN... EVERYTHING! (Madagascar in Pandemic 2)

        flags := SDL_HWSURFACE
        if(fullScreen) {
            flags |= SDL_FULLSCREEN
        }

        screen = SDL setMode(width, height, 32, flags)
        SDL wmSetCaption(title, null)

        sdlSurface = SDL createRgbSurface(SDL_HWSURFACE, width, height, 32,
            0x00FF0000, 0x0000FF00, 0x000000FF, 0)

        cairoSurface = CairoImageSurface new(sdlSurface@ pixels, CairoFormat RGB24,
            sdlSurface@ w, sdlSurface@ h, sdlSurface@ pitch)

        cairoContext = CairoContext new(cairoSurface)
    }

    hideCursor: func {
        SDL showCursor(false) 
    }

    getWidth: func -> Int {
        width
    }

    getHeight: func -> Int {
        height
    }

    getCenter: func -> Vec2 {
        vec2(width / 2, height / 2)
    }

    clear: func {
        cr := cairoContext

        cr setSourceRGB(0, 0, 0)
        cr paint()
    }

    blit: func {
        SDL blitSurface(sdlSurface, null, screen, null)
        SDL flip(screen)
    }

}


use sdl2
import sdl2/Core

LTime: class {

    // the number of 'ticks' since the application start-up
    getTicks: static func -> Int {
        SDL getTicks()
    } 

    // sleep for 'delta' ticks
    delay: static func (delta: UInt32) {
        SDL delay(delta)
    }

}

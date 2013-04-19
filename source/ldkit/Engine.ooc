
// third-party
use zombieconfig
import zombieconfig

// sdk
import structs/[ArrayList]

// ours
import UI, Timing, Actor

Engine: class {

    ui: UI

    actors := ArrayList<Actor> new()

    init: func(config: ZombieConfig) {
        ui = UI new(this, config)
    }

    update: func {
        ui update()

	iter := actors iterator()
	while (iter hasNext?()) {
	    actor := iter next()
	    if (actor update()) {
		iter remove()
	    }
	}
    }

    add: func (actor: Actor) {
	actors add(actor)
    }

    remove: func (actor: Actor) {
	actors remove(actor)
    }

    onTick: func (f: Func (Float)) {
	actors add(ActorClosure new(f))
    }

    quit: func {
	ui dye quit()
	exit(0)
    }

}



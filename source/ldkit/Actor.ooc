
Actor: class {

    init: func {}

    update: func -> Bool {
	"Override %s#update!" printfln(class name)
    }

    destroy: func {
	"Override %s#destroy!" printfln(class name)
    }

}

ActorClosure: class extends Actor {

    f: Func (Float)

    init: func (=f) {

    }

    update: func (delta: Float) -> Bool {
	f(delta)
    }

}


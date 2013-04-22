
// third-party
use chipmunk
import chipmunk

use gnaar
import gnaar/[utils]

import ldkit/[Actor]

// sdk
import structs/[HashMap]

PhysicsActor: class extends Actor {

    body: CpBody
    shape: CpShape
    rotateConstraint: CpConstraint

    space: CpSpace

    pos: Vec2

    init: func (=space) {
        
    }

    createBody: func (mass, moment: Float) {
        body = CpBody new(mass, moment)
        body setPos(cpv(pos))
        space addBody(body)
    }

    createCircle: func (radius: Float, mass: Float) {
        moment := cpMomentForCircle(mass, 0, radius, cpv(radius, radius))
        createCircle(radius, mass, moment)
    }

    createCircle: func ~withMoment (radius: Float, mass, moment: Float) {
        createBody(mass, moment) 
        setShape(CpCircleShape new(body, radius, cpv(0, 0)))
        createConstraint()
    }

    createBox: func (width, height: Float, mass: Float) {
        moment := cpMomentForBox(mass, width, height)
        createBox(width, height, mass, moment)
    }

    createBox: func ~withMoment (width, height: Float, mass, moment: Float) {
        createBody(mass, moment)
        setShape(CpBoxShape new(body, width, height))
        createConstraint()
    }

    setShape: func (.shape) {
        if (this shape) {
            space removeShape(this shape)
            this shape free()
        }

        this shape = shape
        shape setUserData(this)
        space addShape(shape)
    }

    createConstraint: func {
        rotateConstraint = CpRotaryLimitJoint new(body, space getStaticBody(), 0, 0)
        space addConstraint(rotateConstraint)
    }

    destroy: func {
        space removeShape(shape)
        shape free()

        space removeConstraint(rotateConstraint)
        rotateConstraint free()

        space removeBody(body)
        body free()
    }

    handlerPool := static HandlerPool new()

}

HandlerPool: class {

    cachedSpace: CpSpace

    halfHandlers := HashMap<Int32, HalfHandler> new()
    handlers := HashMap<Int64, GenericHandler> new()

    setupCollisions: func (space: CpSpace, typeA: Int32, f: Func (HalfHandler)) {
        if (space != cachedSpace) {
            clear()
            cachedSpace = space
        }

        halfHandler := halfHandlers get(typeA)
        if (!halfHandler) {
            halfHandler = HalfHandler new(this, typeA)
            halfHandlers put(typeA, halfHandler)
        }

        f(halfHandler)
    }

    clear: func {
        handlers clear()
    }

    _hash: func (a, b: Int32) -> Int64 {
        ((a as Int64) << (32 as Int64)) | (b as Int64)
    }

    hasPair?: func (a, b: Int32) -> Bool {
        handlers contains?(_hash(a, b))
    }

    add: func (a, b: Int32, handler: GenericHandler) {
        handlers put(_hash(a, b), handler)
        if (cachedSpace) {
            cachedSpace addCollisionHandler(a, b, handler)
        }
    }

}

HalfHandler: class {

    pool: HandlerPool
    typeA: Int32

    init: func (=pool, =typeA) {
    }

    collideWith: func (typeB: Int32, f: Func (GenericHandler)) {
        if (!pool hasPair?(typeA, typeB)) {
            handler := GenericHandler new()
            f(handler)
            pool add(typeA, typeB, handler)
        }
    }

}

extend CpArbiter {

    getObjects: func <K, V> (dst1: K*, dst2: V*) {
        a, b: CpShape
        getShapes(a&, b&)

        obj1 := a getUserData() as Object
        obj2 := b getUserData() as Object

        if (obj1 != null && !obj1 instanceOf?(K)) {
            raise("Wrong object type1 in collision handler: expected %s, got %s" format(
            K name, obj1 class name))
        }

        if (obj2 != null && !obj2 instanceOf?(V)) {
            raise("Wrong object type2 in collision handler: expected %s, got %s" format(
            V name, obj2 class name))
        }

        dst1@ = obj1
        dst2@ = obj2
    }

}

GenericHandler: class extends CpCollisionHandler {

    beginCb     : Func (CpArbiter) -> Bool
    preSolveCb  : Func (CpArbiter) -> Bool
    postSolveCb : Func (CpArbiter)
    separateCb  : Func (CpArbiter)

    init: func {
        beginCb     = func (arbiter: CpArbiter) -> Bool { true }
        preSolveCb  = func (arbiter: CpArbiter) -> Bool { true }
        postSolveCb = func (arbiter: CpArbiter) {}
        separateCb  = func (arbiter: CpArbiter) {}
    }

    // DSL stuff

    begin: func ~dsl (=beginCb)
    preSolve: func ~dsl (=preSolveCb)
    postSolve: func ~dsl (=postSolveCb)
    separate: func ~dsl (=separateCb)

    // overloads to communicate with ooc-chipmunk

    begin: func (arb: CpArbiter, space: CpSpace) -> Bool {
        beginCb(arb)
    }

    preSolve: func (arb: CpArbiter, space: CpSpace) -> Bool {
        preSolveCb(arb)
    }

    postSolve: func (arb: CpArbiter, space: CpSpace) {
        postSolveCb(arb)
    }

    separate: func (arb: CpArbiter, space: CpSpace) {
        separateCb(arb)
    }

}


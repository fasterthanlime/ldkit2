
use chipmunk
import chipmunk

use gnaar
import gnaar/[utils]

import ldkit/[Actor]

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

}

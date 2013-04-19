
use chipmunk
import chipmunk

import ldkit/[Actor]

PhysicsActor: class extends Actor {

    body: CpBody
    shape: CpShape

    space: CpSpace

    init: func (=space) {
        
    }

    createBody: func (mass, moment: Float) {
        body = CpBody new(mass, moment)
        body setPos(cpv(pos))
        level space addBody(body)
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
            level space removeShape(this shape)
            this shape free()
        }

        this shape = shape
        shape setUserData(this)
        level space addShape(shape)
    }

    createConstraint: func {
        rotateConstraint = CpRotaryLimitJoint new(body, level space getStaticBody(), 0, 0)
        level space addConstraint(rotateConstraint)
    }

    destroy: func {
        level space removeShape(shape)
        shape free()

        level space removeConstraint(rotateConstraint)
        rotateConstraint free()

        level space removeBody(body)
        body free()
    }

}

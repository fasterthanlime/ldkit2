
// internal
import ldkit/[UI]

// third-party
use dye
import dye/[core, math, sprite, primitives]

// sdk
import structs/[Stack]

FlashMessages: class {

    ui: UI

    messages := Stack<String> new()

    messageLength := 90
    counter := 0
     
    pass: GlGroup

    labelSprite: GlSprite

    init: func (=ui) {
	pass = GlGroup new()
	ui statusPass add(pass)

	pos := vec2(ui dye center x, ui dye height - 40)

	rectSprite := GlRectangle new(500, 80)
        rectSprite pos set!(pos)
	rectSprite color set!(0, 0, 0, )
	rectSprite alpha = 0.7
	pass add(rectSprite)

        labelSprite = GlText new(ui fontPath, "", 30)
        labelSprite pos set!(pos)
        labelSprite color set!(230, 230, 128)
        counter = messageLength

        pass add(labelSprite)
    }

    reset: func {
        counter = 0
        messages clear()
        hide()
    }

    show: func {
	pass visible = true
    }

    hide: func {
	pass visible = false
    }

    push: func (msg: String) {
        if (msg size > 0) {
            messages push(msg)
	    counter = messageLength - 10
        }
    }

    update: func {
        if (counter < messageLength) {
            counter += 1
        } else {
            if (!messages empty?()) {
                labelSprite value = messages pop()
		show()
                counter = 0
            } else {
                hide()
            }
        }
    }

}




/*
 * A sprite is, in the large sense, anything that can be drawn onto a display.
 */

use cairo
import cairo/[Cairo, CairoFT]

use freetype2
import freetype2

use deadlogger
import deadlogger/Log

import io/File
import structs/[HashMap, ArrayList]

// libs deps
import Math, Display

Sprite: class {

    logger := static Log getLogger(This name)
    pos := vec2(0.0, 0.0)
    offset := vec2(0.0, 0.0)
    scale := vec2(1.0, 1.0)
    color := vec3(1.0, 0.0, 0.0)
    parent: This

    alpha := 1.0
    visible := true

    init: func (pos: Vec2) {
        this pos set!(pos)
    }

    draw: func (display: Display) {
        if (!visible) return

        cr := display cairoContext

        cr save()
        cr translate(pos x + offset x, pos y + offset y)
        cr scale(scale x, scale y)
        cr setSourceRGBA(color x, color y, color z, alpha)

        paint(cr)
        cr restore()
    }

    /*
     * This is the function you want to overload
     * when you have custom sprites
     */
    paint: func (cr: Context) {
        cr setLineWidth(3)

        cr moveTo(0, 0)
        cr lineTo(0, 50)
        cr relLineTo(50, 0)
        cr closePath()
        cr stroke()
    }

    /*
     * Free resources
     */
    free: func {
        // nothing to do here, but for text sprites etc., might be useful
    }

    absolutePos: Vec2 {
        get {
            if (parent) {
                // wtf but okay.
                pap := parent absolutePos
                if (!pap) pap = parent pos
                pap add(pos)
            } else {
                pos
            }
        }
    }

    containsPoint: func(point: Vec2) -> Bool {
        // override with your own implementation
        false
    }

    rectangleContains: func (min, max, point: Vec2) -> Bool {
        result := (min x <= point x && max x >= point x && min y <= point y && max y >= point y)
        //"is %s inside (%s, %s) ? %d" printfln(point _, min _, max _, result)
        result
    }
    
}

ImageSprite: class extends Sprite {

    tiled := false

    width  := -1
    height := -1

    path: String

    init: func ~ohshutuprock {}

    new: static func (pos: Vec2, path: String) -> This {
        if (!File new(path) exists?()) {
            Exception new("Image file %s doesn't exist! Aborting." format(path)) throw()
        }

        low := path toLower()
        if (low endsWith?(".png")) {
            PngSprite new(pos, path)
        } else {
            Exception new("Unknown image type (not PNG): %s" format(path)) throw()
            null
        }
    }

    paint: func (cr: Context) {
        if (tiled) {
            for (x in -3..3) {
                for (y in -3..3) {
                    cr save()
                    cr translate (x * (width - 1), y * (height - 1))
                    paintOnce(cr)
                    cr restore()
                }
            }
        } else {
            cr save()
            paintOnce(cr)
            cr restore()
        }
    }

    paintOnce: func (cr: Context) {
        cr setSourceRGB(1.0, 0.0, 0.0)
        cr setFontSize(80)
        cr showText("MISSING IMAGE %s" format(path))
    }

    containsPoint: func(point: Vec2) -> Bool {
        ap := absolutePos
        rectangleContains(ap, ap add(width, height), point)
    }

}

PngSprite: class extends ImageSprite {

    image: ImageSurface
    imageCache := static HashMap<String, ImageSurface> new()

    init: func (=pos, =path) {
        if(imageCache contains?(path)) {
            image = imageCache get(path)
        } else {
            image = ImageSurface new(path)
            logger debug("Loaded png asset %s (%dx%d)" format(path, image getWidth(), image getHeight()))
            imageCache put(path, image)
        }

        width  = image getWidth()
        height = image getHeight()
    }

    paintOnce: func (cr: Context) {
        cr setSourceSurface(image, 0, 0)
        cr rectangle(0, 0, width, height)
        cr clip()
        if (alpha == 1.0) {
            cr paint()
        } else {
            cr paintWithAlpha(alpha)
        }
    }

}


// initialize freetype
freetype: FTLibrary
freetype initFreeType()

/**
 * A label that displays text
 */
LabelSprite: class extends Sprite {

    text: String
    fontSize := 22.0

    font: FontFace
    path := "assets/fonts/impact.ttf"
    oldPath := ""
    cache := static HashMap<String, FontFace> new()

    centered := false

    init: func (=pos, =text) { }

    setText: func (=text) {}

    loadFont: func {
        version(!apple) {
            if (cache contains?(path)) {
                font = cache get(path)
            } else {
                logger debug("Loading font asset %s" format(path))
                ftFace: FTFace
                error := freetype newFace(path, 0, ftFace&)
                if (error) {
                    logger warn("Loading font failed, falling back on default font")
                } else {
                    font = newFontFromFreetype(ftFace, 0)
                    cache put(path, font)
                }
            }

            oldPath = path
        }
    }

    paint: func (cr: Context) {
        if (oldPath != path) loadFont()

        cr newSubPath()
        if (font) {
            cr setFontFace(font)
        } else {
            cr selectFontFace("Impact", CairoFontSlant NORMAL, CairoFontWeight NORMAL)
        }
        cr setFontSize(fontSize)

        if (centered) {
            extents: TextExtents
            cr textExtents(text, extents&)
            cr translate (-extents width / 2, extents height / 2)
        }

        cr showText(text)
    }

}

GroupSprite: class extends Sprite {

    children := ArrayList<Sprite> new()

    init: func {
        super(vec2(0, 0))
    }

    draw: func (display: Display) {
        if (!visible) return

        cr := display cairoContext

        cr save()
        cr translate(pos x + offset x, pos y + offset y)
        cr scale(scale x, scale y)

        children each(|child| child draw(display))
        cr restore()
    }

    add: func (s: Sprite) {
        children add(s)
        s parent = this
    }

}


LineSprite: class extends Sprite {

    start := vec2(0)
    end   := vec2(200)
    thickness := 3.0

    init: func {
        super(vec2(0))
    }

    paint: func (cr: Context) {
        cr setLineWidth(thickness)
        cr moveTo(start x, start y)
        cr lineTo(end x, end y)
        cr closePath()
        cr stroke()
    }

}


/**
 * A rectangle, initially a 1x1 square
 */
RectSprite: class extends Sprite {

    init: super func

    size := vec2(1.0, 1.0)
    filled := true
    thickness := 1.0

    paint: func (cr: Context) {
        halfWidth  := size x * 0.5
        halfHeight := size y * 0.5

        cr setLineWidth(thickness)
        cr moveTo(-halfWidth, -halfHeight)
        cr lineTo( halfWidth, -halfHeight)
        cr lineTo( halfWidth,  halfHeight)
        cr lineTo(-halfWidth,  halfHeight)
        cr closePath()
        if (filled) {
            cr fill()
        } else {
            cr stroke()
        }
    }

    containsPoint: func(point: Vec2) -> Bool {
        ap := absolutePos
        halfSize := size mul(0.5)
        rectangleContains(ap sub(halfSize), ap add(halfSize), point)
    }

}


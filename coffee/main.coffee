require.config
    # baseUrl: "js/"
    paths:
        jquery: "lib/jquery-1.9.1"
        goog: "/_ah/channel/jsapi?"
        backbone: "lib/backbone"
        underscore: "lib/underscore"
        kinetic: "lib/kinetic-v4.3.3"

    shim:
        goog:
            exports: "goog"
        paper:
            exports: "paper"
        underscore:
            exports: "_"

require ["kinetic", "jquery", "underscore"], (Kinetic, $, _) ->
    class Box
        constructor: (@x, @y, @height, @boxes, layer) ->
            @shape = new Kinetic.Rect
                fill: '#888'
                # shadowColor: '#000'
                # shadowBlur: 30

            layer.add @shape

            # @shape.on 'mouseover', (e) =>
            #     @setHeight 1
            #     @draw()

            # @shape.on 'mouseout', (e) =>
            #     @setHeight 0
            #     @releaseHeight()
            #     @draw()

            @speed = 0.2

            # @text = new Kinetic.Text
            #     text: "Test"
            #     fill: "red"
            #     align: "center"

            # layer.add @text

            @draw()

        reposition: (width, height) ->
            numX = @boxes.length
            numY = @boxes[0].length

            boxWidth = width / numX
            boxHeight = height / numY

            @shape.setPosition boxWidth * (@x + 0.5), boxHeight * (@y + 0.5)
            @shape.setSize boxWidth, boxHeight
            @shape.setOffset boxWidth / 2, boxHeight / 2

            # @text.setPosition boxWidth * (@x + 0.5), boxHeight * (@y + 0.5)
            # @text.setZIndex 10000

        go: (dt, heights) ->
            gotoHeight = 0

            if @hold
                gotoHeight = @gotoHeight
            else
                numNeighbors = 0

                for coord in [[@x-1, @y], [@x, @y-1], [@x+1, @y], [@x, @y+1]]
                    h = heights[coord[0]]?[coord[1]]

                    if h?
                        gotoHeight += h
                        numNeighbors += 1

                gotoHeight /= 4

            dh = gotoHeight - @height
            @height += dh * @speed
            # @height = Math.max(Math.min(@height, 1), 0)

            @draw()

        setHeight: (height) ->
            @gotoHeight = height
            @hold = true
            @draw()

        releaseHeight: ->
            @hold = false

        draw: ->
            @shape.setZIndex Math.floor(@height * 135)

            # if Math.floor(@height * 255) == 254
            #     console.log @shape.getZIndex(), @shape.getAbsoluteZIndex()
            #     console.log Math.floor(@height * 255), Math.floor(@boxes[@x+1][@y].height * 255), @

            color = Math.round @height * 255

            @shape.setFill "rgb(#{color}, #{color}, #{color})"

            @shape.setScale @height*1.5 + 0.5
            @shape.setShadowOpacity Math.max((@height * 2) - 1, 0.001)

            t = Math.max((@height * 2) - 1, 0)

            # @text.setText Math.floor(@height * 255)


    class Boxes
        constructor: ->
            @width = $(window).width()
            @height = $(window).height()

            @stage = new Kinetic.Stage
                container: "stage"
                width: @width
                height: @height

            @boxLayer = new Kinetic.Layer()

            @numX = 15
            @numY = 9

            @coords = []

            @boxes = []

            for x in [0...@numX]
                col = []
                for y in [0...@numY]
                    box = new Box(x, y, 1/3, @boxes, @boxLayer)
                    col.push box
                    @coords.push [x, y]
                @boxes.push col

            @stage.add @boxLayer

            @reposition()

            $(window).on "resize", @reposition

            @anim = new Kinetic.Animation ((frame) =>
                heights = ((@boxes[x][y].height for y in [0...@numY]) for x in [0...@numX])

                for coord in @coords
                    @boxes[coord[0]][coord[1]].go frame.timeDiff, heights
                ), @boxLayer

            @curHover = []

            $(window).on "mousemove mouseover", (e) =>
                x = Math.floor(@numX * e.clientX / @width)
                y = Math.floor(@numY * e.clientY / @height)

                @hover [[x, y]]

            $(window).on "mouseout", (e) =>
                @hover []

            $(window).on "touchstart touchmove touchend", (e) =>
                coords = []

                for touch in touches
                    x = Math.floor(@numX * touch.clientX / @width)
                    y = Math.floor(@numY * touch.clientY / @height)

                    coords.push [x, y]

                @hover coords

                e.preventDefault()

            @anim.start()

        hover: (coords) ->
            for c in @curHover
                @boxes[c[0]][c[1]].setHeight 0
                @boxes[c[0]][c[1]].releaseHeight()

            for c in coords
                @boxes[c[0]][c[1]].setHeight 1

            @curHover = coords

        reposition: =>
            @width = $(window).width()
            @height = $(window).height()

            @stage.setSize @width, @height

            for x in [0...@numX]
                for y in [0...@numY]
                    @boxes[x][y].reposition @width, @height

            @stage.draw()

    window.boxes = new Boxes()
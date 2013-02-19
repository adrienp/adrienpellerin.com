require.config
    # baseUrl: "js/"
    paths:
        # jquery: "lib/jquery-1.9.1"
        # goog: "/_ah/channel/jsapi?"
        # backbone: "lib/backbone"
        # underscore: "lib/underscore"
        # kinetic: "lib/kinetic-v4.3.3"

        kinetic: "http://cdnjs.cloudflare.com/ajax/libs/kineticjs/4.3.1/kinetic.min"
        underscore: "http://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.4/underscore-min"
        backbone: "http://cdnjs.cloudflare.com/ajax/libs/backbone.js/0.9.10/backbone-min.js"
        jquery: "http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min"

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
            @shape = new Kinetic.Circle
                fill: 'white'
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
            radius = (boxWidth + boxHeight) / 4

            @shape.setPosition boxWidth * (@x + 0.5), boxHeight * (@y + 0.5)
            # @shape.setSize boxWidth, boxHeight
            @shape.setRadius radius
            # @shape.setOffset boxWidth / 2, boxHeight / 2

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
            numBoxes = if @boxes.length == 0 then 0 else @boxes.length * @boxes[0].length
            @shape.setZIndex Math.floor(@height * numBoxes)

            # if Math.floor(@height * 255) == 254
            #     console.log @shape.getZIndex(), @shape.getAbsoluteZIndex()
            #     console.log Math.floor(@height * 255), Math.floor(@boxes[@x+1][@y].height * 255), @

            # color = Math.round @height * 255

            # @shape.setFill "rgb(#{color}, #{color}, #{color})"
            @shape.setOpacity @height

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

            @numX = Math.ceil(@width / 100)
            @numY = Math.ceil(@height / 100)

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
                if @autoMove
                    @autoMove.progress += frame.timeDiff / @autoMove.duration
                    if @autoMove.progress >= 1
                        @hover []
                        @autoMove = null
                    else
                        touchX = @autoMove.end.x * @autoMove.progress + @autoMove.start.x * (1 - @autoMove.progress)
                        touchY = @autoMove.end.y * @autoMove.progress + @autoMove.start.y * (1 - @autoMove.progress)

                        x = Math.floor(@numX * touchX / @width)
                        y = Math.floor(@numY * touchY / @height)

                        @hover [[x, y]]

                heights = ((@boxes[x][y].height for y in [0...@numY]) for x in [0...@numX])

                for coord in @coords
                    @boxes[coord[0]][coord[1]].go frame.timeDiff, heights
                ), @boxLayer

            @curHover = []

            $(window).on "mousemove mouseover", (e) =>
                @autoMove = null

                x = Math.floor(@numX * e.clientX / @width)
                y = Math.floor(@numY * e.clientY / @height)

                @hover [[x, y]]

            $(window).on "mouseout", (e) =>
                @hover []

            $(window).on "touchstart touchmove touchend", (e) =>
                coords = []
                @autoMove = null

                for touch in e.originalEvent.touches
                    x = Math.floor(@numX * touch.clientX / @width)
                    y = Math.floor(@numY * touch.clientY / @height)

                    coords.push [x, y] if x >= 0 and y >= 0

                @hover coords

                e.preventDefault()

            @anim.start()

            setTimeout(@auto, 5000)

        auto: =>
            if @curHover.length == 0
                side = (n) =>
                    if n < 1
                        x: @width * n
                        y: 0
                    else if n < 2
                        x: @width
                        y: @height * (n - 1)
                    else if n < 3
                        x: @width * (3 - n)
                        y: @height
                    else
                        x: 0
                        y: @height * (4 - n)

                start = Math.random() * 4
                end = ((Math.random() * 2) + 1 + start) % 4
                console.log start, side(start), end, side(end)
                start = side(start)

                end = side(end)

                @autoMove =
                    start: start
                    end: end
                    duration: 1000
                    progress: 0

            setTimeout(@auto, Math.random() * 8000 + 5000)

        hover: (coords) ->
            for c in @curHover
                @boxes[c[0]]?[c[1]]?.setHeight 0
                @boxes[c[0]]?[c[1]]?.releaseHeight()

            for c in coords
                @boxes[c[0]]?[c[1]]?.setHeight 1

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
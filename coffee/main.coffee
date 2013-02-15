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

require ["kinetic"], (Kinetic) ->
    stage = new Kinetic.Stage
        container: "stage"

    layer = new Kinetic.Layer()

    rect = new Kinetic.Rect
        x: 200
        y: 75
        width: 100
        height: 50
        fill: 'green'
        stroke: 'black'
        strokeWidth: 4

    layer.add rect
    stage.add layer
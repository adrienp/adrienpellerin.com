// Generated by CoffeeScript 1.3.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  require.config({
    paths: {
      kinetic: "http://cdnjs.cloudflare.com/ajax/libs/kineticjs/4.3.1/kinetic.min",
      underscore: "http://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.4/underscore-min",
      backbone: "http://cdnjs.cloudflare.com/ajax/libs/backbone.js/0.9.10/backbone-min.js",
      jquery: "http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min"
    },
    shim: {
      goog: {
        exports: "goog"
      },
      paper: {
        exports: "paper"
      },
      underscore: {
        exports: "_"
      }
    }
  });

  require(["kinetic", "jquery", "underscore"], function(Kinetic, $, _) {
    var Box, Boxes;
    Box = (function() {

      function Box(x, y, height, boxes, layer) {
        this.x = x;
        this.y = y;
        this.height = height;
        this.boxes = boxes;
        this.shape = new Kinetic.Circle({
          fill: 'white'
        });
        layer.add(this.shape);
        this.speed = 0.2;
        this.draw();
      }

      Box.prototype.reposition = function(width, height) {
        var boxHeight, boxWidth, numX, numY, radius;
        numX = this.boxes.length;
        numY = this.boxes[0].length;
        boxWidth = width / numX;
        boxHeight = height / numY;
        radius = (boxWidth + boxHeight) / 4;
        this.shape.setPosition(boxWidth * (this.x + 0.5), boxHeight * (this.y + 0.5));
        return this.shape.setRadius(radius);
      };

      Box.prototype.go = function(dt, heights) {
        var coord, dh, gotoHeight, h, numNeighbors, _i, _len, _ref, _ref1;
        gotoHeight = 0;
        if (this.hold) {
          gotoHeight = this.gotoHeight;
        } else {
          numNeighbors = 0;
          _ref = [[this.x - 1, this.y], [this.x, this.y - 1], [this.x + 1, this.y], [this.x, this.y + 1]];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            coord = _ref[_i];
            h = (_ref1 = heights[coord[0]]) != null ? _ref1[coord[1]] : void 0;
            if (h != null) {
              gotoHeight += h;
              numNeighbors += 1;
            }
          }
          gotoHeight /= 4;
        }
        dh = gotoHeight - this.height;
        this.height += dh * this.speed;
        return this.draw();
      };

      Box.prototype.setHeight = function(height) {
        this.gotoHeight = height;
        this.hold = true;
        return this.draw();
      };

      Box.prototype.releaseHeight = function() {
        return this.hold = false;
      };

      Box.prototype.draw = function() {
        var numBoxes, t;
        numBoxes = this.boxes.length === 0 ? 0 : this.boxes.length * this.boxes[0].length;
        this.shape.setZIndex(Math.floor(this.height * numBoxes));
        this.shape.setOpacity(this.height);
        this.shape.setScale(this.height * 1.5 + 0.5);
        this.shape.setShadowOpacity(Math.max((this.height * 2) - 1, 0.001));
        return t = Math.max((this.height * 2) - 1, 0);
      };

      return Box;

    })();
    Boxes = (function() {

      function Boxes() {
        this.reposition = __bind(this.reposition, this);

        this.auto = __bind(this.auto, this);

        var box, col, x, y, _i, _j, _ref, _ref1,
          _this = this;
        this.width = $(window).width();
        this.height = $(window).height();
        this.stage = new Kinetic.Stage({
          container: "stage",
          width: this.width,
          height: this.height
        });
        this.boxLayer = new Kinetic.Layer();
        this.numX = Math.ceil(this.width / 100);
        this.numY = Math.ceil(this.height / 100);
        this.coords = [];
        this.boxes = [];
        for (x = _i = 0, _ref = this.numX; 0 <= _ref ? _i < _ref : _i > _ref; x = 0 <= _ref ? ++_i : --_i) {
          col = [];
          for (y = _j = 0, _ref1 = this.numY; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
            box = new Box(x, y, 1 / 3, this.boxes, this.boxLayer);
            col.push(box);
            this.coords.push([x, y]);
          }
          this.boxes.push(col);
        }
        this.stage.add(this.boxLayer);
        this.reposition();
        $(window).on("resize", this.reposition);
        this.anim = new Kinetic.Animation((function(frame) {
          var coord, heights, touchX, touchY, _k, _len, _ref2, _results;
          if (_this.autoMove) {
            _this.autoMove.progress += frame.timeDiff / _this.autoMove.duration;
            if (_this.autoMove.progress >= 1) {
              _this.hover([]);
              _this.autoMove = null;
            } else {
              touchX = _this.autoMove.end.x * _this.autoMove.progress + _this.autoMove.start.x * (1 - _this.autoMove.progress);
              touchY = _this.autoMove.end.y * _this.autoMove.progress + _this.autoMove.start.y * (1 - _this.autoMove.progress);
              x = Math.floor(_this.numX * touchX / _this.width);
              y = Math.floor(_this.numY * touchY / _this.height);
              _this.hover([[x, y]]);
            }
          }
          heights = (function() {
            var _k, _ref2, _results;
            _results = [];
            for (x = _k = 0, _ref2 = this.numX; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; x = 0 <= _ref2 ? ++_k : --_k) {
              _results.push((function() {
                var _l, _ref3, _results1;
                _results1 = [];
                for (y = _l = 0, _ref3 = this.numY; 0 <= _ref3 ? _l < _ref3 : _l > _ref3; y = 0 <= _ref3 ? ++_l : --_l) {
                  _results1.push(this.boxes[x][y].height);
                }
                return _results1;
              }).call(this));
            }
            return _results;
          }).call(_this);
          _ref2 = _this.coords;
          _results = [];
          for (_k = 0, _len = _ref2.length; _k < _len; _k++) {
            coord = _ref2[_k];
            _results.push(_this.boxes[coord[0]][coord[1]].go(frame.timeDiff, heights));
          }
          return _results;
        }), this.boxLayer);
        this.curHover = [];
        $(window).on("mousemove mouseover", function(e) {
          _this.autoMove = null;
          x = Math.floor(_this.numX * e.clientX / _this.width);
          y = Math.floor(_this.numY * e.clientY / _this.height);
          return _this.hover([[x, y]]);
        });
        $(window).on("mouseout", function(e) {
          return _this.hover([]);
        });
        $(window).on("touchstart touchmove touchend", function(e) {
          var coords, touch, _k, _len, _ref2;
          coords = [];
          _this.autoMove = null;
          _ref2 = e.originalEvent.touches;
          for (_k = 0, _len = _ref2.length; _k < _len; _k++) {
            touch = _ref2[_k];
            x = Math.floor(_this.numX * touch.clientX / _this.width);
            y = Math.floor(_this.numY * touch.clientY / _this.height);
            if (x >= 0 && y >= 0) {
              coords.push([x, y]);
            }
          }
          _this.hover(coords);
          return e.preventDefault();
        });
        this.anim.start();
        setTimeout(this.auto, 5000);
      }

      Boxes.prototype.auto = function() {
        var end, side, start,
          _this = this;
        if (this.curHover.length === 0) {
          side = function(n) {
            if (n < 1) {
              return {
                x: _this.width * n,
                y: 0
              };
            } else if (n < 2) {
              return {
                x: _this.width,
                y: _this.height * (n - 1)
              };
            } else if (n < 3) {
              return {
                x: _this.width * (3 - n),
                y: _this.height
              };
            } else {
              return {
                x: 0,
                y: _this.height * (4 - n)
              };
            }
          };
          start = Math.random() * 4;
          end = ((Math.random() * 2) + 1 + start) % 4;
          console.log(start, side(start), end, side(end));
          start = side(start);
          end = side(end);
          this.autoMove = {
            start: start,
            end: end,
            duration: 1000,
            progress: 0
          };
        }
        return setTimeout(this.auto, Math.random() * 8000 + 5000);
      };

      Boxes.prototype.hover = function(coords) {
        var c, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
        _ref = this.curHover;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          if ((_ref1 = this.boxes[c[0]]) != null) {
            if ((_ref2 = _ref1[c[1]]) != null) {
              _ref2.setHeight(0);
            }
          }
          if ((_ref3 = this.boxes[c[0]]) != null) {
            if ((_ref4 = _ref3[c[1]]) != null) {
              _ref4.releaseHeight();
            }
          }
        }
        for (_j = 0, _len1 = coords.length; _j < _len1; _j++) {
          c = coords[_j];
          if ((_ref5 = this.boxes[c[0]]) != null) {
            if ((_ref6 = _ref5[c[1]]) != null) {
              _ref6.setHeight(1);
            }
          }
        }
        return this.curHover = coords;
      };

      Boxes.prototype.reposition = function() {
        var x, y, _i, _j, _ref, _ref1;
        this.width = $(window).width();
        this.height = $(window).height();
        this.stage.setSize(this.width, this.height);
        for (x = _i = 0, _ref = this.numX; 0 <= _ref ? _i < _ref : _i > _ref; x = 0 <= _ref ? ++_i : --_i) {
          for (y = _j = 0, _ref1 = this.numY; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
            this.boxes[x][y].reposition(this.width, this.height);
          }
        }
        return this.stage.draw();
      };

      return Boxes;

    })();
    return window.boxes = new Boxes();
  });

}).call(this);

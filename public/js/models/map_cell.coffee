class App.MapCell

  constructor: ->
    @set.apply this, arguments

  set: (row, col, char, mesh) ->
    @row = row
    @col = col
    @char = char
    @mesh = mesh
    this

{CompositeDisposable} = require 'atom'

module.exports =
class SelectionHighlighterView
  constructor: (serializedState) ->
    @subscribeToTextEditor()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Get the current text editor
  getActiveEditor: ->
    atom.workspace.getActiveTextEditor()

  # Hightlight the selection(s)
  highlightSelection: ->
    console.log("highlight")

    editor = @getActiveEditor()

    ranges = editor.getSelectedBufferRanges()

    for range in ranges
      console.log(range, range.isEmpty())
      unless range.isEmpty()
        console.log("make marker")
        @el = document.createElement 'div'
        @el.textContent = " :) "
        marker = editor.markBufferRange(range)
        marker.setProperties({foo: true})
        decoration = editor.decorateMarker(marker, {type: 'overlay', class: 'selection-highlighted', item: @el})


  #Handle a debounced selection change
  handleSelectionChange: =>
    clearTimeout(@handleSelectionTimeout)
    @handleSelectionTimeout = setTimeout =>
      @resetSelection()
      @highlightSelection()
    , 100

  # Subscribe to editor events
  subscribeToTextEditor: ->
    editor = @getActiveEditor()

    @subscriptions = new CompositeDisposable
    @subscriptions.add editor.onDidChangeSelectionRange @handleSelectionChange

  # Reset the selection(s)
  resetSelection: ->
    console.log("reset")
    # Destroy markers
    editor = @getActiveEditor()
    console.log(editor.getMarkerCount())
    for marker in editor.findMarkers({foo: true})
      console.log('marker: ', marker)
      marker.destroy()

  # Tear down any state and detach
  destroy: ->
    clearTimeout(@handleSelectionTimeout)
    @resetSelection()
    @subscriptions.dispose()

  highlight: ->
    @highlightSelection()

  reset: ->
    @resetSelection()

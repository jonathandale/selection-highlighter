{CompositeDisposable} = require 'atom'
_ = require 'underscore-plus'

module.exports =
class SelectionHighlighterView
  constructor: (serializedState) ->
    @active = false
    @subscribeToTextEditor()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Get the current text editor
  getActiveEditor: ->
    atom.workspace.getActiveTextEditor()

  # Hightlight the selection(s)
  highlightSelection: ->
    editor = @getActiveEditor()
    ranges = editor.getSelectedBufferRanges()
    lineHeight = editor.getLineHeightInPixels()
    allRows = [0..editor.getLineCount()]
    selected = _.flatten _.map ranges, (range) -> range.getRows() unless range.isEmpty()
    selectedRows = _.reject selected, _.isUndefined
    nonSelectedRows = if selectedRows.length then _.difference allRows, selectedRows

    if selectedRows
      for rowNum in selectedRows
        marker = editor.markBufferRange([[rowNum, 0], [rowNum, 1]])
        marker.setProperties({rowTinted: true})
        decoration = editor.decorateMarker(marker, {type: 'line', class: 'selected-line'})

    if nonSelectedRows
      for rowNum in nonSelectedRows
        marker = editor.markBufferRange([[rowNum, 0], [rowNum, 1]])
        marker.setProperties({rowTinted: true})
        decoration = editor.decorateMarker(marker, {type: 'line', class: 'line-tint-1'})

  #Handle a debounced selection change
  handleSelectionChange: =>
    if @active
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
    # Destroy markers
    editor = @getActiveEditor()
    for marker in editor.findMarkers({rowTinted: true})
      marker.destroy()

  # Tear down any state and detach
  destroy: ->
    clearTimeout(@handleSelectionTimeout)
    @resetSelection()
    @subscriptions.dispose()

  highlight: ->
    console.log("active")
    @active = true
    @highlightSelection()

  reset: ->
    console.log("inactive")
    @active = false
    @resetSelection()

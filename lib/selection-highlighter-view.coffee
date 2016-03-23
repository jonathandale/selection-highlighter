{CompositeDisposable} = require 'atom'
_ = require 'underscore-plus'

module.exports =
class SelectionHighlighterView
  constructor: (serializedState) ->
    @active = false
    @subscribeToTextEditor()

  # Get the current text editor
  getActiveEditor: ->
    atom.workspace.getActiveTextEditor()

  # Get row count, adjusting for when a full line selection
  getRows: (range) =>
    rows = range.getRows()
    if range.end.column is 0 then _.initial rows else rows

  # Hightlight the selection(s)
  highlightSelection: ->
    editor = @getActiveEditor()
    ranges = editor.getSelectedBufferRanges()
    lineHeight = editor.getLineHeightInPixels()
    allRows = [0..editor.getLineCount()]
    selected = _.flatten _.map ranges, (range) => @getRows(range) unless range.isEmpty()
    selectedRows = _.reject selected, _.isUndefined # filter out undefineds — empty selections
    nonSelectedRows = if selectedRows.length then _.difference allRows, selectedRows

    # For each row, make new marker and add class
    styleRow = (classname) ->
      marker = editor.markBufferRange([[rowNum, 0], [rowNum, 1]])
      marker.setProperties({sHighlighter: true}) # Give marker a property to tear down later
      decoration = editor.decorateMarker(marker, {type: 'line', class: classname})

    if selectedRows
      for rowNum in selectedRows
        styleRow('selected-line')

    if nonSelectedRows
      for rowNum in nonSelectedRows
        styleRow('line-tint-' + atom.config.get('selection-highlighter.opacityAmount'))

  # Handle a debounced selection change
  handleSelectionChange: =>
    if @active
      clearTimeout(@handleSelectionTimeout)
      @handleSelectionTimeout = setTimeout =>
        @resetSelection()
        @highlightSelection()
      , 150 # Arbitrary time, consider config value?

  # Subscribe to editor events
  subscribeToTextEditor: ->
    editor = @getActiveEditor()
    @subscriptions = new CompositeDisposable
    @subscriptions.add editor.onDidChangeSelectionRange @handleSelectionChange

  # Reset the selection(s)
  resetSelection: ->
    # Destroy markers
    editor = @getActiveEditor()
    for marker in editor.findMarkers({sHighlighter: true})
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

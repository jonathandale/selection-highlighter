SelectionHighlighterView = require './selection-highlighter-view'
{CompositeDisposable} = require 'atom'

module.exports = SelectionHighlighter =
  selectionHighlighterView: null
  subscriptions: null
  toggled: false

  config:
    opacityAmount:
      title: 'Opacity of non-selected lines'
      description: 'Choose a value from 0 - 9. 0 is hidden. 9 is almost full opacity.'
      type: 'integer'
      default: 2
      minimum: 0
      maximum: 9

  activate: (state) ->
    console.log("activate")
    @selectionHighlighterView = new SelectionHighlighterView(state.selectionHighlighterViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'selection-highlighter:toggle': => @toggle()

  deactivate: ->
    console.log("deactivate")
    @subscriptions.dispose()
    @selectionHighlighterView.destroy()

  toggle: ->
    if @toggled
      @selectionHighlighterView.reset()
      @toggled = false
    else
      @selectionHighlighterView.highlight()
      @toggled = true

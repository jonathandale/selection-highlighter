SelectionHighlighterView = require './selection-highlighter-view'
{CompositeDisposable} = require 'atom'

module.exports = SelectionHighlighter =
  selectionHighlighterView: null
  subscriptions: null
  toggled: false

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

SelectionHighlighterView = require './selection-highlighter-view'
{CompositeDisposable} = require 'atom'

module.exports = SelectionHighlighter =
  selectionHighlighterView: null
  subscriptions: null
  toggled: false
  active: false

  config:
    opacityAmount:
      title: 'Opacity of non-selected lines'
      description: 'Choose a value from 0 - 9. 0 is hidden. 9 is almost full opacity.'
      type: 'integer'
      default: 2
      minimum: 0
      maximum: 9
    showIcon:
      title: 'Show icon in status bar when active'
      type: 'boolean'
      default: true

  activate: (state) ->
    console.log("activate selection highlighter", state)
    @selectionHighlighterView = new SelectionHighlighterView(state.selectionHighlighterViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'selection-highlighter:toggle': => @toggle()

  consumeStatusBar: (statusBar) ->
    @statusBar = statusBar
    @active = true
    @toggle()

  deactivate: ->
    console.log("deactivate selection highlighter")
    @subscriptions.dispose()
    @selectionHighlighterView.destroy()
    @destroyIcon

  showIcon: ->
    el = document.createElement('div')
    el.classList.add('highlighter-icon')
    @statusBarTile = @statusBar.addRightTile(item: el, priority: 1000)

  destroyIcon: ->
    @statusBarTile?.destroy()
    @statusBarTile = null

  toggle: ->
    if @active
      if @toggled
        @selectionHighlighterView.reset()
        @toggled = false
        if atom.config.get('selection-highlighter.showIcon')
          @destroyIcon()
      else
        @selectionHighlighterView.highlight()
        @toggled = true
        if atom.config.get('selection-highlighter.showIcon')
          @showIcon()

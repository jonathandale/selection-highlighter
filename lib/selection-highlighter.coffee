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
    showIcon:
      title: 'Show icon in status bar'
      type: 'boolean'
      default: true

  activate: (state) ->
    @selectionHighlighterView = new SelectionHighlighterView(state.selectionHighlighterViewState)
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'selection-highlighter:toggle': => @toggle()

  consumeStatusBar: (statusBar) ->
    @statusBar = statusBar
    if atom.config.get('selection-highlighter.showIcon')
      @createIcon()

  deactivate: ->
    @subscriptions.dispose()
    @selectionHighlighterView.destroy()
    if atom.config.get('selection-highlighter.showIcon')
      @destroyIcon()

  createIcon: ->
    @el = document.createElement('a')
    @el.classList.add('highlighter-icon')

    @el.addEventListener "click", () => @toggle()

    @statusBarTile = @statusBar.addRightTile(item: @el, priority: 1000)

  setIconStatus: (change) ->
    if atom.config.get('selection-highlighter.showIcon')
      @icon = document.querySelector('.highlighter-icon')
      @icon.classList[change]('active')

  destroyIcon: ->
    @statusBarTile?.destroy()
    @statusBarTile = null

  toggle: ->
    if @toggled
      @setIconStatus('remove')
      @selectionHighlighterView.reset()
      @toggled = false
    else
      @setIconStatus('add')
      @selectionHighlighterView.highlight()
      @toggled = true

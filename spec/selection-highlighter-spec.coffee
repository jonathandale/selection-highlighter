SelectionHighlighter = require '../lib/selection-highlighter'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "SelectionHighlighter", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('selection-highlighter')

  describe "when the selection-highlighter:toggle event is triggered", ->
    it "hides and shows the modal panel", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.selection-highlighter')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'selection-highlighter:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.selection-highlighter')).toExist()

        selectionHighlighterElement = workspaceElement.querySelector('.selection-highlighter')
        expect(selectionHighlighterElement).toExist()

        selectionHighlighterPanel = atom.workspace.panelForItem(selectionHighlighterElement)
        expect(selectionHighlighterPanel.isVisible()).toBe true
        atom.commands.dispatch workspaceElement, 'selection-highlighter:toggle'
        expect(selectionHighlighterPanel.isVisible()).toBe false

    it "hides and shows the view", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.selection-highlighter')).not.toExist()

      # This is an activation event, triggering it causes the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'selection-highlighter:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        # Now we can test for view visibility
        selectionHighlighterElement = workspaceElement.querySelector('.selection-highlighter')
        expect(selectionHighlighterElement).toBeVisible()
        atom.commands.dispatch workspaceElement, 'selection-highlighter:toggle'
        expect(selectionHighlighterElement).not.toBeVisible()

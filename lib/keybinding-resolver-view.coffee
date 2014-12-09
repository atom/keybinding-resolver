{Disposable, CompositeDisposable} = require 'atom'
{$$, View} = require 'space-pen'

module.exports =
class KeyBindingResolverView extends View
  @content: ->
    @div class: 'key-binding-resolver tool-panel pannel panel-bottom padding', =>
      @div class: 'panel-heading padded', =>
        @span 'Key Binding Resolver: '
        @span outlet: 'keystroke', 'Press any key'
      @div outlet: 'commands', class: 'panel-body padded'

  initialize: ({attached})->
    @attach() if attached

    @on 'click', '.source', (event) -> atom.workspace.open(event.target.innerText)

  serialize: ->
    attached: @hasParent()

  destroy: ->
    @detach()

  toggle: ->
    if @panel?.isVisible()
      @detach()
    else
      @attach()

  attach: ->
    @disposables = new CompositeDisposable

    @panel = atom.workspace.addBottomPanel(item: this)
    @disposables.add new Disposable =>
      @panel.destroy()
      @panel = null

    @disposables.add atom.keymap.onDidMatchBinding ({keystrokes, binding, keyboardEventTarget}) =>
      @update(keystrokes, binding, keyboardEventTarget)

    @disposables.add atom.keymap.onDidPartiallyMatchBindings ({keystrokes, partiallyMatchedBindings, keyboardEventTarget}) =>
      @updatePartial(keystrokes, partiallyMatchedBindings)

    @disposables.add atom.keymap.onDidFailToMatchBinding ({keystrokes, keyboardEventTarget}) =>
      @update(keystrokes, null, keyboardEventTarget)

  detach: ->
    @disposables.dispose()

  update: (keystrokes, keyBinding, keyboardEventTarget) ->
    @keystroke.html $$ ->
      @span class: 'keystroke', keystrokes

    unusedKeyBindings = atom.keymap.findKeyBindings({keystrokes, target: keyboardEventTarget}).filter (binding) ->
      binding != keyBinding

    unmatchedKeyBindings = atom.keymap.findKeyBindings({keystrokes}).filter (binding) ->
      binding != keyBinding and binding not in unusedKeyBindings

    @commands.html $$ ->
      @table class: 'table-condensed', =>
        if keyBinding
          @tr class: 'used', =>
            @td class: 'command', keyBinding.command
            @td class: 'selector', keyBinding.selector
            @td class: 'source', keyBinding.source

        for binding in unusedKeyBindings
          @tr class: 'unused', =>
            @td class: 'command', binding.command
            @td class: 'selector', binding.selector
            @td class: 'source', binding.source

        for binding in unmatchedKeyBindings
          @tr class: 'unmatched', =>
            @td class: 'command', binding.command
            @td class: 'selector', binding.selector
            @td class: 'source', binding.source

  updatePartial: (keystrokes, keyBindings) ->
    @keystroke.html $$ ->
      @span class: 'keystroke', "#{keystrokes} (partial)"

    @commands.html $$ ->
      @table class: 'table-condensed', =>
        for binding in keyBindings
          @tr class: 'unused', =>
            @td class: 'command', binding.command
            @td class: 'keystrokes', binding.keystrokes
            @td class: 'selector', binding.selector
            @td class: 'source', binding.source

_ = require 'underscore-plus'
{$, $$, View} = require 'atom'
Humanize = require 'humanize-plus'

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

    atom.workspaceView.command 'key-binding-resolver:toggle', => @toggle()
    atom.workspaceView.command 'core:cancel core:close', => @detach()

    @on 'click', '.source', (event) -> atom.workspaceView.open(event.target.innerText)

  serialize: ->
    attached: @hasParent()

  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      @attach()

  attach: ->
    atom.workspaceView.prependToBottom(this)
    @subscribe atom.keymap, "matched", ({keystrokes, binding, keyboardEventTarget}) =>
      @update(keystrokes, binding, keyboardEventTarget)

    @subscribe atom.keymap, "matched-partially", ({keystrokes, partiallyMatchedBindings, keyboardEventTarget}) =>
      @updatePartial(keystrokes, partiallyMatchedBindings)

    @subscribe atom.keymap, "match-failed", ({keystrokes, keyboardEventTarget}) =>
      @update(keystrokes, null, keyboardEventTarget)

  detach: ->
    super
    @unsubscribe()

  update: (keystrokes, keyBinding, keyboardEventTarget) ->
    @keystroke.html $$ ->
      @span class: 'keystroke', keystrokes

    unusedKeyBindings = atom.keymap.findKeyBindings({keystrokes, target: keyboardEventTarget}).filter (binding) ->
      binding != keyBinding

    unmatchedKeyBindings = atom.keymap.findKeyBindings({keystrokes}).filter (binding) ->
      binding != keyBinding and keyBinding not in unusedKeyBindings

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

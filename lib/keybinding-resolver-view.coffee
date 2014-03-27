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
    @subscribe atom.keymap, "key-binding-triggered", (keyBinding, alternativeKeyBindings) =>
      @update(keyBinding, alternativeKeyBindings)

    @subscribe atom.keymap, "parital-key-bindings-triggered", (keystrokes, keyBindings) =>
      @updatePartial(keystrokes, keyBindings)

    @subscribe atom.keymap, "no-key-bindings-triggered", (keystrokes) =>
      @keystroke.html $$ -> @span class: 'keystroke', "#{keystrokes}"
      @commands.empty()

  detach: ->
    super

  update: (usedKeyBinding, alternativeKeyBindings) ->
    @keystroke.html $$ ->
      @span class: 'keystroke', usedKeyBinding.keystrokes

    @commands.html $$ ->
      @table class: 'table-condensed', =>

        @tr class: 'matched selected text-success', =>
          @td class: 'command', usedKeyBinding.command
          @td class: 'selector', usedKeyBinding.selector
          @td class: 'source', usedKeyBinding.source

        for keyBinding in alternativeKeyBindings
          @tr class: 'unmatched text-subtle', =>
            @td class: 'command', keyBinding.command
            @td class: 'selector', keyBinding.selector
            @td class: 'source', keyBinding.source

  updatePartial: (keystrokes, keyBindings) ->
    @keystroke.html $$ ->
      @span class: 'keystroke', "#{keystrokes} (partial)"

    @commands.html $$ ->
      @table class: 'table-condensed', =>
        for keyBinding in keyBindings
          @tr class: 'unmatched text-subtle', =>
            @td class: 'command', keyBinding.command
            @td class: 'keystrokes', keyBinding.keystrokes
            @td class: 'selector', keyBinding.selector
            @td class: 'source', keyBinding.source

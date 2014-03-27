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
    @subscribe atom.keymap, "key-binding-matched", (usedKeyBinding, unusedKeyBindings) =>
      @update(usedKeyBinding, unusedKeyBindings)

    @subscribe atom.keymap, "parital-key-bindings-matched", (keystrokes, keyBindings) =>
      @updatePartial(keystrokes, keyBindings)

    @subscribe atom.keymap, "no-key-binding-matched", (keystrokes) =>
      @keystroke.html $$ -> @span class: 'keystroke', "#{keystrokes}"
      @commands.empty()

  detach: ->
    super
    @unsubscribe()

  update: (usedKeyBinding, unusedKeyBindings) ->
    @keystroke.html $$ ->
      @span class: 'keystroke', usedKeyBinding.keystrokes

    @commands.html $$ ->
      @table class: 'table-condensed', =>
        @tr class: 'used', =>
          @td class: 'command', usedKeyBinding.command
          @td class: 'selector', usedKeyBinding.selector
          @td class: 'source', usedKeyBinding.source

        for keyBinding in unusedKeyBindings
          @tr class: 'unused', =>
            @td class: 'command', keyBinding.command
            @td class: 'selector', keyBinding.selector
            @td class: 'source', keyBinding.source

        matchedKeyBindings = atom.keymap.findKeyBindings(keystrokes: usedKeyBinding.keystrokes)
        matchedKeyBindings = matchedKeyBindings.filter (keyBinding) ->
          keyBinding != usedKeyBinding and keyBinding not in unusedKeyBindings

        for keyBinding in matchedKeyBindings
          @tr class: 'unmatched', =>
            @td class: 'command', keyBinding.command
            @td class: 'selector', keyBinding.selector
            @td class: 'source', keyBinding.source

  updatePartial: (keystrokes, keyBindings) ->
    @keystroke.html $$ ->
      @span class: 'keystroke', "#{keystrokes} (partial)"

    @commands.html $$ ->
      @table class: 'table-condensed', =>
        for keyBinding in keyBindings
          @tr class: 'unused', =>
            @td class: 'command', keyBinding.command
            @td class: 'keystrokes', keyBinding.keystrokes
            @td class: 'selector', keyBinding.selector
            @td class: 'source', keyBinding.source

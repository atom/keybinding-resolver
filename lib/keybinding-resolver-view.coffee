_ = require 'underscore-plus'
{$, $$, View} = require 'atom'
Humanize = require 'humanize-plus'

module.exports =
class KeybindingResolverView extends View
  @content: ->
    @div class: 'keybinding-resolver tool-panel pannel panel-bottom padding', =>
      @div class: 'panel-heading padded', =>
        @span 'Keybinding Resolver: '
        @span outlet: 'keystroke', 'Press any key'
      @div outlet: 'commands', class: 'panel-body padded'

  initialize: ({attached})->
    @attach() if attached

    atom.workspaceView.command 'keybinding-resolver:toggle', => @toggle()
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
    @subscribe atom.keymap, "keybinding-triggered", (keybinding, alternativeKeybindings) =>
      @update(keybinding, alternativeKeybindings)

  detach: ->
    super

  update: (usedKeybinding, alternativeKeybindings) ->
    @keystroke.html $$ ->
      @span class: 'keystroke', usedKeybinding.keystrokes

    @commands.html $$ ->
      @table class: 'table-condensed', =>
        @tr class: 'matched selected text-success', =>
          @td class: 'command', usedKeybinding.command
          @td class: 'selector', usedKeybinding.selector
          @td class: 'source', usedKeybinding.source

        for keybinding in alternativeKeybindings
          @tr class: 'unmatched text-subtle', =>
            @td class: 'command', keybinding.command
            @td class: 'selector', keybinding.selector
            @td class: 'source', keybinding.source

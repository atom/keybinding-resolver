module.exports =
  keybindingResolverView: null

  activate: ({attached}={}) ->
    @createView().toggle() if attached
    atom.commands.add 'atom-workspace',
      'key-binding-resolver:toggle': => @createView().toggle()
      'core:cancel': => @createView().detach()
      'core:close': => @createView().detach()

  createView: ->
    unless @keybindingResolverView?
      KeyBindingResolverView = require './keybinding-resolver-view'
      @keybindingResolverView = new KeyBindingResolverView()
    @keybindingResolverView

  deactivate: ->
    @keybindingResolverView?.destroy()

  serialize: ->
    @keybindingResolverView?.serialize()

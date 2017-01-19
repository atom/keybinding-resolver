KeyBindingResolverView = require './keybinding-resolver-view'

module.exports =
  keybindingResolverView: null

  activate: ({attached}={}) ->
    @createView().toggle() if attached
    atom.commands.add 'atom-workspace',
      'key-binding-resolver:toggle': => @createView().toggle()
      'core:cancel': => @createView().detach()
      'core:close': => @createView().detach()

  createView: ->
    @keybindingResolverView ?= new KeyBindingResolverView()

  deactivate: ->
    @keybindingResolverView?.destroy()

  serialize: ->
    @keybindingResolverView?.serialize()

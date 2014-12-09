KeyBindingResolverView = require './keybinding-resolver-view'

module.exports =
  keybindingResolverView: null

  activate: (state) ->
    @keybindingResolverView = new KeyBindingResolverView(state)
    atom.commands.add 'atom-workspace',
      'key-binding-resolver:toggle': => @keybindingResolverView.toggle()
      'core:cancel core:close': => @keybindingResolverView.detach()

  deactivate: ->
    @keybindingResolverView.destroy()

  serialize: ->
    @keybindingResolverView.serialize()

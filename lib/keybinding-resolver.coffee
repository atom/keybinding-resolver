KeyBindingResolverView = require './keybinding-resolver-view'

module.exports =
  keybindingResolverView: null

  activate: (state) ->
    @keybindingResolverView = new KeyBindingResolverView(state)

  deactivate: ->
    @keybindingResolverView.destroy()

  serialize: ->
    @keybindingResolverView.serialize()

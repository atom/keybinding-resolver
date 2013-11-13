KeybindingResolverView = require './keybinding-resolver-view'

module.exports =
  keybindingResolverView: null

  activate: (state) ->
    @keybindingResolverView = new KeybindingResolverView(state)

  deactivate: ->
    @keybindingResolverView.destroy()

  serialize: ->
    @keybindingResolverView.serialize()

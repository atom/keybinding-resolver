KeybindingResolverView = require '../lib/keybinding-resolver-view'
{RootView} = require 'atom'

describe "KeybindingResolverView", ->
  keybindingResolver = null

  beforeEach ->
    window.rootView = new RootView
    keybindingResolver = atom.activatePackage('keybindingResolver', immediate: true)

  describe "when the keybinding-resolver:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(rootView.find('.keybinding-resolver')).not.toExist()
      rootView.trigger 'keybinding-resolver:toggle'
      expect(rootView.find('.keybinding-resolver')).toExist()
      rootView.trigger 'keybinding-resolver:toggle'
      expect(rootView.find('.keybinding-resolver')).not.toExist()

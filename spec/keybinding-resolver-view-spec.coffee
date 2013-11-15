KeybindingResolverView = require '../lib/keybinding-resolver-view'
{$, RootView} = require 'atom'

describe "KeybindingResolverView", ->
  keybindingResolver = null

  beforeEach ->
    window.rootView = new RootView
    keybindingResolver = atom.activatePackage('keybinding-resolver', immediate: true)

  describe "when the keybinding-resolver:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(rootView.find('.keybinding-resolver')).not.toExist()
      rootView.trigger 'keybinding-resolver:toggle'
      expect(rootView.find('.keybinding-resolver')).toExist()
      rootView.trigger 'keybinding-resolver:toggle'
      expect(rootView.find('.keybinding-resolver')).not.toExist()

  describe "when a keydown event occurs", ->
    it "displays all commands for the event", ->
      keymap.bindKeys 'name', 'body', 'x': 'match-1'
      keymap.bindKeys 'name', 'body', 'x': 'match-2'
      keymap.bindKeys 'name', '.never-again', 'x': 'unmatch-2'

      rootView.trigger 'keybinding-resolver:toggle'
      $(document).trigger keydownEvent('x', target: rootView)
      expect(rootView.find('.keybinding-resolver .matched')).toHaveLength 2
      expect(rootView.find('.keybinding-resolver .unmatched')).toHaveLength 1

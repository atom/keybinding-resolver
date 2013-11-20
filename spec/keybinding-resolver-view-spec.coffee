KeybindingResolverView = require '../lib/keybinding-resolver-view'
{$, RootView} = require 'atom'

describe "KeybindingResolverView", ->
  beforeEach ->
    atom.rootView = new RootView
    atom.packages.activatePackage('keybinding-resolver', immediate: true)

  describe "when the keybinding-resolver:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.rootView.find('.keybinding-resolver')).not.toExist()
      atom.rootView.trigger 'keybinding-resolver:toggle'
      expect(atom.rootView.find('.keybinding-resolver')).toExist()
      atom.rootView.trigger 'keybinding-resolver:toggle'
      expect(atom.rootView.find('.keybinding-resolver')).not.toExist()

  describe "when a keydown event occurs", ->
    it "displays all commands for the event", ->
      atom.keymap.bindKeys 'name', 'body', 'x': 'match-1'
      atom.keymap.bindKeys 'name', 'body', 'x': 'match-2'
      atom.keymap.bindKeys 'name', '.never-again', 'x': 'unmatch-2'

      atom.rootView.trigger 'keybinding-resolver:toggle'
      $(document).trigger keydownEvent('x', target: rootView)
      expect(atom.rootView.find('.keybinding-resolver .matched')).toHaveLength 2
      expect(atom.rootView.find('.keybinding-resolver .unmatched')).toHaveLength 1

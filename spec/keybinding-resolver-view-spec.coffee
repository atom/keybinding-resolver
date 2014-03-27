KeyBindingResolverView = require '../lib/keybinding-resolver-view'
{$, WorkspaceView} = require 'atom'

describe "KeyBindingResolverView", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView

    waitsForPromise ->
      atom.packages.activatePackage('keybinding-resolver')

  describe "when the key-binding-resolver:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.key-binding-resolver')).not.toExist()
      atom.workspaceView.trigger 'key-binding-resolver:toggle'
      expect(atom.workspaceView.find('.key-binding-resolver')).toExist()
      atom.workspaceView.trigger 'key-binding-resolver:toggle'
      expect(atom.workspaceView.find('.key-binding-resolver')).not.toExist()

  describe "when a keydown event occurs", ->
    it "displays all commands for the event", ->
      atom.keymap.bindKeys 'name', 'body', 'x': 'match-1'
      atom.keymap.bindKeys 'name', 'body', 'x': 'match-2'
      atom.keymap.bindKeys 'name', '.never-again', 'x': 'unmatch-2'

      atom.workspaceView.trigger 'key-binding-resolver:toggle'
      $(document).trigger keydownEvent('x', target: atom.workspaceView)
      expect(atom.workspaceView.find('.keybinding-resolver .matched')).toHaveLength 2
      expect(atom.workspaceView.find('.keybinding-resolver .unmatched')).toHaveLength 1

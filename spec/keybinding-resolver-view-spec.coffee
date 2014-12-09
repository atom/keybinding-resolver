KeyBindingResolverView = require '../lib/keybinding-resolver-view'
{WorkspaceView} = require 'atom'
{$} = require 'space-pen'

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
      atom.keymap.bindKeys 'name', '.workspace', 'x': 'match-1'
      atom.keymap.bindKeys 'name', '.workspace', 'x': 'match-2'
      atom.keymap.bindKeys 'name', '.never-again', 'x': 'unmatch-2'

      atom.workspaceView.trigger 'key-binding-resolver:toggle'
      document.dispatchEvent keydownEvent('x', target: atom.workspaceView).originalEvent
      expect(atom.workspaceView.find('.key-binding-resolver .used')).toHaveLength 1
      expect(atom.workspaceView.find('.key-binding-resolver .unused')).toHaveLength 1
      expect(atom.workspaceView.find('.key-binding-resolver .unmatched')).toHaveLength 1

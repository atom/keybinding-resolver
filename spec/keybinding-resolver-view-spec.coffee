KeyBindingResolverView = require '../lib/keybinding-resolver-view'
{$} = require 'space-pen'

describe "KeyBindingResolverView", ->
  workspaceElement = null
  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)

    waitsForPromise ->
      atom.packages.activatePackage('keybinding-resolver')

  describe "when the key-binding-resolver:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(workspaceElement.querySelector('.key-binding-resolver')).not.toExist()
      atom.commands.dispatch workspaceElement, 'key-binding-resolver:toggle'
      expect(workspaceElement.querySelector('.key-binding-resolver')).toExist()
      atom.commands.dispatch workspaceElement, 'key-binding-resolver:toggle'
      expect(workspaceElement.querySelector('.key-binding-resolver')).not.toExist()

  describe "when a keydown event occurs", ->
    it "displays all commands for the event", ->
      atom.keymap.addKeymap 'name', '.workspace': 'x': 'match-1'
      atom.keymap.addKeymap 'name', '.workspace': 'x': 'match-2'
      atom.keymap.addKeymap 'name', '.never-again': 'x': 'unmatch-2'

      atom.commands.dispatch workspaceElement, 'key-binding-resolver:toggle'
      document.dispatchEvent keydownEvent('x', target: workspaceElement).originalEvent
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .used')).toHaveLength 1
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unused')).toHaveLength 1
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unmatched')).toHaveLength 1

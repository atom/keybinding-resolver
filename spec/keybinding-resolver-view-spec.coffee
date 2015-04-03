KeyBindingResolverView = require '../lib/keybinding-resolver-view'
{$} = require 'atom-space-pen-views'

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

      atom.commands.dispatch workspaceElement, 'key-binding-resolver:toggle'
      expect(workspaceElement.querySelector('.key-binding-resolver')).toExist()

  describe "when a keydown event occurs", ->
    it "displays all commands for the event", ->
      atom.keymap.add 'name', '.workspace': 'x': 'match-1'
      atom.keymap.add 'name', '.workspace': 'x': 'match-2'
      atom.keymap.add 'name', '.never-again': 'x': 'unmatch-2'

      atom.commands.dispatch workspaceElement, 'key-binding-resolver:toggle'
      document.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('x', target: workspaceElement)
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .used')).toHaveLength 1
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unused')).toHaveLength 1
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unmatched')).toHaveLength 1

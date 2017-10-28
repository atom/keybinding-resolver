const {it, fit, ffit, beforeEach} = require('./async-spec-helpers') // eslint-disable-line no-unused-vars
const etch = require('etch')

describe('KeyBindingResolverView', () => {
  let workspaceElement

  beforeEach(async () => {
    workspaceElement = atom.views.getView(atom.workspace)
    await atom.packages.activatePackage('keybinding-resolver')
  })

  describe('when the key-binding-resolver:toggle event is triggered', () => {
    it('attaches and then detaches the view', () => {
      expect(workspaceElement.querySelector('.key-binding-resolver')).not.toExist()

      atom.commands.dispatch(workspaceElement, 'key-binding-resolver:toggle')
      expect(workspaceElement.querySelector('.key-binding-resolver')).toExist()

      atom.commands.dispatch(workspaceElement, 'key-binding-resolver:toggle')
      expect(workspaceElement.querySelector('.key-binding-resolver')).not.toExist()

      atom.commands.dispatch(workspaceElement, 'key-binding-resolver:toggle')
      expect(workspaceElement.querySelector('.key-binding-resolver')).toExist()
    })
  })

  describe('when a keydown event occurs', () => {
    it('displays all commands for the keydown event but does not clear for the keyup when there is no keyup binding', async () => {
      atom.keymaps.add('name', {
        '.workspace': {
          'x': 'match-1'
        }
      })
      atom.keymaps.add('name', {
        '.workspace': {
          'x': 'match-2'
        }
      })
      atom.keymaps.add('name', {
        '.never-again': {
          'x': 'unmatch-2'
        }
      })

      atom.commands.dispatch(workspaceElement, 'key-binding-resolver:toggle')

      document.dispatchEvent(atom.keymaps.constructor.buildKeydownEvent('x', {target: workspaceElement}))
      await etch.getScheduler().getNextUpdatePromise()
      expect(workspaceElement.querySelector('.key-binding-resolver .keystroke').textContent).toBe('x')
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .used')).toHaveLength(1)
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unused')).toHaveLength(1)
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unmatched')).toHaveLength(1)

      // It should not render the keyup event data because there is no match
      spyOn(etch.getScheduler(), 'updateDocument').andCallThrough()
      document.dispatchEvent(atom.keymaps.constructor.buildKeyupEvent('x', {target: workspaceElement}))
      expect(etch.getScheduler().updateDocument).not.toHaveBeenCalled()
      expect(workspaceElement.querySelector('.key-binding-resolver .keystroke').textContent).toBe('x')
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .used')).toHaveLength(1)
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unused')).toHaveLength(1)
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unmatched')).toHaveLength(1)
    })

    it('displays all commands for the keydown event but does not clear for the keyup when there is no keyup binding', async () => {
      atom.keymaps.add('name', {
        '.workspace': {
          'x': 'match-1'
        }
      })
      atom.keymaps.add('name', {
        '.workspace': {
          'x ^x': 'match-2'
        }
      })
      atom.keymaps.add('name', {
        '.workspace': {
          'a ^a': 'match-3'
        }
      })
      atom.keymaps.add('name', {
        '.never-again': {
          'x': 'unmatch-2'
        }
      })

      atom.commands.dispatch(workspaceElement, 'key-binding-resolver:toggle')

      // Not partial because it dispatches the command for `x` immediately due to only having keyup events in remainder of partial match
      document.dispatchEvent(atom.keymaps.constructor.buildKeydownEvent('x', {target: workspaceElement}))
      await etch.getScheduler().getNextUpdatePromise()
      expect(workspaceElement.querySelector('.key-binding-resolver .keystroke').textContent).toBe('x')
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .used')).toHaveLength(1)
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unused')).toHaveLength(0)
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unmatched')).toHaveLength(1)

      // It should not render the keyup event data because there is no match
      document.dispatchEvent(atom.keymaps.constructor.buildKeyupEvent('x', {target: workspaceElement}))
      await etch.getScheduler().getNextUpdatePromise()
      expect(workspaceElement.querySelector('.key-binding-resolver .keystroke').textContent).toBe('x ^x')
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .used')).toHaveLength(1)
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unused')).toHaveLength(0)
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unmatched')).toHaveLength(0)

      document.dispatchEvent(atom.keymaps.constructor.buildKeydownEvent('a', {target: workspaceElement}))
      await etch.getScheduler().getNextUpdatePromise()
      expect(workspaceElement.querySelector('.key-binding-resolver .keystroke').textContent).toBe('a (partial)')
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .used')).toHaveLength(0)
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unused')).toHaveLength(1)
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unmatched')).toHaveLength(0)

      document.dispatchEvent(atom.keymaps.constructor.buildKeyupEvent('a', {target: workspaceElement}))
      await etch.getScheduler().getNextUpdatePromise()
      expect(workspaceElement.querySelector('.key-binding-resolver .keystroke').textContent).toBe('a ^a')
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .used')).toHaveLength(1)
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unused')).toHaveLength(0)
      expect(workspaceElement.querySelectorAll('.key-binding-resolver .unmatched')).toHaveLength(0)
    })
  })
})

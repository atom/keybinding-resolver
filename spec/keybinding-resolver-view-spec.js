const {it, fit, ffit, beforeEach} = require('./async-spec-helpers') // eslint-disable-line no-unused-vars
const etch = require('etch')

describe('KeyBindingResolverView', () => {
  let workspaceElement, bottomDockElement

  beforeEach(async () => {
    workspaceElement = atom.views.getView(atom.workspace)
    bottomDockElement = atom.views.getView(atom.workspace.getBottomDock())
    await atom.packages.activatePackage('keybinding-resolver')
  })

  describe('when the key-binding-resolver:toggle event is triggered', () => {
    it('creates and then destroys the view', () => {
      const visibilitySpy = jasmine.createSpy('onDidChangeVisible')
      atom.workspace.getBottomDock().onDidChangeVisible(visibilitySpy)

      expect(bottomDockElement.querySelector('.key-binding-resolver')).not.toExist()

      atom.commands.dispatch(workspaceElement, 'key-binding-resolver:toggle')
      waitsFor(() => visibilitySpy.callCount === 1)
      runs(() => {
        expect(bottomDockElement.querySelector('.key-binding-resolver')).toExist()

        atom.commands.dispatch(workspaceElement, 'key-binding-resolver:toggle')
      })

      waitsFor(() => visibilitySpy.callCount === 2)
      runs(() => {
        expect(bottomDockElement.querySelector('.key-binding-resolver')).toExist()

        atom.commands.dispatch(workspaceElement, 'key-binding-resolver:toggle')
      })

      waitsFor(() => visibilitySpy.callCount === 3)
    })

    it('focuses the view if it is not visible instead of destroying it', () => {
      const visibilitySpy = jasmine.createSpy('onDidChangeVisible')
      atom.workspace.getBottomDock().onDidChangeVisible(visibilitySpy)

      expect(bottomDockElement.querySelector('.key-binding-resolver')).not.toExist()

      atom.commands.dispatch(workspaceElement, 'key-binding-resolver:toggle')
      waitsFor(() => visibilitySpy.callCount === 1)
      runs(() => {
        expect(bottomDockElement.querySelector('.key-binding-resolver')).toExist()

        atom.workspace.getBottomDock().hide()
        atom.commands.dispatch(workspaceElement, 'key-binding-resolver:toggle')
      })

      waitsFor(() => visibilitySpy.callCount === 3) // the second count happened when the dock was toggled
      runs(() => {
        expect(atom.workspace.getBottomDock().isVisible()).toBe(true)
        expect(bottomDockElement.querySelector('.key-binding-resolver')).toExist()
      })
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

      document.dispatchEvent(atom.keymaps.constructor.buildKeydownEvent('x', {target: bottomDockElement}))
      await etch.getScheduler().getNextUpdatePromise()
      expect(bottomDockElement.querySelector('.key-binding-resolver .keystroke').textContent).toBe('x')
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .used')).toHaveLength(1)
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .unused')).toHaveLength(1)
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .unmatched')).toHaveLength(1)

      // It should not render the keyup event data because there is no match
      spyOn(etch.getScheduler(), 'updateDocument').andCallThrough()
      document.dispatchEvent(atom.keymaps.constructor.buildKeyupEvent('x', {target: bottomDockElement}))
      expect(etch.getScheduler().updateDocument).not.toHaveBeenCalled()
      expect(bottomDockElement.querySelector('.key-binding-resolver .keystroke').textContent).toBe('x')
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .used')).toHaveLength(1)
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .unused')).toHaveLength(1)
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .unmatched')).toHaveLength(1)
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
      document.dispatchEvent(atom.keymaps.constructor.buildKeydownEvent('x', {target: bottomDockElement}))
      await etch.getScheduler().getNextUpdatePromise()
      expect(bottomDockElement.querySelector('.key-binding-resolver .keystroke').textContent).toBe('x')
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .used')).toHaveLength(1)
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .unused')).toHaveLength(0)
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .unmatched')).toHaveLength(1)

      // It should not render the keyup event data because there is no match
      document.dispatchEvent(atom.keymaps.constructor.buildKeyupEvent('x', {target: bottomDockElement}))
      await etch.getScheduler().getNextUpdatePromise()
      expect(bottomDockElement.querySelector('.key-binding-resolver .keystroke').textContent).toBe('x ^x')
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .used')).toHaveLength(1)
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .unused')).toHaveLength(0)
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .unmatched')).toHaveLength(0)

      document.dispatchEvent(atom.keymaps.constructor.buildKeydownEvent('a', {target: bottomDockElement}))
      await etch.getScheduler().getNextUpdatePromise()
      expect(bottomDockElement.querySelector('.key-binding-resolver .keystroke').textContent).toBe('a (partial)')
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .used')).toHaveLength(0)
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .unused')).toHaveLength(1)
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .unmatched')).toHaveLength(0)

      document.dispatchEvent(atom.keymaps.constructor.buildKeyupEvent('a', {target: bottomDockElement}))
      await etch.getScheduler().getNextUpdatePromise()
      expect(bottomDockElement.querySelector('.key-binding-resolver .keystroke').textContent).toBe('a ^a')
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .used')).toHaveLength(1)
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .unused')).toHaveLength(0)
      expect(bottomDockElement.querySelectorAll('.key-binding-resolver .unmatched')).toHaveLength(0)
    })
  })
})

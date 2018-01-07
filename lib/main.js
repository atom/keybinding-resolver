const {CompositeDisposable} = require('atom')

const KeyBindingResolverView = require('./keybinding-resolver-view')

module.exports = {
  keybindingResolverView: null,

  activate (state = {}) {
    this.disposables = new CompositeDisposable()

    const {attached} = state
    if (attached)
      this.getKeybindingResolverView().toggle()

    this.disposables.add(atom.commands.add('atom-workspace', {
      'keybinding-resolver:toggle': () => this.getKeybindingResolverView().toggle(),
    }))

    if (!atom.config.get('keybinding-resolver.persistentPanel'))
      this.disposables.add(atom.commands.add('atom-workspace', {
        'core:cancel': () => this.getKeybindingResolverView().detach(),
        'core:close': () => this.getKeybindingResolverView().detach()
      }))
  },

  getKeybindingResolverView () {
    if (this.keybindingResolverView == null) {
      this.keybindingResolverView = new KeyBindingResolverView()
    }
    return this.keybindingResolverView
  },

  deactivate () {
    this.disposables.dispose()
    if (this.keybindingResolverView != null) {
      this.keybindingResolverView.destroy()
    }
  },

  serialize () {
    if (this.keybindingResolverView != null) {
      return this.keybindingResolverView.serialize()
    }
    return undefined
  },

  config : {
    persistentPanel : {
      type : 'boolean',
      default : false,
      title : 'Panel stays open, responds only to "toggle", not cancel or close'
    }
  }
}

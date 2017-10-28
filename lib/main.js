const KeyBindingResolverView = require('./keybinding-resolver-view')

module.exports = {
  keybindingResolverView: null,

  activate (state = {}) {
    const {attached} = state
    if (attached) this.getKeybindingResolverView().toggle()
    atom.commands.add('atom-workspace', {
      'key-binding-resolver:toggle': () => this.getKeybindingResolverView().toggle(),
      'core:cancel': () => this.getKeybindingResolverView().detach(),
      'core:close': () => this.getKeybindingResolverView().detach()
    })
  },

  getKeybindingResolverView () {
    if (this.keybindingResolverView == null) {
      this.keybindingResolverView = new KeyBindingResolverView()
    }
    return this.keybindingResolverView
  },

  deactivate () {
    if (this.keybindingResolverView != null) {
      this.keybindingResolverView.destroy()
    }
  },

  serialize () {
    if (this.keybindingResolverView != null) {
      return this.keybindingResolverView.serialize()
    }
    return undefined
  }
}

const {CompositeDisposable} = require('atom')

const KeyBindingResolverView = require('./keybinding-resolver-view')

const KEYBINDING_RESOLVER_URI = 'atom://keybinding-resolver'

module.exports = {
  activate () {
    this.subscriptions = new CompositeDisposable()

    this.subscriptions.add(atom.workspace.addOpener(uri => {
      if (uri === KEYBINDING_RESOLVER_URI) {
        return new KeyBindingResolverView()
      }
    }))

    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'key-binding-resolver:toggle': () => this.toggle()
    }))
  },

  async deactivate () {
    this.subscriptions.dispose()
    let pane = atom.workspace.paneForURI(KEYBINDING_RESOLVER_URI)
    while (pane) {
      await pane.destroyItem(pane.itemForURI(KEYBINDING_RESOLVER_URI))
      pane = atom.workspace.paneForURI(KEYBINDING_RESOLVER_URI)
    }
  },

  toggle () {
    const pane = atom.workspace.paneForURI(KEYBINDING_RESOLVER_URI)
    if (pane) {
      atom.workspace.hide(KEYBINDING_RESOLVER_URI)
      // Also destroy the view so that we don't keep capturing keybinding events
      pane.destroyItem(pane.itemForURI(KEYBINDING_RESOLVER_URI))
    } else {
      atom.workspace.open(KEYBINDING_RESOLVER_URI)
    }
  },

  deserializeKeyBindingResolverView (serialized) {
    return new KeyBindingResolverView()
  }
}

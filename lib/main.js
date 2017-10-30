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

  deactivate () {
    this.subscriptions.dispose()
    const pane = atom.workspace.paneForURI(KEYBINDING_RESOLVER_URI)
    if (pane) {
      pane.destroyItem(pane.itemForURI(KEYBINDING_RESOLVER_URI))
    }
  },

  toggle () {
    const pane = atom.workspace.paneForURI(KEYBINDING_RESOLVER_URI)
    // FIXME: This should check if the pane itself is visible, not the bottom dock.
    // This will allow us to support more dock locations.
    if (pane && atom.workspace.getBottomDock().isVisible()) {
      atom.workspace.hide(KEYBINDING_RESOLVER_URI)
      // Also destroy the view so that we don't keep capturing keybinding events
      pane.destroyItem(pane.itemForURI(KEYBINDING_RESOLVER_URI))
    } else {
      atom.workspace.open(KEYBINDING_RESOLVER_URI)
    }
  }
}

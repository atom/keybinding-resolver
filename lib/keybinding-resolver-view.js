/** @babel */
/** @jsx etch.dom */

import fs from 'fs-plus'
import etch from 'etch'
import {CompositeDisposable} from 'atom'
import path from 'path'

export default class KeyBindingResolverView {
  constructor () {
    this.keystrokes = null
    this.usedKeyBinding = null
    this.unusedKeyBindings = []
    this.unmatchedKeyBindings = []
    this.partiallyMatchedBindings = []
    this.disposables = new CompositeDisposable()

    this.disposables.add(atom.keymaps.onDidMatchBinding(({keystrokes, binding, keyboardEventTarget, eventType}) => {
      if (eventType === 'keyup' && binding == null) {
        return
      }

      const unusedKeyBindings = atom.keymaps
        .findKeyBindings({keystrokes, target: keyboardEventTarget})
        .filter((b) => b !== binding)

      const unmatchedKeyBindings = atom.keymaps
        .findKeyBindings({keystrokes})
        .filter((b) => b !== binding && !unusedKeyBindings.includes(b))

      this.update({usedKeyBinding: binding, unusedKeyBindings, unmatchedKeyBindings, keystrokes})
    }))

    this.disposables.add(atom.keymaps.onDidPartiallyMatchBindings(({keystrokes, partiallyMatchedBindings}) => {
      this.update({keystrokes, partiallyMatchedBindings})
    }))

    this.disposables.add(atom.keymaps.onDidFailToMatchBinding(({keystrokes, keyboardEventTarget, eventType}) => {
      if (eventType === 'keyup') {
        return
      }

      const unusedKeyBindings = atom.keymaps.findKeyBindings({keystrokes, target: keyboardEventTarget})
      const unmatchedKeyBindings = atom.keymaps
        .findKeyBindings({keystrokes})
        .filter((b) => !unusedKeyBindings.includes(b))

      this.update({unusedKeyBindings, unmatchedKeyBindings, keystrokes})
    }))

    etch.initialize(this)
  }

  getTitle () {
    return 'Key Binding Resolver'
  }

  getIconName () {
    return 'keyboard'
  }

  getDefaultLocation () {
    return 'bottom'
  }

  getAllowedLocations () {
    // TODO: Support left and right possibly
    return ['bottom']
  }

  getURI () {
    return 'atom://keybinding-resolver'
  }

  serialize () {
    return {
      deserializer: 'keybinding-resolver/KeyBindingResolverView'
    }
  }

  destroy () {
    this.detach()
    return etch.destroy(this)
  }

  detach () {
    this.disposables.dispose()
  }

  update (props) {
    this.keystrokes = props.keystrokes
    this.usedKeyBinding = props.usedKeyBinding
    this.unusedKeyBindings = props.unusedKeyBindings || []
    this.unmatchedKeyBindings = props.unmatchedKeyBindings || []
    this.partiallyMatchedBindings = props.partiallyMatchedBindings || []
    return etch.update(this)
  }

  render () {
    return (
      <div className='key-binding-resolver'>
        <div className='panel-heading padded'>{this.renderKeystrokes()}</div>
        <div className='panel-body padded'>{this.renderKeyBindings()}</div>
      </div>
    )
  }

  renderKeystrokes () {
    if (this.keystrokes) {
      if (this.partiallyMatchedBindings.length > 0) {
        return <span className='keystroke'>{this.keystrokes} (partial)</span>
      } else {
        return <span className='keystroke'>{this.keystrokes}</span>
      }
    } else {
      return <span>Press any key</span>
    }
  }

  renderKeyBindings () {
    if (this.partiallyMatchedBindings.length > 0) {
      return (
        <table className='table-condensed'>
          <tbody>
            {this.partiallyMatchedBindings.map((binding) => (
              <tr className='unused'>
                <td className='command'>{binding.command}</td>
                <td className='keystrokes'>{binding.keystrokes}</td>
                <td className='selector'>{binding.selector}</td>
                <td className='source' onclick={() => this.openKeybindingFile(binding.source)}>{binding.source}</td>
              </tr>
          ))}
          </tbody>
        </table>
      )
    } else {
      let usedKeyBinding = ''
      if (this.usedKeyBinding) {
        usedKeyBinding = (
          <tr className='used'>
            <td className='command'>{this.usedKeyBinding.command}</td>
            <td className='selector'>{this.usedKeyBinding.selector}</td>
            <td className='source' onclick={() => this.openKeybindingFile(this.usedKeyBinding.source)}>{this.usedKeyBinding.source}</td>
          </tr>
        )
      }
      return (
        <table className='table-condensed'>
          <tbody>
            {usedKeyBinding}
            {this.unusedKeyBindings.map((binding) => (
              <tr className='unused'>
                <td className='command'>{binding.command}</td>
                <td className='selector'>{binding.selector}</td>
                <td className='source' onclick={() => this.openKeybindingFile(binding.source)}>{binding.source}</td>
              </tr>
            ))}
            {this.unmatchedKeyBindings.map((binding) => (
              <tr className='unmatched'>
                <td className='command'>{binding.command}</td>
                <td className='selector'>{binding.selector}</td>
                <td className='source' onclick={() => this.openKeybindingFile(binding.source)}>{binding.source}</td>
              </tr>
          ))}
          </tbody>
        </table>
      )
    }
  }

  isInAsarArchive (pathToCheck) {
    const {resourcePath} = atom.getLoadSettings()
    return pathToCheck.startsWith(`${resourcePath}${path.sep}`) && path.extname(resourcePath) === '.asar'
  }

  extractBundledKeymap (bundledKeymapPath) {
    const metadata = require(path.join(atom.getLoadSettings().resourcePath, 'package.json'))
    const bundledKeymaps = metadata ? metadata._atomKeymaps : {}
    const keymapName = path.basename(bundledKeymapPath)
    const extractedKeymapPath = path.join(require('temp').mkdirSync('atom-bundled-keymap-'), keymapName)
    fs.writeFileSync(
      extractedKeymapPath,
      JSON.stringify(bundledKeymaps[keymapName] || {}, null, 2)
    )
    return extractedKeymapPath
  }

  extractBundledPackageKeymap (keymapRelativePath) {
    const packageName = keymapRelativePath.split(path.sep)[1]
    const keymapName = path.basename(keymapRelativePath)
    const metadata = atom.packages.packagesCache[packageName] || {}
    const keymaps = metadata.keymaps || {}
    const extractedKeymapPath = path.join(require('temp').mkdirSync('atom-bundled-keymap-'), keymapName)
    fs.writeFileSync(
      extractedKeymapPath,
      JSON.stringify(keymaps[keymapRelativePath] || {}, null, 2)
    )
    return extractedKeymapPath
  }

  openKeybindingFile (keymapPath) {
    if (this.isInAsarArchive(keymapPath)) {
      keymapPath = this.extractBundledKeymap(keymapPath)
    } else if (keymapPath.startsWith('core:node_modules')) {
      keymapPath = this.extractBundledPackageKeymap(keymapPath.replace('core:', ''))
    } else if (keymapPath.startsWith('core:')) {
      keymapPath = this.extractBundledKeymap(keymapPath.replace('core:', ''))
    }

    atom.workspace.open(keymapPath)
  }
}

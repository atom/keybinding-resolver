{Disposable, CompositeDisposable} = require 'atom'
{$$, View} = require 'atom-space-pen-views'
path = require 'path'

module.exports =
class KeyBindingResolverView extends View
  @content: ->
    @div class: 'key-binding-resolver', =>
      @div class: 'panel-heading padded', =>
        @span 'Key Binding Resolver: '
        @span outlet: 'keystroke', 'Press any key'
      @div outlet: 'commands', class: 'panel-body padded'

  initialize: ->
    @on 'click', '.source', ({target}) => @openKeybindingFile(target.innerText)

  serialize: ->
    attached: @panel?.isVisible()

  destroy: ->
    @detach()

  toggle: ->
    if @panel?.isVisible()
      @detach()
    else
      @attach()

  attach: ->
    @disposables = new CompositeDisposable

    @panel = atom.workspace.addBottomPanel(item: this)
    @disposables.add new Disposable =>
      @panel.destroy()
      @panel = null

    @disposables.add atom.keymaps.onDidMatchBinding ({keystrokes, binding, keyboardEventTarget, eventType}) =>
      @update(keystrokes, binding, keyboardEventTarget, eventType)

    @disposables.add atom.keymaps.onDidPartiallyMatchBindings ({keystrokes, partiallyMatchedBindings, keyboardEventTarget, eventType}) =>
      @updatePartial(keystrokes, partiallyMatchedBindings)

    @disposables.add atom.keymaps.onDidFailToMatchBinding ({keystrokes, keyboardEventTarget, eventType}) =>
      @update(keystrokes, null, keyboardEventTarget, eventType)

  detach: ->
    @disposables?.dispose()

  update: (keystrokes, keyBinding, keyboardEventTarget, eventType) ->
    return if eventType is 'keyup' and keyBinding is null

    @keystroke.html $$ ->
      @span class: 'keystroke', keystrokes

    unusedKeyBindings = atom.keymaps.findKeyBindings({keystrokes, target: keyboardEventTarget}).filter (binding) ->
      binding isnt keyBinding

    unmatchedKeyBindings = atom.keymaps.findKeyBindings({keystrokes}).filter (binding) ->
      binding isnt keyBinding and binding not in unusedKeyBindings

    @commands.html $$ ->
      @table class: 'table-condensed', =>
        if keyBinding
          @tr class: 'used', =>
            @td class: 'command', keyBinding.command
            @td class: 'selector', keyBinding.selector
            @td class: 'source', keyBinding.source

        for binding in unusedKeyBindings
          @tr class: 'unused', =>
            @td class: 'command', binding.command
            @td class: 'selector', binding.selector
            @td class: 'source', binding.source

        for binding in unmatchedKeyBindings
          @tr class: 'unmatched', =>
            @td class: 'command', binding.command
            @td class: 'selector', binding.selector
            @td class: 'source', binding.source

  updatePartial: (keystrokes, keyBindings) ->
    @keystroke.html $$ ->
      @span class: 'keystroke', "#{keystrokes} (partial)"

    @commands.html $$ ->
      @table class: 'table-condensed', =>
        for binding in keyBindings
          @tr class: 'unused', =>
            @td class: 'command', binding.command
            @td class: 'keystrokes', binding.keystrokes
            @td class: 'selector', binding.selector
            @td class: 'source', binding.source

  isInAsarArchive: (pathToCheck) ->
    {resourcePath} = atom.getLoadSettings()
    pathToCheck.startsWith("#{resourcePath}#{path.sep}") and path.extname(resourcePath) is '.asar'

  extractBundledKeymap: (keymapPath) ->
    bundledKeymaps = require(path.join(atom.getLoadSettings().resourcePath, 'package.json'))?._atomKeymaps
    keymapName = path.basename(keymapPath)
    keymapPath = path.join(require('temp').mkdirSync('atom-bundled-keymap-'), keymapName)
    keymap = bundledKeymaps?[keymapName] ? {}
    require('fs-plus').writeFileSync(keymapPath, JSON.stringify(keymap, null, 2))
    keymapPath

  openKeybindingFile: (keymapPath) ->
    keymapPath = @extractBundledKeymap(keymapPath) if @isInAsarArchive(keymapPath)
    atom.workspace.open(keymapPath)

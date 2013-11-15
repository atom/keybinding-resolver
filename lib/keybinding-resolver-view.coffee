{_, $, $$, View} = require 'atom'
Humanize = require 'humanize-plus'

module.exports =
class KeybindingResolverView extends View
  @content: ->
    @div class: 'keybinding-resolver tool-panel pannel panel-bottom padding', =>
      @div outlet: 'keystroke', class: 'panel-heading padded', 'Press any key'
      @div outlet: 'commands', class: 'panel-body padded'

  initialize: ({attached})->
    @attach() if attached

    atom.rootView.command "keybinding-resolver:toggle", => @toggle()
    $(document).preempt 'keydown', (event) => @handleEvent(event)
    @on "click", ".source", (event) ->
      rootView.open(event.target.innerText)

  serialize: ->
    attached: @hasParent()

  destroy: ->
    @detach()


  toggle: ->
    if @hasParent()
      @detach()
    else
      @attach()

  attach: ->
    atom.rootView.vertical.append(this)

  handleEvent: (event) ->
    keystroke = atom.keymap.keystrokeStringForEvent(event)
    bindings = atom.keymap.bindingsForKeystroke(keystroke)
    matchedBindings = atom.keymap.bindingsMatchingElement(document.activeElement, bindings)
    unmatchedBindings = bindings.filter (binding) ->
      for matchedBinding in matchedBindings
        return false if _.isEqual(matchedBinding, binding)
      true

    bindingsLength = Object.keys(bindings).length
    @keystroke.html $$ ->
      @span class: 'keystroke', keystroke

    createListItem = (classString, binding) ->
      @tr class: classString, =>
        @td class: 'command', binding.command
        @td class: 'selector', binding.selector
        @td class: 'source', binding.source

    @commands.html $$ ->
      @table class: 'table-condensed', =>
        for binding, index in matchedBindings
          classString = 'matched'
          classString += ' selected text-success' if index == 0
          createListItem.call this, classString, binding

        for binding in unmatchedBindings
          classString = 'unmatched text-subtle'
          createListItem.call this, classString, binding

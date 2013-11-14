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
    mappings = atom.keymap.mappingsForKeystroke(keystroke)
    matchedMappings = atom.keymap.mappingsMatchingElement(document.activeElement, mappings)
    unmatchedMappings = mappings.filter (mapping) ->
      for matchedMapping in matchedMappings
        return false if _.isEqual(matchedMapping, mapping)
      true

    mappingsLength = Object.keys(mappings).length
    @keystroke.html $$ ->
      @span class: 'keystroke', keystroke

    createListItem = (classString, mapping) ->
      @tr class: classString, =>
        @td class: 'command', mapping.command
        @td class: 'selector', mapping.selector
        @td class: 'source', mapping.source

    @commands.html $$ ->
      @table class: 'table-condensed', =>
        for mapping, index in matchedMappings
          classString = 'matched'
          classString += ' selected text-success' if index == 0
          createListItem.call this, classString, mapping

        for mapping in unmatchedMappings
          classString = 'unmatched text-subtle'
          createListItem.call this, classString, mapping

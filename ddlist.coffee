$ ->
  state = null
  selected = null
  ###
    EventHandlerの振り分け
  ###
  listNode = $('#list')

  listNode.on 'mousedown', 'li', (event) ->
    state.onMouseDown event
  listNode.on 'mousemove', 'li', (event) ->
    state.onMouseMove event
  listNode.on 'mouseup', 'li', (event) ->
    state.onMouseUp event
  listNode.on 'dblclick', 'li', (event) ->
    state.onDoubleClick event
  $(document).on 'keydown', (event) ->
    state.onKeyDown event
  $('body').not('.text-editing').on 'click', ->
    state.onOtherClick()

  ###
    State移行処理
  ###
  transitState = (nextState) ->
    $('#debug').text state + ' -> ' + nextState
    state = nextState

  ###
    Stateの基底クラス
  ###
  AbstractState = ->
  AbstractState.prototype =
    initialize: ->
    onMouseDown: (event) ->
    onMouseMove: (event) ->
    onMouseUp: (event) ->
    onDubleClick: (event) ->
    onKeyDown: (event) ->
    onOtherClick: ->
    toString: -> 'AbstractState'

  ###
    待機中State
  ###
  NormalState = ->
    selected = null

  $.extend(NormalState.prototype, AbstractState.prototype,
    onMouseDown: (event) ->
      target = event.target
      if target.tagName is 'LI'
        transitState new DragMovingState target

    onDoubleClick: (event) ->
      target = event.target
      if target.tagName is 'LI'
        transitState new TextEditingState target

    toString: -> 'NormalState'
  )

  ###
    List項目移動中State
  ###
  DragMovingState = (target) ->
    selected = target
    $('#drag-item').text($(selected).text()).show()
    return

  $.extend(DragMovingState.prototype, AbstractState.prototype,
    onMouseMove: (event) ->
      target = event.target
      if target.tagName is 'LI'
        $('#drag-item').css
          left: event.pageX + 2
          top: event.pageY + 2
        $('#list li').removeClass 'drag-over'
        $(target).addClass 'drag-over'

    onMouseUp: (event) ->
      target = event.target
      $('#list li').removeClass 'drag-over'
      if(target isnt selected)
        $(target).after selected
      $('#drag-item').hide()
      transitState new NormalState()

    toString: -> 'DragMovingState'
  )

  ###
    textbox編集中State
  ###
  TextEditingState = (target) ->
    selected = target
    pos = $(selected).position()
    @input =
      $('<input type="text" class="text-editing">')
        .css(
          left: pos.left
          top: pos.top
        ).val($(selected).text())
        .appendTo('body')
        .focus()
    $(selected).html '&nbsp;'
    return

  $.extend(TextEditingState.prototype, AbstractState.prototype,
    onKeyDown: (event) ->
      if event.which is 13
        $(selected).text @input.val()
        @input.remove()
        transitState new NormalState()

    onOtherClick: ->
      $(selected).text @input.val()
      @input.remove()
      transitState new NormalState()

    toString: -> 'TextEditingState'
  )

  transitState new NormalState()
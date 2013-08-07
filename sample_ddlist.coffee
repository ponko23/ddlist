###
  非ステートパターンの場合
###

$ () ->
  selected = null
  $("#list li").mousedown () ->
    if !selected
      selected = @
      $("#drag-item").text($(selected).text()).show()

  $("#list").mousemove (event) ->
    target = event.target
    if target.tagName is "LI" && selected
      $("#drag-item").css
        left: event.pageX + 2
        top: event.pageY + 2
      $("#list li").removeClass "drag-over"
      $(target).addClass "drag-over"

  $("#list").mouseup (event) ->
    target = event.target
    if target.tagName == "LI" && selected
      $(target).after selected
      selected = null

      $("#list li").removeClass "drag-over"
      $("#drag-item").hide()
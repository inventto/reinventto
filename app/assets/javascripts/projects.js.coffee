# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  $(".revert").on 'click', (e) ->
    Pixastic.revert(document.getElementById("base-image"))
  $(".invert").on 'click', (e) ->
    Pixastic.process(document.getElementById("base-image"), "invert")
  $(".desaturate").on 'click', (e) ->
    Pixastic.process(document.getElementById("base-image"), "desaturate")
  $(".brightness").on 'click', (e) ->
    Pixastic.process(document.getElementById("base-image"), "brightness", {brightness:50,contrast:0})
  $(".darkness").on 'click', (e) ->
    Pixastic.process(document.getElementById("base-image"), "brightness", {brightness:-50,contrast:0})
  $(".contrast").on 'click', (e) ->
    Pixastic.process(document.getElementById("base-image"), "brightness", {brightness:0,contrast:0.25})
  $(".laplace").on 'click', (e) ->
    Pixastic.process(document.getElementById("base-image"), "laplace", {edgeStrength:0.9,invert:false,greyLevel:0})
  $(".sepia").on 'click', (e) ->
    Pixastic.process(document.getElementById("base-image"), "sepia")
  $(".hue").on 'click', (e) ->
    Pixastic.process(document.getElementById("base-image"), "hsl", {hue:32,saturation:0,lightness:0})
  $(".solarize").on 'click', (e) ->
    Pixastic.process(document.getElementById("base-image"), "solarize")
  $(".transparent").on 'click', (e) ->
    Pixastic.process(document.getElementById("base-image"), "transparent")
  $(".transparent2").on 'click', (e) ->
    Pixastic.process(document.getElementById("base-image"), "transparent", {white: true})

  $("#slider-opacity").slider({orientation: "vertical", value: 50})
  $("#base-image").fadeTo(200, 0.5)
  $("#slider-opacity").on "slidechange", ( event, ui ) ->
    $("#base-image").fadeTo(100, ui.value / 100)

  $('#config-button').on 'click', (e) ->
    if $(e.currentTarget).hasClass('active')
      $('#context-container > div').hide(100)
      $(this).removeClass('active')
    else
      active_context('config-context')
      $('#controls > div').removeClass('active')
      $(this).addClass('active')

  active_context = (context) ->
    $('#context-container > div').hide(100)
    $('#'+context).show(100)

  window.URL = window.URL || window.webkitURL
  navigator.getUserMedia  = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia
  video = $('#capture video')[0]
  canvas = $('#capture canvas.camera')[0]
  thumb_canvas = $('#capture canvas.camera')[0]
  thumb_canvas.width = 128
  thumb_canvas.height = 128
  canvas.width = 500
  canvas.height = 500
  ctx = canvas.getContext('2d')
  thumb_ctx = thumb_canvas.getContext('2d')
  localMediaStream = null

  snapshot = ->
    if (localMediaStream)
      diffH = video.clientHeight - canvas.height
      diffW = video.clientWidth - canvas.width

      ctx.drawImage(video, -diffW / 2, -diffH / 2, video.clientWidth, video.clientHeight)
      thumb_ctx.drawImage(video, -diffW / 2, -diffH / 2, 128, 128)
      blob =  canvas.toDataURL('image/webp')
      thumb_blob = thumb_canvas.toDataURL('image/webp')
      $('img#captured-image').attr 'src', blob
      $('img#baseimage').attr 'src', blob
      $('img#thumbimage').attr 'src', thumb_blob

      uploadImageFromBlob blob, thumb_blob

      $('img#thumbimage').show()
      $('img#captured-image').show()
      $(video).hide()

  pic = true
  $("#snapshot-button").on "click", ->
    if pic
      this.src = "/images/plussnapbutton.png"
      $(this).css({margin: "32px"})
      snapshot()
    else
      this.src = "/images/snapbutton.png"
      $(this).css({margin: "0px"})
      $('img#captured-image').hide()
      $('img#thumbimage').hide()
      $(video).show()
    pic = !pic

  video.addEventListener('click', snapshot, false)
  sourceStream = (stream) ->
    video.src = window.URL.createObjectURL(stream)
    localMediaStream = stream

  onFailSoHard = -> {}
  navigator.getUserMedia video: true, sourceStream, onFailSoHard

  uploadImageFromBlob = (blob, thumb_blob) ->
     fd = new FormData()
     fd.append("image", blob)
     fd.append("thumb", thumb_blob)
     $.ajax
       url: window.location.pathname.replace('edit','add_image'),
       data: fd,
       type: 'POST',
       processData: false,
       contentType: false,
       success: (data) ->
         console.log("enviou imagem e recebeu ", data)

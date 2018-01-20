# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$('.left').click ->
  $('#myCarousel').carousel 'prev'
  return
$('.right').click ->
 $('#myCarousel').carousel 'next'
 return
$('.carousel').carousel
  interval: 60
  pause: 'hover'
  wrap: true

---
---

window.urls = 
  categories_url: "https://sh-example-categories.herokuapp.com"
  basic_url: "https://sh-example-simple.herokuapp.com"
  priority_url: "https://sh-example-priority.herokuapp.com"
  arbitrary_url: "https://sh-example-arbitrary.herokuapp.com"

# Ping the heroku apps this page uses to get them out of hibernation
for url in (Object.keys(window.urls).map (u) -> urls[u])
  request = new XMLHttpRequest
  request.open 'GET', url, true
  request.send()

window.toQueryString = (selection) ->
  if selection is null
    query = urls['categories_url']
  else
    query = selection.join(",")
    query = query.replace(/\s/g, "%20")
    query = "#{urls['categories_url']}/?categories=#{query}" 
  return query

window.showData = (pre_id, data) ->
  $("##{pre_id}").text JSON.stringify(data, null, 2)

window.showUrl = (pre_id, url) ->
  url = url.replace /[^(&|\?)]*=undefined/ig, ''
  url = url.replace /&&+/g, '&'
  $("##{pre_id}-url").html "<a href='#{url}'>#{url}</a>"

$(document).ready ->
  # Add headroom to header
  headroom  = new Headroom(document.querySelector("#header"))
  headroom.init()

  $('.scroll-to-ref').click (e) ->
    event.preventDefault()
    target = $(event.target).attr('href')
    $('body').animate( 
      scrollTop: ($(target).offset().top - 20), 'fast' 
    )

  $('pre').addClass('prettyprint') # Add code highlighting

  $('.example-data-block').text "// This block will display values as they are returned from the server."

  $(".code-toggle").click (e) ->
    e.preventDefault()
    $($(this).attr("href")).slideToggle()
    $(this).toggleClass('is-showing-code')

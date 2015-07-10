---
---

# Ping the heroku apps this page uses to get them out of hibernation
urls = ['sh-example-simple', 'sh-example-priority']
for url in urls
  request = new XMLHttpRequest
  request.open 'GET', "https://#{url}.herokuapp.com", true
  request.send()


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

  $('#sh-example-simple-select').select2
    allowClear: true
    placeholder: "Choose a manufacturer"
    ajax:
      url: 'https://sh-example-simple.herokuapp.com'
      dataType: 'json'
      delay: 250
      data: (params) ->
        q: params.term
        page: params.page
        per_page: 10
      processResults: (data, page) ->
        # Select2 requires an id, so we need to map the results and add an ID
        # You could instead include an id in the tsv you add to soulheart ;)
        results: data.matches.map (item) -> {id: item.text, text: item.text}
        pagination:
          # If there are 10 matches, there's probably at least another page
          more: data.matches.length == 10
      cache: true

  $('#sh-example-priority-select').select2
    allowClear: true
    placeholder: "Choose manufacturers"
    multiple: true
    ajax:
      url: 'https://sh-example-priority.herokuapp.com'
      dataType: 'json'
      delay: 250
      data: (params) ->
        q: params.term
        page: params.page
        per_page: 10
      processResults: (data, page) ->
        # Since sh-example-priority has ids, we don't need to map the response
        results: data.matches
        pagination:
          # If there are 10 matches, there's probably at least another page
          more: data.matches.length == 10
      cache: true
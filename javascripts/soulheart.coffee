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

  categories_base_url = "http://localhost:9292"

  $('#sh-example-categories-select-category').select2
    allowClear: true
    placeholder: "Choose a category"
    multiple: true
    ajax:
      url: "#{categories_base_url}/categories"
      dataType: 'json'
      delay: 250
      data: (params) ->
        q: params.term
        page: params.page
        per_page: 10
      processResults: (data, page) ->
        # Select2 requires an id, so we need to map the results and add an ID
        # You could instead include an id in the tsv you add to soulheart ;)
        results: data.categories.map (item) -> {id: item, text: item}
      cache: true

  $('#sh-example-categories-select-category').on "change", (e) ->
    if $(this).val() is null
      $('#sh-example-categories-select-item').select2('val', 'All')
    window.categories = $(this).val()
    # window.categories = (item.value for item in e.target)
    window.categories_url = toQueryString(window.categories)
    setItemsSelect(window.categories_url)
    setLabelText(window.categories)

  toQueryString = (selection) ->
    if selection is null
      query is null
    else
      query = selection.join(",")
      query = query.replace(/\s/g, "%20")
      query = "#{categories_base_url}/?categories=#{query}" 
    return query

  setLabelText = (selection) ->
    if selection is null
      label = "Choose a category"
    else
      label = selection.join(" & ")
      label = label.replace /\w*/g, (txt) ->
        txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
      label = label + " <small>from <a href='https://bikeindex.org/documentation/api_v2#!/selections'>Bike Index</a></small>"
    $("#sh-example-categories-select-label").html label

  setItemsSelect = (categories_url) ->
    $('#sh-example-categories-select-item').select2
      allowClear: true
      placeholder: "Choose an item"
      ajax:
        url: categories_url
        dataType: 'json'
        delay: 250
        data: (params) ->
          q: params.term
          page: params.page
          per_page: 100
        processResults: (data, page) ->
          # Select2 requires an id, so we need to map the results and add an ID
          # You could instead include an id in the tsv you add to soulheart ;)
          results: data.matches.map (item) -> {id: item.text, text: item.text}
        cache: true

  setItemsSelect()
  setLabelText(null)
 

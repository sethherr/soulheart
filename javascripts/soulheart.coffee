---
---

urls = 
  categories_url: "https://sh-example-categories.herokuapp.com"
  basic_url: "https://sh-example-simple.herokuapp.com"
  priority_url: "https://sh-example-priority.herokuapp.com"
  arbitrary_url: "https://sh-example-arbitrary.herokuapp.com"

# Ping the heroku apps this page uses to get them out of hibernation
for url in (Object.keys(urls).map (u) -> urls[u])
  request = new XMLHttpRequest
  request.open 'GET', url, true
  request.send()

toQueryString = (selection) ->
  if selection is null
    query = urls['categories_url']
  else
    query = selection.join(",")
    query = query.replace(/\s/g, "%20")
    query = "#{urls['categories_url']}/?categories=#{query}" 
  return query

showData = (pre_id, data) ->
  $("##{pre_id}").text JSON.stringify(data, null, 2)

showUrl = (pre_id, url) ->
  console.log(url)
  url = url.replace /[^(&|?)]*=undefined/ig, ''

  $("##{pre_id}-url").html "<a href='#{url}'>#{url}</a>"

setLabelText = (selection) ->
  if selection is null
    label = "Choose items from any category"
  else
    label = selection.join(" & ")
    label = label.replace /\w*/g, (txt) ->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
    label = "Choose Items from #{label} <small>from <a href='https://bikeindex.org/documentation/api_v2#!/selections' tabindex=-1>Bike Index</a></small>"
  $("#sh-example-categories-select-label").html label

formatEmoji = (emoji) ->
  # console.log emoji
  if !emoji.id
    return emoji.text
  if emoji.category is "emoticon"
    $emoji = $("<span><img src='#{emoji.image_url}' class='img-emoji opt-emoji' />#{emoji.text}</span><span class='emoji-type'>#{emoji.category} from #{emoji.source}</span>")
    $emoji
  else if emoji.category is "donger"
    $emoji = $("<span><span class='img-donger opt-emoji'>#{emoji.text}</span>#{emoji.id}</span><span class='emoji-type'>#{emoji.category} from #{emoji.source}</span>")
    $emoji

formatSelectedEmoji = (emoji) ->
  console.log emoji
  if !emoji.id
    return emoji.text
  if emoji.category is "emoticon"
    $emoji = $("<span><img src='#{emoji.image_url}' class='img-emoji' /></span>")
    $emoji
  else if emoji.category is "donger"
    $emoji = $("<span class='img-donger'>#{emoji.text}</span>")
    $emoji


initializeSelectBlocks = ->
  $('#sh-example-simple-select').select2
    allowClear: true
    width: 'style'
    placeholder: "Choose a manufacturer"
    ajax:
      url: urls['basic_url']
      dataType: 'json'
      delay: 250
      data: (params) ->
        q: params.term
        page: params.page
        per_page: 10
      processResults: (data, page) ->
        # showData("#simple-data")
        $('#simple-data').text JSON.stringify(data, null, 2)
        # Select2 requires an id, so we need to map the results and add an ID
        # You could instead include an id in the tsv you add to soulheart ;)
        results: data.matches.map (item) -> {id: item.text, text: item.text}
        pagination:
          # If there are 10 matches, there's probably at least another page
          more: data.matches.length == 10
      cache: true

  $('#sh-example-priority-select').select2
    allowClear: true
    width: 'style'
    placeholder: "Choose manufacturers"
    multiple: true
    ajax:
      url: urls['priority_url']
      dataType: 'json'
      delay: 250
      data: (params) ->
        console.log('testing')
        showUrl("priority-data", "#{url}?q=#{params.term}&page=#{params.page}&per_page=10")
        result =
          q: params.term
          page: params.page
          per_page: 10
      processResults: (data, page) ->
        showData("priority-data", data)
        # Since sh-example-priority has ids, we don't need to map the response
        results: data.matches
        pagination:
          # If there are 10 matches, there's probably at least another page
          more: data.matches.length == 10
      cache: true


  $('#sh-example-categories-select-category').select2
    allowClear: true
    width: 'style'
    placeholder: "Choose a category"
    multiple: true
    ajax:
      url: "#{urls['categories_url']}/categories"
      dataType: 'json'
      delay: 250
      data: (params) ->
        q: params.term
        page: params.page
        per_page: 10
      processResults: (data, page) ->
        # showData("#categories-data")
        $("#categories-data").text JSON.stringify(data, null, 2)
        # Select2 requires an id, so we need to map the results and add an ID
        # You could instead include an id in the tsv you add to soulheart ;)
        results: data.categories.map (item) -> {id: item, text: item}
      cache: true

  $('#sh-example-categories-select-category').on "change", (e) ->
    if $(this).val() is null
      $('#sh-example-categories-select-item').select2('val', 'All')
    window.categories = $(this).val()
    window.categories_url = toQueryString(window.categories)
    setItemsSelect(window.categories_url)
    setLabelText(window.categories)



  setItemsSelect = (categories_url) ->
    $('#sh-example-categories-select-item').select2
      allowClear: true
      width: 'style'
      multiple: true
      placeholder: "Choose items"
      ajax:
        url: categories_url
        dataType: 'json'
        delay: 250
        data: (params) ->
          q: params.term
          page: params.page
          per_page: 10
        processResults: (data, page) ->
          # showData("#categories-data")
          $("#categories-data").text JSON.stringify(data, null, 2)
          # Select2 requires an id, so we need to map the results and add an ID
          # You could instead include an id in the tsv you add to soulheart ;)
          results: data.matches.map (item) -> {id: item.text, text: item.text}
          pagination:
            # If there are 10 matches, there's probably at least another page
            more: data.matches.length == 10
        cache: true

  setItemsSelect(urls['categories_url'])
  setLabelText(null)

  $('#sh-example-arbitrary-select').select2
    allowClear: true
    width: 'style'
    placeholder: "Choose an emoticon"
    multiple: true
    templateSelection: formatSelectedEmoji
    templateResult: formatEmoji
    ajax:
      url: urls['arbitrary_url']
      dataType: 'json'
      delay: 250
      data: (params) ->
        q: params.term
        page: params.page
        per_page: 10
      processResults: (data, page) ->
        # showData("#arbitrary-data")
        $("#arbitrary-data").text JSON.stringify(data, null, 2)
        # Since sh-example-arbitrary has ids, we don't need to map the response
        results: data.matches
        pagination:
          # If there are 10 matches, there's probably at least another page
          more: data.matches.length == 10
      cache: true


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
  
  initializeSelectBlocks()

  $('pre').addClass('prettyprint') # Add code highlighting


  $('.example-data-block').text "// This block will display values as they are returned from the server."

  
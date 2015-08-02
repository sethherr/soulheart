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
  url = url.replace /[^(&|\?)]*=undefined/ig, ''
  url = url.replace /&&+/g, '&'
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

setLabelTextSelectize = (selection) ->
  if selection is null
    label = "Choose items from any category"
  else
    label = selection.join(" & ")
    label = label.replace /\w*/g, (txt) ->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
    label = "Choose Items from #{label} <small>from <a href='https://bikeindex.org/documentation/api_v2#!/selections' tabindex=-1>Bike Index</a></small>"
  $("#sh-example-categories-select-label-selectize").html label

formatEmoji = (emoji) ->
  if !emoji.id
    return emoji.text
  if emoji.category is "emoticon"
    $emoji = $("<span><img src='#{emoji.image_url}' class='img-emoji opt-emoji' />#{emoji.text}</span><span class='emoji-type'>#{emoji.category} from #{emoji.source}</span>")
    $emoji
  else if emoji.category is "donger"
    $emoji = $("<span><span class='img-donger opt-emoji'>#{emoji.text}</span>#{emoji.id}</span><span class='emoji-type'>#{emoji.category} from #{emoji.source}</span>")
    $emoji

formatSelectedEmoji = (emoji) ->
  if !emoji.id
    return emoji.text
  if emoji.category is "emoticon"
    $emoji = $("<span><img src='#{emoji.image_url}' class='img-emoji' /></span>")
    $emoji
  else if emoji.category is "donger"
    $emoji = $("<span class='img-donger'>#{emoji.text}</span>")
    $emoji

tabNavigation = ->
  $('#tabs').on 'click', 'a', (e) ->
  $a = $(e.target)
  $li = $a.parent()
  selector = $a.attr('data-section')
  $li.siblings().removeClass 'active'
  $li.addClass 'active'
  $('.tab-content').hide()
  $(selector).show()
  e.preventDefault()
  false

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
        showUrl("priority-data", "#{this.url}?q=#{params.term}&page=#{params.page}&per_page=10")
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
          if window.categories?
            joiner = '&' 
          else 
            joiner = '?'
          showUrl("categories-data", "#{this.url}#{joiner}q=#{params.term}&page=#{params.page}&per_page=10")
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
        showUrl("arbitrary-data", "#{this.url}?q=#{params.term}&page=#{params.page}&per_page=10")
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

initializeSelectizeBlocks = ->
  $('#sh-example-simple-select-selectize').selectize
    preload: true
    width: 'style'
    placeholder: "Choose a manufacturer"
    valueField: 'text'
    labelField: 'text'
    searchField: 'text'
    load: (query, callback) ->
      # if !query.length
      #   return callback()
      $.ajax
        url: urls['basic_url'] + "/?q=" + encodeURIComponent(query)
        type: 'GET'
        dataType: 'json'
        delay: 250
        data: (params) ->
          q: params.term
          page: params.page
          per_page: 10
        #   $('#simple-data-selectize').text JSON.stringify(data, null, 2)
          pagination:
            # If there are 10 matches, there's probably at least another page
            more: data.matches.length == 10
        cache: true
        error: ->
          callback()
          return
        success: (res) ->
          callback res.matches.slice(0, 10)
          return
      return

  $('#sh-example-priority-select-selectize').selectize
    preload: true
    width: 'style'
    placeholder: "Choose manufacturers"
    valueField: 'text'
    labelField: 'text'
    searchField: 'text'
    maxItems: null
    maxOptions: null
    load: (query, callback) ->
      # if !query.length
      #   return callback()
      $.ajax
        url: urls['priority_url'] + "/?q=" + encodeURIComponent(query)
        type: 'GET'
        dataType: 'json'
        delay: 250
        # processResults: (data, page) ->
        #   $('#simple-data').text JSON.stringify(data, null, 2)
        data: (params) ->
          q: params.term
          page: params.page
          per_page: 10
      #   $('#simple-data-selectize').text JSON.stringify(data, null, 2)
          pagination:
            # If there are 10 matches, there's probably at least another page
            more: data.matches.length == 10
        cache: true
        error: ->
          callback()
          return
        success: (res) ->
          callback res.matches.slice(0, 10)
          return
      return

  $('#sh-example-categories-select-category-selectize').selectize
    # onChange: (value) ->
    #   # console.log value
    #   # if value is null
    #   #   setItemsSelectSelectize(urls['categories_url'])
    #   # else
    #   window.selectize_categories_url = toQueryString(value)
    #   # console.log(window.selectize_categories_url)
    #   setItemsSelectSelectize(window.selectize_categories_url)
    #   setLabelTextSelectize(value)
    options: []
    preload: true
    width: 'style'
    placeholder: "Choose a category"
    valueField: 'text'
    labelField: 'text'
    searchField: 'text'
    maxItems: null
    maxOptions: null
    load: (query, callback) ->
      # if !query.length
      #   return callback()
      $.ajax
        url: "#{urls['categories_url']}/categories"
        type: 'GET'
        dataType: 'json'
        delay: 250
        data: (params) ->
          q: query,
          page_limit: 10,
          # per_page: 10
        error: ->
          callback()
          return
        success: (res) ->
          res = res.categories.map (item) -> {text: item}
          callback res
          return
      return

  $('#sh-example-categories-select-category-selectize').on "change", (e) ->
    # if $(this).val() is null
    #   $('#sh-example-categories-select-item').select2('val', 'All')
    window.selectize_categories = $(this).val()
    console.log(window.selectize_categories)
    window.selectize_categories_url = toQueryString(window.selectize_categories)
    setItemsSelectSelectize(window.selectize_categories_url)
    setLabelTextSelectize(window.selectize_categories)

  setItemsSelectSelectize = (categories_url) ->
    $('#sh-example-categories-select-item-selectize').selectize
      preload: true
      width: 'style'
      placeholder: "Choose items"
      valueField: 'text'
      labelField: 'text'
      searchField: 'text'
      maxItems: null
      maxOptions: null
      load: (query, callback) ->
        # console.log(categories_url)
        # if !query.length
        #   return callback()
        $.ajax
          url: categories_url
          type: 'GET'
          dataType: 'json'
          delay: 250
          cache: true
          error: ->
            callback()
            return
          success: (res) ->
            callback res.matches.slice(0, 10)
            # console.log(res) 
            return
        return

  # setItemsSelectSelectize(urls['categories_url'])
  setLabelTextSelectize(null)

  $('#sh-example-arbitrary-select-selectize').selectize
    preload: true
    width: 'style'
    placeholder: "Choose an emoticon"
    valueField: 'text'
    labelField: 'text'
    searchField: 'text'
    render:
      option: (item, escape) ->
        if item.category is "emoticon"
          return "<div><img src='#{escape(item.image_url)}' class='img-emoji opt-emoji' />#{escape(item.text)}</span></div>"
        else if item.category is "donger"
          return "<div><span><span class='img-donger opt-emoji'>#{escape(item.text)}</span>#{escape(item.id)}</span></div>"
      item: (item, escape) ->
        if item.category is "emoticon"
          return "<span><img src='#{escape(item.image_url)}' class='img-emoji' /></span>"
        else if item.category is "donger"
          return "<span class='img-donger'>#{escape(item.text)}</span>"
    maxItems: null
    maxOptions: null
    load: (query, callback) ->
      # if !query.length
      #   return callback()
      $.ajax
        url: urls['arbitrary_url'] + "/?q=" + encodeURIComponent(query)
        type: 'GET'
        dataType: 'json'
        delay: 250
        # processResults: (data, page) ->
        #   $('#simple-data').text JSON.stringify(data, null, 2)
        error: ->
          callback()
          return
        success: (res) ->
          callback res.matches.slice(0, 10)
          return
      return

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
  initializeSelectizeBlocks()

  $('pre').addClass('prettyprint') # Add code highlighting

  $('.example-data-block').text "// This block will display values as they are returned from the server."

  # tabNavigation()
  $(".code-toggle").click (e) ->
    e.preventDefault()
    $($(this).attr("href")).slideToggle()
    $(this).toggleClass('is-showing-code')

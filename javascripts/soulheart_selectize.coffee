---
---

setLabelText = (selection) ->
  if selection is null
    label = "Choose items from any category"
  else
    label = selection.join(" & ")
    label = label.replace /\w*/g, (txt) ->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
    label = "Choose Items from #{label} <small>from <a href='https://bikeindex.org/documentation/api_v2#!/selections' tabindex=-1>Bike Index</a></small>"
  $("#sh-example-categories-select-label").html label

initializeSelectBlocks = ->
  $('#sh-example-simple-select').selectize
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
        #   $('#simple-data').text JSON.stringify(data, null, 2)
          pagination:
            # If there are 10 matches, there's probably at least another page
            more: data.matches.length == 10
        processResults: (data, page) ->
          window.showData("priority-data", data)
          # Since sh-example-priority has ids, we don't need to map the response
          results: data.matches
          pagination:
            # If there are 10 matches, there's probably at least another page
            more: data.matches.length == 10
        cache: true
        error: ->
          callback()
          return
        success: (res) ->
          # data = res.matches
          # window.showData("priority-data", data)
          # $("#simple-data").text JSON.stringify(data, null, 2)
          # console.log data
          callback res.matches.slice(0, 10)
          return
      return

  $('#sh-example-priority-select').selectize
    plugins: ['remove_button']
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
        data: (params) ->
          window.showUrl("priority-data", "#{this.url}?q=#{params.term}&page=#{params.page}&per_page=10")
          q: params.term
          page: params.page
          per_page: 10
          pagination:
            # If there are 10 matches, there's probably at least another page
            more: data.matches.length == 10
        cache: true
        error: ->
          callback()
          return
        success: (res) ->
          baseurl = urls['priority_url']
          console.log baseurl
          showUrl("priority-data", baseurl)
          data = res.matches
          window.showData("priority-data", data)
          # console.log data
          callback res.matches.slice(0, 10)
          return
      return

  $('#sh-example-categories-select-category').selectize
    onChange: (value) ->
      # if value is null
      #   setItemsSelect(urls['categories_url'])
      # else
      window.selectize_categories_url = toQueryString(value)
      setItemsSelect(window.selectize_categories_url)
      setLabelText(value)
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

  # $('#sh-example-categories-select-category').on "change", (e) ->
  #   # if $(this).val() is null
  #   #   $('#sh-example-categories-select-item').select2('val', 'All')
  #   window.selectize_categories = $(this).val()
  #   # console.log(window.selectize_categories)
  #   window.selectize_categories_url = toQueryString(window.selectize_categories)
  #   setItemsSelect(window.selectize_categories_url)
  #   setLabelText(window.selectize_categories)

  setItemsSelect = (new_url) ->
    console.log new_url
    $('#sh-example-categories-select-item').selectize
      options: []
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
          url: new_url
          type: 'GET'
          dataType: 'json'
          delay: 250
          cache: true
          error: ->
            callback()
            return
          success: (res) ->
            data = res.matches
            window.showData("categories-data", data)
            callback res.matches.slice(0, 10)
            return
        return

  # setItemsSelect(urls['categories_url'])
  # setLabelText(null)

  $('#sh-example-arbitrary-select').selectize
    plugins: ['remove_button']
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
        error: ->
          callback()
          return
        success: (res) ->
          data = res.matches
          window.showData("arbitrary-data", data)
          callback res.matches.slice(0, 10)
          return
      return

$(document).ready ->
  initializeSelectBlocks()


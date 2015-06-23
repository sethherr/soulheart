---
---

$(document).ready ->
  formatResult = (match) ->

  $('#sh-example-simple-select').select2
    allowClear: true
    placeholder: "Choose a manufacturer"
    ajax:
      url: 'http://sh-example-simple.herokuapp.com'
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
    
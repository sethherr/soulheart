---
layout: default
title: Selectize Demos
permalink: /selectize/
---
<script type="text/javascript" src="{{ "/javascripts/soulheart_selectize.js" | prepend: site.baseurl }}"></script>

<div class="page-header"><h1><img src="https://raw.githubusercontent.com/sethherr/soulheart/master/examples/logo.png" alt="Soulheart" width="200" />
Hello, this is soulheart.
<small>Easy remote data source for autocomplete</small>
</h1></div>

<!-- <div class="tab-content" id="selectize"> -->
<h3>Set up a remote data source with zero backend programming. <br></h3>

Deploy to Heroku with the click of a button. Upload a tsv with a `text` column. Start using it.

<div class="panel panel-default" id="sh-example-simple-select-panel"><div class="panel-body"><div class="form-group">
<label>Bicycle Manufacturers <small>from <a href="https://bikeindex.org/manufacturers">Bike Index</a></small></label>
<select class="form-control" id="sh-example-simple-select" style="width: 100%;"></select>
</div></div>
</div>


<p>Here is how to deploy the above example, step by step:</p>

<ol class="step-by-step-basic">
<li>
<p>Deploy to Heroku by clicking the button <a href="https://dashboard.heroku.com/new?template=https%3A%2F%2Fgithub.com%2Fsethherr%2Fsoulheart"><img src="https://www.herokucdn.com/deploy/button.png" alt="deploy"/></a>
<br><em>This requires a verified Heroku account&mdash;you will have to add a payment method to Heroku even though you won't be charged</em>
</p>
</li>

<li>
<a href="https://devcenter.heroku.com/articles/heroku-command">Install the Heroku CLI</a> and open up a terminal window.
</li>

<li><p>Run this command in the terminal window:</p>
<pre class="with-highlight lang-sh">heroku run -a sh-example-simple soulheart load <a href="https://raw.githubusercontent.com/sethherr/soulheart/master/examples/manufacturers_simple.tsv">https://raw.githubusercontent.com/sethherr/soulheart/master/examples/manufacturers_simple.tsv</a></pre>
<div class="highlight code-highlight">Replace <code>sh-example-simple</code> with the name of your app on Heroku</div>
</li>

<li>
<p>Add <a href="https://brianreavis.github.io/selectize.js/">Selectize</a> by downloading the source files and adding them to your page:</p>
<pre>
&lt;script type="text/javascript" src="selectize.js"&gt;&lt;/script&gt;
&lt;link rel="stylesheet" type="text/css" href="selectize.css" /&gt;
</pre>
</li>

<li>
<p>Use this javascript to hook up the select box with selectize:</p>
<pre class="with-highlight">
$('#sh-example-simple-select-selectize').selectize({
  preload: true,
  valueField: 'text',
  labelField: 'text',
  searchField: 'text',
  load: function(query, callback) {
    $.ajax({
      url: "https://sh-example-simple.herokuapp.com" + "/?q=" + encodeURIComponent(query),
      type: 'GET',
      error: function() {
        callback();
      },
      success: function(res) {
        callback(res.matches.slice(0, 10));
      }
    });
  }
});
</pre>
<div class="highlight code-highlight">Replace <code>sh-example-simple</code> in <code>http://sh-example-simple.herokuapp.com</code> with the name of your app on Heroku</div>
</li>
</ol>


<div class="page-header">
<h2>Sorting by priority <small>in addition to alphanumerically</small></h2>
</div>

So, for example, let’s say you want to select bicycle manufacturers using selectize - but you want to prioritize more common manufacturers.

Some manufacturers are more popular than others - and since we expect people to be searching for more popular ones more frequently, it's important to make them show up first &mdash; for example, if you input a "t", the first manufacturer to select should be "Trek", not "Tacx".

<div class="row padded-row">
<div class="col-md-6"><div class="form-group" id="sh-example-priority-select-panel">
<label>Bicycle Manufacturers with priority <small>data from <a href="https://bikeindex.org/manufacturers">Bike Index</a></small></label>
<select class="form-control" id="sh-example-priority-select" style="width: 100%;"></select>
</div></div>
<div class="col-md-6"><pre id="priority-data" class="example-data-block with-highlight" style="height: 10em;"></pre>
<div class="highlight code-highlight" id="priority-data-url"></div></div>
</div>


<div class="special-pad"></div>
Items with equal scores are ordered alphanumerically. So in the manufacturers example above, manufacturers are grouped in broad levels of popularity - 10, 100, 250 & 500 - higher numbers show up first. This example uses [manufacturers.tsv](https://github.com/sethherr/soulheart/tree/master/examples/manufacturers.tsv)

Set a `priority` to organize the way items are ordered.

<a class="btn btn-primary code-toggle" role="button" data-toggle="collapse" href="#sh-example-priority-code" aria-expanded="false" aria-controls="collapseExample"><span class="hiding-code">Show code</span><span class="showing-code">Hide code</span></a>

<div class="code-block collapse" id="sh-example-priority-code"><pre>

</pre></div>

<div class="page-header">
<h2 id="using-categories">Categories</h2>
</div>

Search for items in only one category by adding a `category` parameter:

<div class="panel panel-default" id="sh-example-categories-select-panel"><div class="panel-body">
<div class="col-sm-4">
<div class="form-group">
<label>Choose Categories</label>
<select class="form-control" id="sh-example-categories-select-category" style="width: 100%;"></select>
</div></div>
<div class="col-sm-8">
<div class="form-group">
<label id="sh-example-categories-select-label"></label>
<select class="form-control" id="sh-example-categories-select-item" style="width: 100%;"></select>
</div></div>
</div>
</div>

<div><pre id="categories-data" class="example-data-block with-highlight" style="height: 10em;"></pre>
<div class="highlight code-highlight" id="categories-data-url"></div></div>



This example uses <a href="https://raw.githubusercontent.com/sethherr/soulheart/master/examples/categories.json">categories.json</a>, which includes a whole host of options from the <a href="https://bikeindex.org/documentation/api_v2#!/selections/">Bike Index API</a>. Say that, instead of searching the full list, you only want to view options for handlebar types.

All categories are available at the Heroku app's url + `/categories`. So start by pulling options into the category select box from: 
<pre><a href="https://sh-example-categories.herokuapp.com/categories">https://sh-example-categories.herokuapp.com/categories</a></pre>

When the category changes, you want to grab the value and add it to your url as a query. This becomes the source for the items select box:

<pre>
<a href="https://sh-example-categories.herokuapp.com?categories=handlebar%20types">https://sh-example-categories.herokuapp.com?categories=handlebar%20types</a>
</pre>


Search for items in multiple categories by separating them with commas:
<pre>
<a href="https://sh-example-categories.herokuapp.com?categories=colors,component%20types">https://sh-example-categories.herokuapp.com?categories=colors,component%20types</a>
</pre>

<a class="btn btn-primary code-toggle" role="button" data-toggle="collapse" href="#sh-example-categories-code" aria-expanded="false" aria-controls="collapseExample"><span class="hiding-code">Show code</span><span class="showing-code">Hide code</span></a>

<div class="code-block collapse" id="sh-example-categories-code"><pre>

</pre>
</div>

<div class="page-header">
  <h2 id="using-data">Arbitrary return data</h2>
</div>

Any column that isn't `category`, `text` or `priority` will be returned as well.

<div class="panel panel-default" id="sh-example-arbitrary-select-panel"><div class="panel-body"><div class="form-group">
<label>Emoticons</label>
<select  class="form-control" id="sh-example-arbitrary-select" style="width: 100%;"></select>
</div></div>
</div>

<div><pre id="arbitrary-data" class="example-data-block with-highlight" style="height: 10em;"></pre>
<div class="highlight code-highlight" id="arbitrary-data-url"></div></div>

Here, the <a href="https://github.com/sethherr/soulheart/blob/master/examples/emoticons.json">emoticons.json</a> example file includes `id`, `image_url` and `source` fields. These values are returned and available for incorporation into the select box. 

Through the magic of the <a href="https://github.com/brianreavis/selectize.js/blob/master/docs/usage.md#rendering">selectize rendering options</a>, emoticon images are displayed in the dropdown along with their `text`, `category` and `source` details:
<pre>

</pre>

Once an item is selected, we can opt to display only its image:
<pre>

</pre>

<a class="btn btn-primary code-toggle" role="button" data-toggle="collapse" href="#sh-example-arbitrary-code" aria-expanded="false" aria-controls="collapseExample"><span class="hiding-code">Show code</span><span class="showing-code">Hide code</span></a>

<div class="code-block collapse" id="sh-example-arbitrary-code"><pre>

</pre>
</div>

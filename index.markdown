---
layout: default
---

<div class="page-header"><h1><img src="https://raw.githubusercontent.com/sethherr/soulheart/master/examples/logo.png" alt="Soulheart" width="200" />
Hello, this is soulheart.
<small>Easy remote data source for autocomplete</small>
</h1></div>

<h3>Set up a remote data source with zero backend programming. <br></h3>

Deploy to Heroku with the click of a button. Upload a tsv with a `text` column. Start using it.

<div class="panel panel-default" id="sh-example-simple-select-panel"><div class="panel-body"><div class="form-group">
<label>Bicycle Manufacturers <small>from <a href="https://bikeindex.org/manufacturers">Bike Index</a></small></label>
<select class="form-control" id="sh-example-simple-select"></select>
</div></div>
</div>

<p>Here is how to deploy the above example, step by step:</p>

<ol class="step-by-step-basic">
<li>
Deploy to Heroku by clicking <a href="https://dashboard.heroku.com/new?template=https%3A%2F%2Fgithub.com%2Fsethherr%2Fsoulheart"><img src="https://www.herokucdn.com/deploy/button.png" alt="deploy" /></a>
</li>

<li>
<a href="https://devcenter.heroku.com/articles/heroku-command">Install the Heroku CLI</a> and open up a terminal window.
</li>

<li>Run this command in the command prompt <em>replace "sh-example-simple" with the name of your app on Heroku</em>:
<pre>heroku run -a sh-example-simple soulheart load <a href="https://raw.githubusercontent.com/sethherr/soulheart/master/examples/manufacturers_simple.tsv">https://raw.githubusercontent.com/sethherr/soulheart/master/examples/manufacturers_simple.tsv</a></pre>
</li>

<li>Add <a href="https://select2.github.io/">Select2</a>

<pre>
&lt;link href="//cdnjs.cloudflare.com/ajax/libs/select2/4.0.0/css/select2.min.css" rel="stylesheet" /&gt;
&lt;script src="//cdnjs.cloudflare.com/ajax/libs/select2/4.0.0/js/select2.min.js"&gt;&lt;/script&gt;
</pre>

and a select box to your html page:
<pre>
&lt;select id="basic-example-select"&gt;&lt;/select&gt;
</pre>

</li>

<li>Use this javascript to hook up the select box with select2:

<em>Once again, replace "sh-example-simple" with the name of your app on Heroku</em>:

<pre>
$('#sh-example-simple-select').select2({
  allowClear: true,
  placeholder: "Choose a manufacturer",
  ajax: {
    url: 'http://sh-example-simple.herokuapp.com',
    dataType: 'json',
    delay: 250,
    data: function(params) {
      return {
        q: params.term,
        page: params.page,
        per_page: 10
      };
    },
    processResults: function(data, page) {
      return {
        // Select2 requires an id, so we need to map the results and add an ID
        // You could instead include an id in the tsv you add to soulheart ;)
        results: data.matches.map(function(item) {
          return {
            id: item.text,
            text: item.text
          };
        }),

        pagination: {
          // If there are 10 matches, there's at least another page
          more: data.matches.length === 10
        }
      };
    },
    cache: true
  }
});
    </pre>
  </li>
</ol>


<div class="page-header">
<h2>Sorting by priority <small>in addition to alphanumerically</small></h2>
</div>

So, for example, let’s say you want to select bicycle manufacturers using select2 - but you want to prioritize more common manufacturers.

Some manufacturers are more popular than others - and since we expect people to be searching for more popular ones more frequently, it's important to make them show up first &mdash; for example, if you input a "t", the first manufacturer to select should be "Trek", not "Tacx".

<div class="panel panel-default" id="sh-example-priority-select-panel"><div class="panel-body"><div class="form-group">
<label>Bicycle Manufacturers with priority <small>data from <a href="https://bikeindex.org/manufacturers">Bike Index</a></small></label>
<select class="form-control" id="sh-example-priority-select"></select>
</div></div>
</div>
<div class="special-pad"></div>
Items with equal scores are ordered alphanumerically. So in the manufacturers example above, manufacturers are grouped in broad levels of popularity - 10, 100, 250 & 500 - higher numbers show up first. This example uses [manufacturers.tsv](https://github.com/sethherr/soulheart/tree/master/examples/manufacturers.tsv)

Set a `priority` to organize the way items are ordered.

<div class="page-header">
<h2 id="using-categories">Categories</h2>
</div>

Search for items in only one category by adding a `categories` parameter:

<pre>
<a href="http://sh-example-simple.herokuapp.com?categories=manufacturer">http://sh-example-simple.herokuapp.com?categories=manufacturer</a>
</pre>

<p>Search for items in any of the included categories by seperating the categories with commas:</p>

<pre>
<a href="http://sh-example-simple.herokuapp.com/?categories=manufacturer,frame%20manufacturer">http://sh-example-simple.herokuapp.com/?categories=manufacturer,frame%20manufacturer</a>
</pre>



<div class="page-header">
  <h2 id="using-data">Arbitrary return data</h2>
</div>

Any column that isn't `categroy`, `text` or `priority` will be returned as well.

I'd like this to be an example of emoticons & emojis




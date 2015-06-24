---
layout: default
---

<div class="page-header"><h1><img src="https://raw.githubusercontent.com/sethherr/soulheart/master/logo.png" alt="Soulheart" width="200" />
Hello. This is soulheart.
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
<pre>heroku run -a sh-example-simple soulheart load <a href="https://raw.githubusercontent.com/sethherr/soulheart/gh-pages/example_sources/manufacturers_simple.tsv">https://raw.githubusercontent.com/sethherr/soulheart/gh-pages/example_sources/manufacturers_simple.tsv</a></pre>
</li>

<li>Add a select box to your page, <code>&lt;select id="basic-example-select"&gt;&lt;/select&gt;</code>, then use this javascript to hook up the select box with select2:

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
<label>Bicycle Manufacturers with priority <small>from <a href="https://bikeindex.org/manufacturers">Bike Index</a></small></label>
<select class="form-control" id="sh-example-priority-select"></select>
</div></div>
</div>

Items with equal scores are ordered alphanumerically. So in the manufacturers example above, manufacturers are grouped in broad levels of popularity - 10, 100, 250 & 500 - higher numbers show up first. This example uses [manufacturers.tsv](https://github.com/sethherr/soulheart/blob/gh-pages/example_sources/manufacturers.tsv)

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

<p>Any column that isn't <code>categroy</code>, <code>text</code> or <code>priority</code> will be returned as well.</p>


<div class="page-header">
  <h2 id="formatting">Formatting data</h2>
</div>

<p>You can add data from JSON, CSV and TSV files.</p>

<p>Items can be very simple - all that is required is a <code>text</code> value.</p>

<p>A <code>text</code> column or key is required.</p>

<p>So the simplest thing to load is a csv that looks like this:</p>

<table class="table table-striped table-bordered">
  <thead>
    <tr>
      <th>Text</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Apple</td>
    </tr>
    <tr>
      <td>Orange</td>
    </tr>
    <tr>
      <td>Pear</td>
    </tr>
    <tr>
      <td>Banana</td>
    </tr>
  </tbody>
</table>


<h4>Optional attributes: <small>if you have a <a class="scroll-to-ref" href="#using-priority">priority</a>, <a class="scroll-to-ref" href="#using-categories">category</a>, or a <a class="scroll-to-ref" href="#using-data">data hash</a>, it will use them as explained above.</small></h4>


<p>Here is an excerpt of <a href="https://github.com/sethherr/soulheart/blob/gh-pages/example_sources/manufacturers.tsv">the tsv that was loaded in for the priority example</a>:</p>

<table class="table table-striped table-bordered">
  <thead>
    <tr>
      <th>text</th>
      <th>category</th>
      <th>priority</th>
      <th>website</th>
      <th>logo</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>All City</td>
      <td>Frame manufacturer</td>
      <td>100</td>
      <td>http://allcitycycles.com</td>
      <td>https://files.bikeindex.org/uploads/Ma/371/all-city.png</td>
    </tr>
    <tr>
      <td>Salsa</td>
      <td>Frame manufacturer</td>
      <td>250</td>
      <td>http://salsacycles.com/</td>
      <td></td>
    </tr>
    <tr>
      <td>Sunday</td>
      <td>Frame manufacturer</td>
      <td>10</td>
      <td>http://www.sundaybikes.com</td>
      <td></td>
    </tr>
    <tr>
      <td>SRAM</td>
      <td>Manufacturer</td>
      <td>250</td>
      <td>http://www.sram.com</td>
      <td></td>
    </tr>
    <tr>
      <td>Surly</td>
      <td>Frame manufacturer</td>
      <td>500</td>
      <td>http://surlybikes.com</td>
      <td></td>
    </tr>
  </tbody>
</table>


A result from <a href="https//sh-example-priority.herokuapp.com">sh-example-priority.herokuapp.com</a>, the place where the above data is loaded, looks like:

    {
      "text": "Surly",
      "category":"Frame manufacturer",
      "website":"http://surlybikes.com",
      "logo":null
    }



<h4 id="for-json">For JSON</h4>

Soulheart uses [line delineated JSON streams](https://en.wikipedia.org/wiki/JSON_Streaming#Line_delimited_JSON), so it doesn’t have to load the whole file into memory. Which just means - put each object onto a seperate line.

Here is the above example as a json stream:


    {"text": "All City", "category": "Frame manufacturer", "priority": 100, "website": "http://allcitycycles.com", "logo": "https://files.bikeindex.org/uploads/Ma/371/all-city.png"}
    {"text": "Salsa", "category": "Frame manufacturer", "priority": 250, "website": "http://salsacycles.com/"} 
    {"text": "Sunday", "category": "Frame manufacturer", "priority": 10, "website": "http://www.sundaybikes.com"}
    {"text": "SRAM", "category": "Manufacturer", "priority": 250, "website": "http://www.sram.com" }
    {"text": "Surly", "category": "Frame manufacturer", "priority": 500, "website": "http://surlybikes.com"}


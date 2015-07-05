---
layout: default
title: Loading data
permalink: /loading_data/
---

<div class="page-header">
<h1>Loading data</h1>
</div>

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


<p>Here is an excerpt of <a href="https://github.com/sethherr/soulheart/tree/master/example_data_sources/manufacturers.tsv">the tsv that was loaded in for the priority example</a>:</p>

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


<div class="page-header">
<h2 id="aliases">Aliases</h2>
</div>

You can also include aliases in the data you load. Soulheart will match across those aliases.
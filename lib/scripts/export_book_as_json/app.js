#!/usr/bin/env node
(function () {
  // usage example: node app.js --url=http://stage-dl-pa.home.nyu.edu/books --start=0 --rows=10
  var request = require('request');
  var fs = require('fs');  
  var argv = require('minimist')(process.argv.slice(2));
  var auth = { 'user': 'alpha-user', 'pass': 'dlts2010', 'sendImmediately': true };  
  var start = (argv.start) ? argv.start : 0;
  var rows = (argv.rows) ? argv.rows : 10;
  var apiUrl = (argv.url) ? argv.url : 'http://stage-dl-pa.home.nyu.edu/books';
  console.log('Start ' + start);
  console.log('Rows ' + rows);
  function books_callback (error, response, body) {    
    if (!error && response.statusCode == 200) {
      var data = JSON.parse(body);
      data.response.docs.forEach(function(element) {
    	console.log('Book ' + element.entity_title + ' saved!');
    	var entity_language = element.entity_language;
    	if (entity_language == 'und') entity_language = 'en'
    	fs.writeFile(require('path').dirname(require.main.filename) + '/data/' + element.identifier + '.' + entity_language + '.json', JSON.stringify(element));
      });      
    }
  }
  request({ 'url' : apiUrl + '/books.json?rows=' + rows + ' &start=' + start + '&getRaw=true', 'auth': auth }, books_callback);
})();

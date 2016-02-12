#!/usr/bin/env node
(function () {	
  var request = require('request');
  var apiUrl = 'http://stage-dl-pa.home.nyu.edu/books';
  var auth = { 'user': 'alpha-user', 'pass': 'dlts2010', 'sendImmediately': true };  
  var start = 500;  
  var rows = 500;
  function book_callback (error, response, body) {
    var fs = require('fs');
    if ( !error && response.statusCode == 200) {
      var data = JSON.parse(body);
      fs.writeFile(require('path').dirname(require.main.filename) + '/data/' + data.identifier + '.json', JSON.stringify(data));
    }
  }  
  function books_callback (error, response, body) {
    if ( ! error && response.statusCode == 200) {
      var data = JSON.parse(body);
      data.response.docs.forEach( function( element, index, array ) {
    	console.log ( 'Requesting book ' + element.entity_title );
        request( { 'url' : apiUrl + '/books/' + element.identifier  + '/book.json?getRaw=true&limit=' + element.metadata.sequence_count.value[0], 'auth': auth }, book_callback);
      });
    }
  }  
  function init (error, response, body) {	
    if (!error && response.statusCode == 200) {
      var data = JSON.parse(body);
	  var numFound = data.response.numFound;	  
	  var start = parseInt(data.response.start,10) + rows;	  
      request( { 'url' : apiUrl + '/books.json?getRaw=true&rows=' + rows + '&start=' + start, 'auth': auth }, books_callback);          
    }
  }  
  request({ 'url' : apiUrl + '/books.json?rows=0&start=' + start, 'auth': auth }, init);  
})();

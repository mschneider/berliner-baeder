var $, baseUrl, berlin, parseBath, parseBathList, request;

berlin = require('./berlin.json');

request = require('request');

$ = require('jQuery');

baseUrl = 'http://www.berlinerbaederbetriebe.de/';

parseBath = function(body) {
  return $(body).find('div#content > p').each(function(index, p) {
    return console.log($(p).text());
  });
};

parseBathList = function(body) {
  return $(body).find('div#content > p > a').each(function(index, bathLink) {
    var href;
    href = $(bathLink).attr('href');
    return request(baseUrl + href, function(error, response, body) {
      if (!error && response.statusCode === 200) {
        console.log("found bath", href);
        return parseBath(body);
      }
    });
  });
};

request(baseUrl + '24.html', function(error, response, body) {
  if (!error && response.statusCode === 200) return parseBathList(body);
});

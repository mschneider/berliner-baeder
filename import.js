var $, baseUrl, berlin, fs, parseBath, parseBathList, parseTimeTable, request, _;

berlin = require('./berlin.json');

fs = require('fs');

request = require('request');

$ = require('jQuery');

_ = require('underscore');

_.str = require('underscore.string');

_.mixin(_.str.exports());

baseUrl = 'http://www.berlinerbaederbetriebe.de/';

parseBath = function(body) {
  var bath, features, name, text, time_table;
  name = $(body).find('#content h1:first').text();
  features = [];
  text = $(body).find('#content').text();
  if (_.str.include(text, '25-m-Becken')) features.push('25-m-Becken');
  if (_.str.include(text, '50-m-Becken')) features.push('50-m-Becken');
  time_table = $(body).find('#content_ul > table:first');
  return bath = {
    'name': name,
    'features': features,
    'openingTimes': parseTimeTable(time_table)
  };
};

parseBathList = function(body, cb) {
  var bathLinks, result, returnResult;
  bathLinks = $(body).find('div#content > p > a');
  result = [];
  returnResult = _.after(bathLinks.length, function() {
    return cb(result);
  });
  return bathLinks.each(function(index, bathLink) {
    var href;
    href = $(bathLink).attr('href');
    return request(baseUrl + href, function(error, response, body) {
      if (!error && response.statusCode === 200) {
        result.push(parseBath(body));
        return returnResult();
      }
    });
  });
};

parseTimeTable = function(table) {
  var lastDay, result;
  result = {};
  lastDay = void 0;
  $(table).find('tr').each(function(index, row) {
    var comment, day, time, _ref;
    _ref = _.map($(row).find('td'), function(node) {
      return _.trim($(node).text());
    }), day = _ref[0], time = _ref[1], comment = _ref[2];
    day || (day = lastDay);
    result[day] || (result[day] = {});
    result[day][time] = comment;
    return lastDay = day;
  });
  return result;
};

request(baseUrl + '24.html', function(error, response, body) {
  if (!error && response.statusCode === 200) {
    return parseBathList(body, function(baths) {
      return console.log(JSON.stringify(baths));
    });
  }
});

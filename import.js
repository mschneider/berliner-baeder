var $, BathParser, baseUrl, baths, berlin, fs, gm, request, writeBaths, _;

berlin = require('./berlin.json');

fs = require('fs');

gm = require('googlemaps');

request = require('request');

$ = require('jQuery');

_ = require('underscore');

_.str = require('underscore.string');

_.mixin(_.str.exports());

baseUrl = 'http://www.berlinerbaederbetriebe.de/';

BathParser = (function() {

  function BathParser(body) {
    this.body = body;
  }

  BathParser.prototype.run = function(cb) {
    var result;
    result = {
      address: this.address(),
      name: this.name(),
      laneLength: this.laneLength(),
      openingTimes: this.openingTimes()
    };
    return gm.geocode(result.address, function(error, response) {
      var location;
      if (!error && response.status === 'OK') {
        location = response.results[0].geometry.location;
        result.location = {
          lat: location.lat,
          lng: location.lng
        };
        console.log('finished', result.name);
        return cb(result);
      } else {
        console.log('could not geocode', result.address);
        return cb();
      }
    });
  };

  BathParser.prototype.address = function() {
    var lines;
    lines = this.body.find('#content_left p:first b').html().split('<br>');
    return lines[0] + ', ' + lines[1];
  };

  BathParser.prototype.name = function() {
    return this.body.find('#content h1:first').text();
  };

  BathParser.prototype.laneLength = function() {
    var content;
    content = this.body.find('#content').text();
    if (_.str.include(content, '50-m-Becken')) {
      return '50m';
    } else {
      return '25m';
    }
  };

  BathParser.prototype.openingTimes = function() {
    var lastDay, result, that;
    result = {};
    lastDay = '';
    that = this;
    this.body.find('#content_ul > table:first tr').each(function(index, row) {
      var comment, day, time, _ref;
      _ref = _.map($(row).find('td'), function(node) {
        return _.trim($(node).text());
      }), day = _ref[0], time = _ref[1], comment = _ref[2];
      day || (day = lastDay);
      if (time) that.addTimeTableEntry(result, day, time, comment);
      return lastDay = day;
    });
    return result;
  };

  BathParser.prototype.cleanComment = function(comment) {
    if (_.str.include(comment, 'Parallelbetrieb')) {
      comment = _.str.insert(comment, 'Parallelbetrieb'.length, ' ');
      comment = comment.split('/ ').join('/');
    }
    return comment = _.trim(comment, '*');
  };

  BathParser.prototype.addTimeTableEntry = function(openingTimes, day, time, comment) {
    var from, newEntry, to, _ref;
    _ref = time.split(' - '), from = _ref[0], to = _ref[1];
    comment = this.cleanComment(comment);
    if (comment) {
      newEntry = {
        from: from,
        to: to,
        comment: comment
      };
    } else {
      newEntry = {
        from: from,
        to: to
      };
    }
    openingTimes[day] || (openingTimes[day] = []);
    return openingTimes[day].push(newEntry);
  };

  return BathParser;

})();

baths = [];

writeBaths = function() {
  var content, openedBaths;
  openedBaths = _.reject(baths, function(bath) {
    return _.isEmpty(bath.openingTimes);
  });
  content = 'Baths = ' + JSON.stringify(openedBaths);
  console.log('writing to baths.json');
  return fs.writeFile('baths.json', content, function(err) {
    if (err) throw err;
  });
};

request(baseUrl + '24.html', function(error, response, body) {
  var bathLinks, requestFinished;
  if (!error && response.statusCode === 200) {
    bathLinks = $(body).find('div#content > p > a');
    requestFinished = _.after(bathLinks.length, writeBaths);
    console.log('crawling', bathLinks.length, 'baths');
    return bathLinks.each(function(index, bathLink) {
      var href;
      href = $(bathLink).attr('href');
      return request(baseUrl + href, function(error, response, body) {
        if (!error && response.statusCode === 200) {
          return new BathParser($(body)).run(function(bath) {
            if (bath) baths.push(bath);
            return requestFinished();
          });
        } else {
          console.log('could not fetch:', baseUrl + href);
          return requestFinished();
        }
      });
    });
  }
});

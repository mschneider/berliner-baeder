var App;

App = {
  distance: function(position, station) {
    var lat1, lat2, lon1, lon2, x, y;
    lat1 = position.coords.latitude;
    lon1 = position.coords.longitude;
    lat2 = Number(station.lat);
    lon2 = Number(station.lon);
    x = (lon2 - lon1) * Math.cos((lat1 + lat2) / 2);
    y = lat2 - lat1;
    return Math.sqrt(x * x + y * y);
  },
  findBaths: function(position) {
    var closest, station, _i, _len;
    console.log("you are at:", position.coords.latitude, position.coords.longitude);
    for (_i = 0, _len = Stations.length; _i < _len; _i++) {
      station = Stations[_i];
      closest || (closest = station);
      station.distance = this.distance(position, station);
      if (closest.distance > station.distance) closest = station;
    }
    return console.log("closest:", closest);
  }
};

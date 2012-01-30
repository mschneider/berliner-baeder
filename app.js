var App;

App = {
  distance: function(position, bath) {
    var lat1, lat2, lng1, lng2, x, y;
    lat1 = position.coords.latitude;
    lng1 = position.coords.longitude;
    lat2 = Number(bath.location.lat);
    lng2 = Number(bath.location.lng);
    x = (lng2 - lng1) * Math.cos((lat1 + lat2) / 2);
    y = lat2 - lat1;
    return Math.sqrt(x * x + y * y);
  },
  findBaths: function(position) {
    var bath, closestBath, _i, _len;
    console.log("you are at:", position.coords.latitude, position.coords.longitude);
    for (_i = 0, _len = Baths.length; _i < _len; _i++) {
      bath = Baths[_i];
      closestBath || (closestBath = bath);
      bath.distance = App.distance(position, bath);
      if (closestBath.distance > bath.distance) closestBath = bath;
    }
    return console.log("closest bath:", closestBath);
  }
};

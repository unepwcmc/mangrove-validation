var map;
var projection;
var MERCATOR_RANGE = 256;
var infowindow;
var trackData = [];
var stripes1;
var stripes2;
var stripes3;
var globalMaptile = new GlobalMercator();
var start_latlng;

function bound(value, opt_min, opt_max) {
  if (opt_min != null) value = Math.max(value, opt_min);
  if (opt_max != null) value = Math.min(value, opt_max);
  return value;
}

function degreesToRadians(deg) {
  return deg * (Math.PI / 180);
}

function radiansToDegrees(rad) {
  return rad / (Math.PI / 180);
}  

function MercatorProjection() {
  this.pixelOrigin_ = new google.maps.Point(
    MERCATOR_RANGE / 2, MERCATOR_RANGE / 2);
  this.pixelsPerLonDegree_ = MERCATOR_RANGE / 360;
  this.pixelsPerLonRadian_ = MERCATOR_RANGE / (2 * Math.PI);
};

function getTileByLatLng(latlng) {
  var worldCoordinate = projection.fromLatLngToPoint(latlng);
  var pixelCoordinate = new google.maps.Point(worldCoordinate.x * Math.pow(2, map.getZoom()), worldCoordinate.y * Math.pow(2, map.getZoom()));
  var tileCoordinate = new google.maps.Point(Math.floor(pixelCoordinate.x / MERCATOR_RANGE), Math.floor(pixelCoordinate.y / MERCATOR_RANGE));

  var tileCoordStr = "Tile Coordinate: " + tileCoordinate.x + " , " + tileCoordinate.y + " at Zoom Level: " + map.getZoom();
  console.log(tileCoordStr);
}

MercatorProjection.prototype.fromLatLngToPoint = function(latLng, opt_point) {
  var me = this;

  var point = opt_point || new google.maps.Point(0, 0);

  var origin = me.pixelOrigin_;
  point.x = origin.x + latLng.lng() * me.pixelsPerLonDegree_;
  // NOTE(appleton): Truncating to 0.9999 effectively limits latitude to
  // 89.189.  This is about a third of a tile past the edge of the world tile.
  var siny = bound(Math.sin(degreesToRadians(latLng.lat())), -0.9999, 0.9999);
  point.y = origin.y + 0.5 * Math.log((1 + siny) / (1 - siny)) * -me.pixelsPerLonRadian_;
  return point;
}; 

MercatorProjection.prototype.fromPointToLatLng = function(point) {
  var me = this;

  var origin = me.pixelOrigin_;
  var lng = (point.x - origin.x) / me.pixelsPerLonDegree_;
  var latRadians = (point.y - origin.y) / -me.pixelsPerLonRadian_;
  var lat = radiansToDegrees(2 * Math.atan(Math.exp(latRadians)) - Math.PI / 2);
  return new google.maps.LatLng(lat, lng);
}; 

function CoordMapType(tileSize) {
  this.tileSize = tileSize;
}

CoordMapType.prototype.getTile = function(coord, zoom, ownerDocument) {
  var canvas = document.createElement("canvas");
  var id = 'id-' + coord.x + '-' + coord.y + '-' + zoom;

  if (typeof G_vmlCanvasManager != 'undefined') 
    G_vmlCanvasManager.initElement(canvas);

  canvas.id = id;
  canvas.width = canvas.height = 256;
  canvas.style.width = '256px';
  canvas.style.height = '256px';	
  canvas.style.left = '0px';
  canvas.style.top =  '0px';
  canvas.style.position = "relative";    

  var ctx = canvas.getContext("2d");
  var cross = canvas.getContext('2d');

  ctx.strokeStyle = "#FFF";
  ctx.lineWidth   = 1;
  ctx.beginPath();

  var cells = 4;
  if(zoom==16) {
    cells = 2;
  }    
  if(zoom==17) {
    cells = 1;
  }    

  if(zoom==14) {
    cells = 8;
  }
  if(zoom==13) {
    cells = 16;
  }    


  var cellsSize = 256/cells;
  for (var i = 0; i < cells; i++) {
    ctx.moveTo(0, (cellsSize*i));
    ctx.lineTo(256,(cellsSize*i));
    ctx.moveTo((cellsSize*i),0);
    ctx.lineTo((cellsSize*i),256);  
  }        
  ctx.stroke();    

  ctx.fillStyle    = 'red';
  ctx.font         = 'bold 10px sans-serif'
  //ctx.fillText(zoom + ' / '+coord.x+ ' / '+coord.y, 10, 10);

  cross.strokeStyle = "#FFF";
  cross.lineWidth   = 2;
  cross.beginPath();

  for (var i = 0; i < cells; i++) {
    cross.moveTo(0, (cellsSize*i));
    cross.lineTo(10,(cellsSize*i));

    for (var j = 1; j < cells; j++) {
      cross.moveTo((cellsSize*j)-10, cellsSize*i);
      cross.lineTo((cellsSize*j)+10, cellsSize*i);
    }

    cross.moveTo(256, (cellsSize*i));
    cross.lineTo(246,(cellsSize*i));


    cross.moveTo((cellsSize*i),0);
    cross.lineTo((cellsSize*i),10);

    for (var j = 1; j < cells; j++) {
      cross.moveTo(cellsSize*i, (cellsSize*j)-10 );
      cross.lineTo(cellsSize*i,(cellsSize*j)+10);
    }

    cross.moveTo((cellsSize*i), 256);
    cross.lineTo((cellsSize*i), 246);
  }        
  cross.stroke();

  return canvas;
};

function openInfoWindow(latlng) {
  if (infowindow!=null) {
    infowindow.moveTo(latlng);
  } else {
    infowindow = new InfoWindow(latlng, map);
  }
}

function initialize() {
  $.ajax({
    type: "POST",
    url: "/tracks",
    success: function(result){
      projection = new MercatorProjection();
      trackData = result;
      start_latlng = getCellCenter(trackData[0].x, trackData[0].y, 17);

      meters = globalMaptile.LatLonToMeters(start_latlng.lat(),start_latlng.lng());
      pixels = globalMaptile.MetersToPixels(meters[0],meters[1],17);

      $.ajax({
        type: "GET",
        dataType: 'jsonp',
        url: 'http://khm0.google.com/mz?x='+trackData[0].x+'&y='+trackData[0].y+'&z=17&v=62',
        success: function(result){
          console.log(result.zoom);
          if (parseInt(result.zoom)<15) {
            initialize();
          } else {
            var mapOptions = {
              zoom: 15,
              scrollwheel: false,
              center: start_latlng,
              mapTypeId: google.maps.MapTypeId.SATELLITE,
              mapTypeControl: false,
              navigationControl: false,
              scaleControl: false,
              streetViewControl: false,
              disableDoubleClickZoom: true
            };
            map = new google.maps.Map(document.getElementById("map_canvas"),mapOptions);

            map.setCenter(start_latlng);
            google.maps.event.addListener(map, 'zoom_changed', function() {
              map.setZoom(15);
            });

            //infowindow = new InfoWindow(start_latlng, map, trackData);

            setTimeout('map.overlayMapTypes.insertAt(0, new CoordMapType(new google.maps.Size(256, 256)))',1000);
            setTimeout('map.overlayMapTypes.insertAt(0, new FillMap(new google.maps.Size(256, 256)))',1000);

            hideLoading();
          }
        }
      });
    }
  });
}

function getNewTrack() {
  infowindow.setMap(null);
  showLoading();
  $.ajax({
    type: "POST",
    url: "/tracks",
    success: function(result){
      projection = new MercatorProjection();
      trackData = result;
      start_latlng = getCellCenter(trackData[0].x, trackData[0].y, 17);

      meters = globalMaptile.LatLonToMeters(start_latlng.lat(),start_latlng.lng());
      pixels = globalMaptile.MetersToPixels(meters[0],meters[1],17);

      $.ajax({
        type: "GET",
        dataType: 'jsonp',
        url: 'http://khm0.google.com/mz?x='+trackData[0].x+'&y='+trackData[0].y+'&z=17&v=62',
        success: function(result){
          console.log(result.zoom);
          if (parseInt(result.zoom)<15) {
            getNewTrack();
          } else {
            map.setCenter(start_latlng);
            infowindow = new InfoWindow(start_latlng, map, trackData);

            hideLoading();
          }
        }
      });
    }
  });
}

function FillMap(tileSize) {
  this.tileSize = tileSize;
}

FillMap.prototype.getTile = function(coord, zoom, ownerDocument) {
  var canvas = document.createElement("canvas");
  if (typeof G_vmlCanvasManager != 'undefined') 
    G_vmlCanvasManager.initElement(canvas);

  var id = 'id-' + coord.x + '-' + coord.y + '-' + zoom;

  canvas.id = id;
  canvas.width = canvas.height = 256;
  canvas.style.width = '256px';
  canvas.style.height = '256px';	
  canvas.style.left = '0px';
  canvas.style.top =  '0px';
  canvas.style.position = "relative";	

  $.ajax({
    type: "GET",
    url: "tiles/"+coord.x+"/"+coord.y+'/15',
    success: function(result){	
      var context = canvas.getContext("2d");
      var cellsSize = 64;

      stripes1 = new Image();
      stripes1.src = "images/stripes.png";
      stripes2 = new Image();
      stripes2.src = "images/stripes_2.png";
      stripes3 = new Image();
      stripes3.src = "images/stripes_3.png";
				
      var x_coord = Math.floor(coord.x*4);
      var y_coord = Math.floor(coord.y*4);

      stripes3.onload = function() {
        var x=0, y=0;
        for (var i = x_coord; i < (x_coord + 4); i++) {
          for (var j = y_coord; j< (y_coord + 4); j++) {
            var image = checkCellType(result,i,j);
            if (image!=null) {
              context.drawImage(image, (cellsSize*x), (cellsSize*y));
            }
            y = y+1;
          }
          y = 0;
          x = x+1;
        }
      };
    }
  });
  return canvas;
};

function checkCellType(data, coord_x, coord_y) {
  for(var i=0; i<data.length; i++) {
    if(data[i].x == coord_x && data[i].y == coord_y) {
      return stripes1;
    }
  }
  return null;
}

function getCellCenter(x,y,zoom) {
  var google_tiles = globalMaptile.GoogleTile(x, y, 17);
  var obj = globalMaptile.TileLatLonBounds(google_tiles[0],google_tiles[1],17);
  var latlngbounds = new google.maps.LatLngBounds();

  latlngbounds.extend(new google.maps.LatLng(obj[0],obj[1]));
  latlngbounds.extend(new google.maps.LatLng(obj[2],obj[3]));

  return latlngbounds.getCenter();
}
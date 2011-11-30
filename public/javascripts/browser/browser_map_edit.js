var poly;
var markers = [];
var path = new google.maps.MVCArray;

function initializeMapEdition() {
  poly = new google.maps.Polygon({
    strokeWeight: 2,
    fillColor: '#00FF00',
    editable: true
  });
  poly.setMap(map);
  poly.setPaths(new google.maps.MVCArray([path]));

  google.maps.event.addListener(path, 'insert_at', pathChange);
  google.maps.event.addListener(path, 'set_at', pathChange);

  google.maps.event.addListener(map, 'click', addPoint);

  google.maps.event.addListener(poly, 'dblclick', changePolyColor);
}

function changePolyColor(event) {
  if(poly.fillColor == "#00FF00") {
    poly.setOptions({fillColor: "#FF0000"});
  } else {
    poly.setOptions({fillColor: "#00FF00"});
  }
  
  console.log(poly.fillColor);
}

function addPoint(event) {
  // Insert path
  path.insertAt(path.length, event.latLng);
  // Update Grid
  updateGrid();
}

function pathChange() {
  // Update Grid
  updateGrid();
}

function updateGrid() {
  var tile_coordinates = [], i, j,
    min_x, max_x, min_y, max_y,
    canvas, zoom = map.getZoom();
  
  // Path as to be at least a triangle
  if(path.length < 3) {
    return;
  }

  // Get all the grids that COULD intersect the path
  for(i = 0; i < path.length; i++) {
    tile_coordinates.push(getTileCoordinates(path.getAt(i)).tileCoordinate);
  }

  // Get min and max values for X and Y of the tiles
  for(i = 0; i < tile_coordinates.length; i++) {
    min_x = min_x ? (min_x > tile_coordinates[i].x ? tile_coordinates[i].x : min_x) : tile_coordinates[i].x;
    max_x = max_x ? (max_x < tile_coordinates[i].x ? tile_coordinates[i].x : max_x) : tile_coordinates[i].x;
    min_y = min_y ? (min_y > tile_coordinates[i].y ? tile_coordinates[i].y : min_y) : tile_coordinates[i].y;
    max_y = max_y ? (max_y < tile_coordinates[i].y ? tile_coordinates[i].y : max_y) : tile_coordinates[i].y;
  }

  for(i = min_x; i <= max_x; i++) {
    for(j = min_y; j <= max_y; j++) {
      canvas = document.getElementById('id-' + i + '-' + j + '-' + zoom);
      updateCanvas(i, j, canvas, path);
    }
  }
  
  // TODO: clean deselected tiles
}

function updateCanvas(canvas_x, canvas_y, canvas, path) {
  var x, y, cellSize = 64, poly,
    context = canvas.getContext("2d");

  context.clearRect(0, 0, MERCATOR_RANGE, MERCATOR_RANGE);

  for (x = 0; x < 4; x++) {
    for (y = 0; y < 4; y++) {
      poly = [
        new google.maps.Point((canvas_x * MERCATOR_RANGE) + (x * cellSize), (canvas_y * MERCATOR_RANGE) + (y * cellSize)),
        new google.maps.Point((canvas_x * MERCATOR_RANGE) + ((x + 1) * cellSize), (canvas_y * MERCATOR_RANGE) + (y * cellSize)),
        new google.maps.Point((canvas_x * MERCATOR_RANGE) + ((x + 1) * cellSize), (canvas_y * MERCATOR_RANGE) + ((y + 1) * cellSize)),
        new google.maps.Point((canvas_x * MERCATOR_RANGE) + (x * cellSize), (canvas_y * MERCATOR_RANGE) + ((y + 1) * cellSize))
//        [ (canvas_x * MERCATOR_RANGE) + (x * cellSize), (canvas_y * MERCATOR_RANGE) + (y * cellSize) ],
//        [ (canvas_x * MERCATOR_RANGE) + ((x + 1) * cellSize), (canvas_y * MERCATOR_RANGE) + (y * cellSize) ],
//        [ (canvas_x * MERCATOR_RANGE) + ((x + 1) * cellSize), (canvas_y * MERCATOR_RANGE) + ((y + 1) * cellSize) ],
//        [ (canvas_x * MERCATOR_RANGE) + (x * cellSize), (canvas_y * MERCATOR_RANGE) + ((y + 1) * cellSize) ]
      ];

      if(polyIntersectsPath(poly, path)) {
        context.drawImage(stripes_select, cellSize*x, cellSize*y);
      }
    }
  }
}

function polyIntersectsPath(poly, path) {
  var i, pixel_coordinates, fixed_path = [], fixed_poly = [];
  
  for(i = 0; i < path.length; i++) {
    pixel_coordinates = getTileCoordinates(path.getAt(i)).pixelCoordinate;

    fixed_path.push([pixel_coordinates.x, pixel_coordinates.y]);
  }

  for(i = 0; i < poly.length; i++) {
    fixed_poly.push([poly[i].x, poly[i].y]);
    
    if(pointInPoly(fixed_path, poly[i].x, poly[i].y)) {
      return true;
    }
  }

  for(i = 0; i < fixed_path.length; i++) {
    if(pointInPoly(fixed_poly, fixed_path[i][0], fixed_path[i][1])) {
      return true;
    }
  }

  return false;
}

function pointInPoly(polyCords, pointX, pointY) {
  var i, j, c = false;

  for (i = 0, j = polyCords.length - 1; i < polyCords.length; j = i++) {
    if (((polyCords[i][1] > pointY) != (polyCords[j][1] > pointY)) && (pointX < (polyCords[j][0] - polyCords[i][0]) * (pointY - polyCords[i][1]) / (polyCords[j][1] - polyCords[i][1]) + polyCords[i][0])) {
      c = !c;
    }
  }

  return c;
}

// Source: http://code.google.com/apis/maps/documentation/javascript/examples/map-coordinates.html
function getTileCoordinates(point) {
  var numTiles = 1 << map.getZoom();
  var projection = new MercatorProjection();
  var worldCoordinate = projection.fromLatLngToPoint(point);
  var pixelCoordinate = new google.maps.Point(worldCoordinate.x * numTiles, worldCoordinate.y * numTiles);
  var tileCoordinate = new google.maps.Point(Math.floor(pixelCoordinate.x / MERCATOR_RANGE), Math.floor(pixelCoordinate.y / MERCATOR_RANGE));

  return {worldCoordinate: worldCoordinate, pixelCoordinate: pixelCoordinate, tileCoordinate: tileCoordinate};
}
InfoWindow.prototype = new google.maps.OverlayView();


function InfoWindow(latlng, map) {

  this.latlng_ = latlng;
  this.map_ = map;

  this.div_ = null;
  this.setMap(map);
}

InfoWindow.prototype.onAdd = function() {

  var div = document.createElement('DIV');
  div.style.border = "none";
  div.style.borderWidth = "0px";
  div.style.position = "absolute";
	div.style.background = "url(../images/infowindow_bkg.png) no-repeat 0 0";
	div.style.width = '204px';
	div.style.padding = '18px 13px 29px 13px';
	div.style.height = '94px';
	
  var title = document.createElement('h3');
  title.style.border = "none";
  title.style.borderWidth = "0px";
  title.style.position = "relative";
	title.style.font = "normal 21px Arial";
	title.style.color = "#000000";
	$(title).text("Are there signs of any human activity?");
	$(title).css('line-height','25px');
	$(title).css('text-shadow','white 0 1px -2px');
	title.style.width = '230px';
	title.style.height = '141px';
	div.appendChild(title);
	
  var yes = document.createElement('a');
  yes.style.border = "none";
  yes.style.borderWidth = "0px";
  yes.style.position = "absolute";
	yes.style.bottom = "65px";
	yes.style.right = "35px";
	yes.style.width = '64px';
	yes.style.height = '35px';
	yes.style.background = "url(../images/yes.png) no-repeat 0 0";
	div.appendChild(yes);

	$(yes).bind('touchmove touchcancel touchend',function(ev){
		$(this).css('background-position','0 -0');
	});

	$(yes).bind('touchstart',function(ev){
		$(this).css('background-position','0 -37px');
	});
	
	
  var no = document.createElement('a');
  no.style.border = "none";
  no.style.borderWidth = "0px";
  no.style.position = "absolute";
	no.style.bottom = "65px";
	no.style.right = "100px";
	no.style.width = '64px';
	no.style.height = '35px';
	no.style.background = "url(../images/no.png) no-repeat 0 0";
	div.appendChild(no);
	
	$(no).bind('touchmove touchcancel touchend',function(ev){
		$(this).css('background-position','0 -0');
	});

	$(no).bind('touchstart',function(ev){
		$(this).css('background-position','0 -38px');
	});

	

  this.div_ = div;

  var panes = this.getPanes();
  panes.floatPane.appendChild(this.div_);
}

InfoWindow.prototype.draw = function() {

  var pixPosition = this.getProjection().fromLatLngToDivPixel(this.latlng_);
  if (!pixPosition) return;

  this.div_.style.left = (pixPosition.x - 115) + "px";
  this.div_.style.width = '230px';
  this.div_.style.height = '141px';
  this.div_.style.top = (pixPosition.y - 141) + "px";

}

InfoWindow.prototype.onRemove = function() {
  this.div_.parentNode.removeChild(this.div_);
}

InfoWindow.prototype.hide = function() {
  if (this.div_) {
    this.div_.style.visibility = "hidden";
  }
}

InfoWindow.prototype.show = function() {
  if (this.div_) {
    this.div_.style.visibility = "visible";0
  }
}

InfoWindow.prototype.toggle = function() {
  if (this.div_) {
    if (this.div_.style.visibility == "hidden") {
      this.show();
    } else {
      this.hide();
    }
  }
}

InfoWindow.prototype.moveTo = function(latlng) {
  this.latlng_ = latlng;
}


InfoWindow.prototype.toggleDOM = function() {
  if (this.getMap()) {
    this.setMap(null);
  } else {
    this.setMap(this.map_);
  }
}

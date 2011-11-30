var second_map;

InfoWindow.prototype = new google.maps.OverlayView();

function InfoWindow(latlng, map, track) {
  this.position = 1;
  this.track_length = track.length;
  this.max_position = 1;
  this.track = track;
	
  this.latlng_ = latlng;
  this.map_ = map;
  this.div_ = null;
  this.setMap(map);
}

InfoWindow.prototype.onAdd = function() {
  var me = this;

  var div = document.createElement('DIV.INFO_WINDOW');
  div.style.border = "none";
  div.style.borderWidth = "0px";
  div.style.position = "absolute";
  div.style.width = '440px';
  div.style.height = '150px';

  var div_content = document.createElement('div');
  $(div_content).css('background-color','#212121'); 
  div_content.style.borderWidth = "0px";
  div_content.style.position = "absolute";
  div_content.style.top = '9px';
  div_content.style.left = '0';

  div_content.style.width = '440px';
  div_content.style.height = '140px';

  $(div_content).css('background','-webkit-gradient(linear,left bottom,left top,color-stop(0, rgb(35,35,35)),color-stop(1, rgb(18,18,18)))');
  $(div_content).css('background','-moz-linear-gradient(left bottom,rgb(35,35,35) 0%,rgb(18,18,18) 100%)');

  div.appendChild(div_content);

  var arrow_up = document.createElement('a');
  arrow_up.style.border = "none";
  arrow_up.style.borderWidth = "0px";
  arrow_up.style.position = "absolute"
  arrow_up.style.top = "20px";
  arrow_up.style.left = "20px";
  arrow_up.style.cursor = 'pointer';
  arrow_up.style.width = '12px';
  arrow_up.style.height = '12px';
  arrow_up.style.background = "url(../images/upArrow.png) no-repeat 0 0";

  $(arrow_up).hover(function(ev){
    $(this).css('background-position','0 -12px');
  }, function(ev){
    $(this).css('background-position','0px 0px');
  });

  div_content.appendChild(arrow_up);

  var current_step = document.createElement('p');
  $(current_step).addClass('current_step');
  current_step.style.font = "normal 11px Junction";
  current_step.style.color = "#5A5A5A";
  current_step.style.position = "absolute";
  current_step.style.top = "48px";
  current_step.style.left = "21px";
  $(current_step).css('line-height','15px');
  current_step.width = '30px';
  $(current_step).text("1");
  div_content.appendChild(current_step);

  var of_text = document.createElement('p');
  of_text.style.font = "normal 11px Junction";
  of_text.style.color = "#5A5A5A";
  of_text.style.position = "absolute";
  of_text.style.top = "64px";
  of_text.style.left = "19px";
  of_text.width = '30px';
  $(of_text).css('line-height','15px');
  $(of_text).text("OF");
  div_content.appendChild(of_text);

  var total_steps = document.createElement('p');
  total_steps.style.font = "normal 11px Junction";
  total_steps.style.color = "#5A5A5A";
  total_steps.style.position = "absolute";
  total_steps.style.bottom = "48px";
  total_steps.style.left = "21px";
  $(total_steps).css('line-height','15px');
  total_steps.width = '30px';
  $(total_steps).text(this.track_length);
  div_content.appendChild(total_steps);

  var arrow_down = document.createElement('a');
  arrow_down.style.border = "none";
  arrow_down.style.borderWidth = "0px";
  arrow_down.style.position = "absolute";
  arrow_down.style.bottom = "20px";
  arrow_down.style.cursor = 'pointer';
  arrow_down.style.left = "20px";
  arrow_down.style.width = '12px';
  arrow_down.style.height = '12px';
  arrow_down.style.background = "url(../images/downArrow.png) no-repeat 0 0";

  $(arrow_down).hover(function(ev){
    $(this).css('background-position','0 -12px');
  },function(ev){
    $(this).css('background-position','0px 0px');
  });
  div_content.appendChild(arrow_down);

  var image_static_layer = document.createElement('div');
  $(image_static_layer).addClass('second_map');
  image_static_layer.style.height =  '150px';
  image_static_layer.style.width =  '150px';
  image_static_layer.style.position = 'relative';
  image_static_layer.style.zIndex = "11";
  image_static_layer.style.top = "3px";
  image_static_layer.style.left = "53px";	
  div.appendChild(image_static_layer);

  var layer_selected = document.createElement('div');
  layer_selected.style.border = "3px solid #FFFFFF";
  $(layer_selected).css('-moz-border-radius','5px');
  $(layer_selected).css('-webkit-border-radius','5px');	
  layer_selected.style.position = "absolute";
  layer_selected.style.width = '150px';
  layer_selected.style.height = '150px';
  layer_selected.style.top = "0";
  layer_selected.style.left = "51px";
  $(layer_selected).css('background','url(../images/alpha_layer_infowindow.png) no-repeat 0 0'); 					
  div.appendChild(layer_selected);

  var title = document.createElement('h3');
  title.style.border = "none";
  title.style.borderWidth = "0px";
  title.style.position = "absolute";
  title.style.top = "20px";
  title.style.right = "0";
  title.style.font = "normal 21px Junction";
  title.style.color = "#FFFFFF";
  $(title).text("Are there signs of any human activity?");
  $(title).css('line-height','25px');
  $(title).css('text-shadow','black 0 1px -2px');
  title.style.width = '220px';
  title.style.height = '51px';
  div_content.appendChild(title);
	
  var view_map = document.createElement('a');
  $(view_map).css('text-decoration','underline');
  view_map.style.position = "absolute";
  view_map.style.bottom = "20px";
  view_map.style.right = "160px";
  view_map.style.font = "normal 13px Junction";
  view_map.style.color = "#5A5A5A";
  $(view_map).text("view map");
  div_content.appendChild(view_map);

  $(title).css('line-height','25px');
  title.style.width = '220px';
  title.style.height = '51px';
  div_content.appendChild(title);
	
  var yes = document.createElement('a');
  yes.style.border = "none";
  yes.style.borderWidth = "0px";
  yes.style.position = "absolute";
  yes.style.bottom = "15px";
  yes.style.right = "15px";
  yes.style.width = '64px';
  yes.style.cursor = 'pointer';
  yes.style.height = '35px';
  yes.style.background = "url(../images/yes.png) no-repeat 0 0";
  div_content.appendChild(yes);
  $(yes).hover(function(ev){
    $(this).css('background-position','0 -37px');
  },
  function(ev){
    $(this).css('background-position','0 0');
  });
	
  $(yes).click(function(ev){
    me.moveInfoWindow(true);
  });

  var no = document.createElement('a');
  no.style.border = "none";
  no.style.borderWidth = "0px";
  no.style.position = "absolute";
  no.style.bottom = "15px";
  no.style.right = "80px";
  no.style.width = '64px';
  no.style.cursor = 'pointer';
  no.style.height = '35px';
  no.style.background = "url(../images/no.png) no-repeat 0 0";
  div_content.appendChild(no);
  $(no).hover(function(ev){
    $(this).css('background-position','0 -38px');
  },
  function(ev){
    $(this).css('background-position','0 0');
  });

  $(no).click(function(ev){
    me.moveInfoWindow(false);
  });

  this.addOnKeyPress();

  var mapOptions = {
    zoom: 15,
    scrollwheel: false,
    center: this.latlng_,
    mapTypeId: google.maps.MapTypeId.SATELLITE,
    mapTypeControl: false,
    navigationControl: false,
    scaleControl: false,
    streetViewControl: false,
    disableDoubleClickZoom: true
  };

  this.div_ = div;

  var panes = this.getPanes();
  panes.overlayLayer.style["zIndex"] = 1001;
  panes.overlayLayer.appendChild(this.div_);

  second_map = new google.maps.Map(image_static_layer,mapOptions);

}

InfoWindow.prototype.draw = function() {
  var pixPosition = this.getProjection().fromLatLngToDivPixel(this.latlng_);
  if (!pixPosition) return;

  this.div_.style.left = (pixPosition.x - 126) + "px";
  this.div_.style.top = (pixPosition.y - 85) + "px";

}

InfoWindow.prototype.onRemove = function() {
  this.div_.parentNode.removeChild(this.div_);
}

InfoWindow.prototype.moveInfoWindow = function(choice) {
  if (this.position == this.max_position) {
    this.max_position = this.max_position + 1;
  }

  if (this.position==this.track_length) {
    this.sendChoice(choice,this.track[this.position-1].id);
    getGameRank();
    getNewTrack();
    this.removeOnKeyPress();
    return;
  } else {
    this.sendChoice(choice,this.track[this.position-1].id);
    this.position = this.position + 1;
  }
  this.latlng_ = this.getCoords();
  second_map.setCenter(this.latlng_);
	
	
  $(this.div_).children('div').children('p.current_step').text(this.position);
  this.draw();

  this.map_.setCenter(this.latlng_);
}

InfoWindow.prototype.sendChoice = function(choice,id) {
  $.ajax({
    type: "POST",
    url: "/classifications/"+id,
    data: {
      value : id, 
      _method: 'put'
    }
  });
}

InfoWindow.prototype.getCoords = function() {
  return getCellCenter(this.track[this.position-1].x,this.track[this.position-1].y,this.track[this.position-1].zoom);
}

InfoWindow.prototype.addOnKeyPress = function() {
  var me = this;
  $(document).keypress(function (e) {
    if ( e.keyCode == 110 ){
      showResponse('N');
      me.moveInfoWindow(false);
    } else {
      if (e.keyCode == 121) {
        showResponse('Y');
        me.moveInfoWindow(true);
      }
    }
  });
}

InfoWindow.prototype.removeOnKeyPress = function() {
  $(document).unbind('keypress');
}
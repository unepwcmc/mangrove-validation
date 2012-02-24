window.VALIDATION =
  map: null # Google Maps
  mapOptions:
    center: new google.maps.LatLng(-18.521283,36.650391)
    zoom: 4
    mapTypeId: google.maps.MapTypeId.SATELLITE
    mapTypeControl: false
    panControl: false
    zoomControl: false
    rotateControl: false
    streetViewControl: false
  mapPolygon: null # Google Maps Polygon
  mapPolygonOptions:
    editable: true
  minEditZoom: 10
  mangroves: null # CartoDB Mangroves Unverified Layer
  mangroves_params: null
  mangroves_validated: null # CartoDB Mangroves Validated Layer
  mangroves_validated_params: null
  corals: null # CartoDB Corals Unverified Layer
  corals_params: null
  corals_validated: null # CartoDB Corals Validated Layer
  corals_validated_params: null
  currentAction: null # Current user action ['validate', 'add', 'delete']
  submitModalEvents: {}
  selectedLayer: 'mangrove'

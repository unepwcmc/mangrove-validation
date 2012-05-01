window.VALIDATION =
  layers: # check app/models/enumerations/names.rb
    mangroves:
      id: 0
      status:
        0:
          style: 'polygon-fill:#B15F00;polygon-opacity:0.7;line-width:0'
          hide: false
        1:
          style: 'polygon-fill:#FF8800;polygon-opacity:0.7;line-width:0'
          hide: false
    corals:
      id: 1
      status:
        0:
          style: 'polygon-fill:#A1A121;polygon-opacity:0.7;line-width:0'
          hide: true
        1:
          style: 'polygon-fill:#FDFD34;polygon-opacity:0.7;line-width:0'
          hide: true
    saltmarshes:
      id: 2
      status:
        0:
          style: 'polygon-fill:#663CA0;polygon-opacity:0.7;line-width:0'
          hide: true
        1:
          style: 'polygon-fill:#A260FF;polygon-opacity:0.7;line-width:0'
          hide: true
  actions: # check app/models/enumerations/actions.rb
    validate: 0
    add: 1
    'delete': 2
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
  minEditZoom:
    hide: 10
    mangroves: 13
    corals: 10
    saltmarshes: 12

  mangroves: null # CartoDB Mangroves Unverified Layer
  mangroves_params: null
  mangroves_validated: null # CartoDB Mangroves Validated Layer
  mangroves_validated_params: null

  corals: null # CartoDB Corals Unverified Layer
  corals_params: null
  corals_validated: null # CartoDB Corals Validated Layer
  corals_validated_params: null

  saltmarshes: null # CartoDB Salt marshes Unverified Layer
  saltmarshes_params: null
  saltmarshes_validated: null # CartoDB Salt marshes Validated Layer
  saltmarshes_validated_params: null

  currentAction: null # User actions: ['validate', 'add', 'delete']
  submitModalEvents: {}
  selectedLayer: 'mangroves' # Name of the layer or 'hide'

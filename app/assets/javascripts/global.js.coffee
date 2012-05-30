window.VALIDATION =
  layers: # check app/models/enumerations/names.rb
    mangroves:
      id: 0
      editions:
        base:
          status: 0 # check app/models/enumerations/status.rb
          color: '#FC860A'
          hide: false
        validated:
          status: 1 # check app/models/enumerations/status.rb
          action: 0 # check app/models/enumerations/actions.rb
          color: '#4C9D38'
          hide: false
        added:
          status: 1 # check app/models/enumerations/status.rb
          action: 1 # check app/models/enumerations/actions.rb
          color: '#0A94FF'
          hide: false
    corals:
      id: 1
      editions:
        base:
          status: 0 # check app/models/enumerations/status.rb
          color: '#FC860A'
          hide: true
        validated:
          status: 1 # check app/models/enumerations/status.rb
          action: 0 # check app/models/enumerations/actions.rb
          color: '#4C9D38'
          hide: true
        added:
          status: 1 # check app/models/enumerations/status.rb
          action: 1 # check app/models/enumerations/actions.rb
          color: '#0A94FF'
          hide: true
    saltmarshes:
      id: 2
      editions:
        base:
          status: 0 # check app/models/enumerations/status.rb
          color: '#FC860A'
          hide: true
        validated:
          status: 1 # check app/models/enumerations/status.rb
          action: 0 # check app/models/enumerations/actions.rb
          color: '#4C9D38'
          hide: true
        added:
          status: 1 # check app/models/enumerations/status.rb
          action: 1 # check app/models/enumerations/actions.rb
          color: '#0A94FF'
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
    mapTypeControl: true
    mapTypeControlOptions: 
      mapTypeIds: [google.maps.MapTypeId.SATELLITE, google.maps.MapTypeId.TERRAIN, google.maps.MapTypeId.HYBRID]
      style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
    panControl: false
    zoomControl: true
    rotateControl: false
    scaleControl: true
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
  mangroves_added: null # CartoDB Mangroves Added Layer
  mangroves_added_params: null

  corals: null # CartoDB Corals Unverified Layer
  corals_params: null
  corals_validated: null # CartoDB Corals Validated Layer
  corals_validated_params: null
  corals_added: null # CartoDB Corals Added Layer
  corals_added_params: null

  saltmarshes: null # CartoDB Salt marshes Unverified Layer
  saltmarshes_params: null
  saltmarshes_validated: null # CartoDB Salt marshes Validated Layer
  saltmarshes_validated_params: null
  saltmarshes_added: null # CartoDB Salt marshes Added Layer
  saltmarshes_added_params: null

  currentAction: null # User actions: ['validate', 'add', 'delete']
  authModalEvents: {}
  selectedLayer: 'mangroves' # Name of the layer or 'hide'

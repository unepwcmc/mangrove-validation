class MangroveValidation.Models.Layer extends Backbone.Model
  paramRoot: 'layer'

  defaults:
    name: null

class MangroveValidation.Collections.LayersCollection extends Backbone.Collection
  model: MangroveValidation.Models.Layer
  url: '/layers'

  search: (query) ->
    # Get the layers for the given search term
    
    #TODO actually search
    @reset([{name: 'result 1', layer_id:1}, {name: 'result 2', layer_id: 5}])

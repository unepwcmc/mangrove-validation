class MangroveValidation.Models.Layer extends Backbone.Model
  paramRoot: 'layer'

  defaults:
    name: null

class MangroveValidation.Collections.LayersCollection extends Backbone.Collection
  model: MangroveValidation.Models.Layer
  url: '/layers'

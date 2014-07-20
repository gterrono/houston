Template._houston_sidenav.helpers
  collections: ->
    Houston._session('collections')
  num_of_records: ->
    Houston._collections.collections.findOne({name: @name}).count
  is_active: (name) ->
    name is Houston._session('collection_name')

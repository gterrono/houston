root = exports ? this

root.Houston ?= {}

Houston._houstonize = (name) -> "_houston_#{name}"

Houston._get_fields = (documents) ->
  key_to_type = {_id: 'ObjectId'}
  find_fields = (document, prefix='') ->

    for key, value of _.omit(document, '_id')
      if typeof value is 'object'
        
        # handle dates like strings
        if value instanceof Date
          full_path_key = "#{prefix}#{key}"
          key_to_type[full_path_key] = "String"

        # recurse into sub documents
        else
          find_fields value, "#{prefix}#{key}."
      else if typeof value isnt 'function'
        full_path_key = "#{prefix}#{key}"
        key_to_type[full_path_key] = typeof value

  for document in documents
    find_fields document

  (name: key, type: value for key, value of key_to_type)

Houston._get_field_names = (documents) ->
  _.pluck(Houston._get_fields(documents), 'name')

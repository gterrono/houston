root = exports ? this

root.Houston ?= {}

Houston._houstonize = (name) -> "_houston_#{name}"

Houston._custom_method_name = (collection_name, method_name) ->
  Houston._houstonize("#{collection_name}/#{method_name}")

# change _MAX_DOCS_TO_EXPLORE if you need us to explore more docs
Houston._MAX_DOCS_TO_EXPLORE = 100

_get_fields_from_simple_schema = (simple_schema) -> # keep it private?
  is_array_of_objects = (field) ->
    # we don't know type of Array[Object?String?Date?] from simpleschema but at least we can deduce if it is [Object] from key names
    res = _.filter(simple_schema._schemaKeys, (key) ->
      key.indexOf(field) == 0
    ).length > 1
    console.warn(res)
    res

  _.pairs(simple_schema._schema).filter((pair) ->
    !is_array_of_objects(pair[0])
  ).map((pair) ->
    name = pair[0]
    type = pair[1].type
    if type == Array # and it is not array of objects
      name = name + '.0'
      type = String # we don't know which is it so default will be String TODO
    name: name.replace(/\.\$/g, '.0') # SimpleSchema arrays to 'only first element'
    type: Houston._function_name(type) # type name and also constructor name to take from window object on client
  ).filter((item) ->
    item.type isnt "Object" # remove middle keys that is objects but not array of objects
  )

Houston._function_name = (f) ->
  r = f.toString()
  r = r.substr('function '.length)
  r = r.substr(0, r.indexOf('('))
  r

Houston._get_simple_schema = (collection) ->
  collection.simpleSchema and collection.simpleSchema() # TODO check if is function

Houston._get_fields_from_collection = (collection) ->
  simple_schema = Houston._get_simple_schema(collection)
  common_fields = Houston._get_fields(collection.find().fetch())
  if simple_schema
    simple_schema_fields = _get_fields_from_simple_schema(simple_schema)
    _id_index = _.pluck(simple_schema_fields, 'name').indexOf('_id') # special case if someone typised _id
    if _id_index >= 0
      _id_schema = simple_schema_fields[_id_index]
      # mark it required to use in collection add view
      _id_schema._required = true
      if _id_index >= 1
        _id_schema = simple_schema_fields.splice(_id_index, 1)[0]
        # then move it to the beginning if it isn't already
        simple_schema_fields = _.flatten [
          _id_schema
          simple_schema_fields
        ]
    else if _id_index is -1 # stub it
      simple_schema_fields = _.flatten [ # add default first _id field
        {
          name: "_id"
          type: "ObjectId"
        }
        simple_schema_fields
      ]
    # TODO if extending array[0] add type from array[0] to other fields like array[1] etc
    _.extend(common_fields, simple_schema_fields) # add deduced fields. it won't harm but will give us arrays
  else
    # TODO(AMK) randomly sample the documents in question
    common_fields

Houston._get_fields = (documents, options={}) ->
  key_to_type = if options.exclude_id? then {} else {_id: 'ObjectId'}

  find_fields = (document, prefix='') ->
    for key, value of _.omit(document, '_id')
      if typeof value is 'object'

        # handle dates like strings
        if value instanceof Date
          full_path_key = "#{prefix}#{key}"
          key_to_type[full_path_key] = "Date"

        # recurse into sub documents
        else
          find_fields value, "#{prefix}#{key}."
      else if typeof value isnt 'function'
        full_path_key = "#{prefix}#{key}"
        key_to_type[full_path_key] = typeof value

  for document in documents[..Houston._MAX_DOCS_TO_EXPLORE]
    find_fields document

  (name: key, type: value for key, value of key_to_type)

Houston._get_field_names = (documents) ->
  _.pluck(Houston._get_fields(documents), 'name')

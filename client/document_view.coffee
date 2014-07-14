Template._houston_document_view.helpers
  collection_name: -> Houston._session('collection_name')
  adminHide: -> if Houston._session('should_show') then '' else 'hide'
  fields: ->
    document = get_collection().findOne _id: Houston._session('document_id')
    unless document
      try
        document = get_collection().findOne _id: new Meteor.Collection.ObjectID(Houston._session('document_id'))
      catch error
        console.log error
    fields = Houston._get_fields([document])
    result = []
    for field in fields
      value = Houston._nested_field_lookup(document, field.name)
      result.push(name: "#{field.name} (#{typeof value})", name_id: field.name, type: typeof value, value: value)
    return result
  document_id: -> Houston._session('document_id')

Template._houston_document_field.helpers
  field_is_id: -> @name is '_id'
  type_is_boolean: -> @type is 'boolean'
  document_id: -> Houston._session('document_id')

get_collection = -> Houston._get_collection(Houston._session('collection_name'))

Template._houston_document_view.events
  'click .houston-save': (e) ->
    e.preventDefault()
    update_dict = {}
    for field in $('.houston-field')
      field_name = field.name.split(' ')[0]
      unless field_name is '_id'
        update_dict[field_name] = Houston._convert_to_correct_type(field_name, field.value,
          get_collection())
    Houston._call("#{Houston._session('collection_name')}_update",
      Houston._session('document_id'), $set: update_dict)
    Houston._session('should_show', true)
    setTimeout (->
      Houston._session('should_show', false)
    ), 3600

  'click .houston-delete': (e) ->
    e.preventDefault()
    id = Houston._session('document_id')
    if confirm("Are you sure you want to delete the document with _id #{id}?")
      Houston._call("#{Houston._session('collection_name')}_delete", id)
      Houston._go 'collection', name: Houston._session('collection_name')

Template._houston_document_view.rendered = ->
  $(window).unbind('scroll')

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
    return (name: field.name, value: Houston._nested_field_lookup(document, field.name) for field in fields)
  document_id: -> Houston._session('document_id')

Template._houston_document_field.helpers
  field_is_id: -> @name is '_id'
  document_id: -> Houston._session('document_id')

get_collection = -> Houston._get_collection(Houston._session('collection_name'))

Template._houston_document_view.events
  'click .houston-save': (e) ->
    e.preventDefault()
    old_object = get_collection().findOne _id: Houston._session('document_id')
    unless old_object
      try
        old_object = get_collection().findOne _id: new Meteor.Collection.ObjectID(Houston._session('document_id'))
      catch error
        console.log error
    update_dict = {}
    for field in $('.houston-field')
      unless field.name is '_id'
        update_dict[field.name] = if typeof(old_object[field.name]) == 'number'
            parseFloat(field.value)
          else
            field.value
    Houston._call("#{Houston._session('collection_name')}_update",
      Houston._session('document_id'), $set: update_dict)
    Houston._session('should_show', true)
    setTimeout (->
      Houston._session('should_show', false)
    ), 1500

  'click .houston-delete': (e) ->
    e.preventDefault()
    if confirm('Are you sure you want to delete this document?')
      Houston._call("#{Houston._session('collection_name')}_delete",
        Houston._session('document_id'))
      Houston._go 'collection', name: Houston._session('collection_name')

Template._houston_document_view.rendered = ->
  $(window).unbind('scroll')

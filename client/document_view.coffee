Template._houston_document_view.helpers
  collection_name: -> Session.get('_houston_collection_name')
  adminHide: -> if Session.get('_houston_should_show') then '' else 'hide'
  fields: ->
    document = get_collection().findOne _id: Session.get('_houston_document_id')
    unless document
      try
        document = get_collection().findOne _id: new Meteor.Collection.ObjectID(Session.get('_houston_document_id'))
      catch error
        console.log error
    fields = Houston._get_fields([document])
    console.log fields
    #To make document not go away
    console.log document
    l = (field_name: field.name, field_value: Houston._lookup(document, field.name) for field in fields)
    console.log l
    l
  field_is_id: -> @field_name is '_id'
  document_id: -> Session.get('_houston_document_id')

get_collection = -> Houston._get_collection(Session.get('_houston_collection_name'))

Template._houston_document_view.events
  'click .houston-save': (e) ->
    e.preventDefault()
    old_object = get_collection().findOne _id: Session.get('_houston_document_id')
    unless old_object
      try
        old_object = get_collection().findOne _id: new Meteor.Collection.ObjectID(Session.get('_houston_document_id'))
      catch error
        console.log error
    update_dict = {}
    for field in $('.field')
      unless field.name is '_id'
        update_dict[field.name] = if typeof(old_object[field.name]) == 'number'
            parseFloat(field.value)
          else
            field.value
    Meteor.call("_houston_#{Session.get('_houston_collection_name')}_update",
      Session.get('_houston_document_id'), $set: update_dict)
    Session.set('_houston_should_show', true)
    setTimeout (->
      Session.set('_houston_should_show', false)
    ), 1500

  'click .houston-delete': (e) ->
    e.preventDefault()
    Meteor.call "_houston_#{Session.get('_houston_collection_name')}_delete",
      Session.get('_houston_document_id')
    Meteor.Router.to "/houston/#{Session.get('_houston_collection_name')}"
  'focus textarea.field': (e) ->
    $(e.target).closest('textarea').trigger('autosize.resize');

Template._houston_document_view.rendered = ->
  $('textarea.field').autosize()
  $(window).unbind('scroll')

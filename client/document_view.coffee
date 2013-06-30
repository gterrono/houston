Template.document_view.helpers
  collection_name: -> Session.get('collection_name')
  fields: ->
    document = get_collection().findOne _id: Session.get('document_id')
    (field_name: key, field_value: value for key, value of document)

get_collection = -> window["inspector_#{Session.get('collection_name')}"]

Template._houston_document_view.helpers
  collection_info: -> Houston._collections.collections.findOne {@name}
  showSaved: -> Houston._session('show_saved')
  fields: ->
    fields = Houston._get_fields([@document], exclude_id: true)
    result = []
    for field in fields
      value = Houston._nested_field_lookup(@document, field.name)
      result.push(name: "#{field.name} (#{typeof value})", name_id: field.name, type: typeof value, value: value.toString())
    return result
  document_id: ->
    @document._id

Template._houston_document_field.helpers
  has_type: -> Houston._INPUT_TYPES[@type]?
  input_type: -> Houston._INPUT_TYPES[@type]

Template._houston_document_view.events
  'click #houston-save': (e) ->
    e.preventDefault()
    update_dict = {}
    collection = Houston._get_collection(@name)
    for field in $('.houston-field')
      field_name = field.name.split(' ')[0]
      unless field_name is '_id'
        update_dict[field_name] = Houston._convert_to_correct_type(field_name, field.value, collection)
    Houston._call("#{@name}_update", @document._id, $set: update_dict, Houston._show_flash)

  'click #houston-delete': (e) ->
    e.preventDefault()
    id = @document._id
    if confirm("Are you sure you want to delete the document with _id #{id}?")
      Houston._call("#{@name}_delete", id)
      Houston._go 'collection', name: @name

Template._houston_document_view.rendered = ->
  $(window).unbind('scroll')

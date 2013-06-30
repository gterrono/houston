Template.admin_new_collection.events
  'click .admin-add-collection-button': (e) ->
    e.preventDefault()
    collection_name = $('#admin-collection-name').val()
    Meteor.call('setupNewCollection', collection_name, (e, r) ->
      Meteor.subscribe "admin_#{collection_name}"
      inspector_name = "inspector_#{collection_name}"

      unless window[inspector_name]
        # you can only instantiate a collection once
        try
          window[inspector_name] = new Meteor.Collection(collection_name)
        catch e
          window[inspector_name] = Meteor._LocalCollectionDriver.collections[collection_name]
      $form = $('#admin-new-collection-form')
      new_doc = {}
      for group in $form.find('.admin-field-group')
        $group = $(group)
        field_name = $group.find('.admin-field').val()
        if field_name
          new_doc[field_name] = $group.find('.admin-value').val()

      Meteor.call "admin_#{collection_name}_insert", new_doc
    )
    $('#adminCollectionModal').modal('hide')

  'keyup .admin-last-field': (e) ->
    $('.admin-last-field').removeClass('admin-last-field')
    $('#admin-new-collection-form').append(Template.admin_collection_field_group())

Template._houston_custom_actions.helpers
  actions: ->
    if @collection_info.method_names
      (_.extend({action}, @) for action in @collection_info.method_names)
Template._houston_custom_actions.events
  'click .custom-houston-action': (e) ->
    e.preventDefault()
    Meteor.call Houston._custom_method_name(@collection_info.name, @action), @document, Houston._show_flash


var fixHelper = function(e, ui) {
  ui.children().each(function() {
    $(this).width($(this).width());
  });
  return ui;
};

function FindReplace(order_id, index) {
  data = Products.findOne({sort_order: parseFloat(order_id)});
  Products.update({_id: data._id}, {$set: {sort_order: index}})
};

initSortable = function() {
  $("#data-table tbody").sortable({
    opacity: 0.6,
    cursor: 'move',
    helper: fixHelper,
    scrollSensitivity: 40,
    update: function(){
      sort = $(this).sortable('toArray');
      jQuery.map(sort, function(order, i){
        var order_id = order.match(/\d/g);
        order_id = order_id.join("");
        console.log('New Order: ' + order_id);
        FindReplace(order_id, i);
      });
    }
  }).disableSelection();
};

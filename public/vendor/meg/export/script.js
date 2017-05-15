//** WIZARD THINGS **//
$(document).ready(function () {

  var navListItems = $('div.setup-panel div a'),
    allWells = $('.setup-content'),
    allNextBtn = $('.nextBtn');

  allWells.hide();

  navListItems.click(function (e) {
      e.preventDefault();
      var $target = $($(this).attr('href')),
              $item = $(this);

      if (!$item.hasClass('disabled')) {
          navListItems.removeClass('btn-primary').addClass('btn-default');
          $item.addClass('btn-primary');
          allWells.hide();
          $target.show();
          $target.find('input:eq(0)').focus();
      }
  });

  allNextBtn.click(function(){
    var curStep = $(this).closest(".setup-content"),
        curStepBtn = curStep.attr("id"),
        nextStepWizard = $('div.setup-panel div a[href="#' + curStepBtn + '"]').parent().next().children("a"),
        curInputs = curStep.find("input[type='text'],input[type='url']"),
        isValid = true;
    valueStep = parseInt($(curStep).attr('name'))
    if (valueStep == 1){
      if (getCheckedFields()['keys'].length == 0)
        isValid = false
    }

    if (isValid)
        nextStepWizard.removeAttr('disabled').trigger('click');
  });

  // $('div.setup-panel div a.btn-primary').trigger('click');
});

//** LIST CHECK THINGS **//

settings = {
    on: {
        icon: 'glyphicon glyphicon-check'
    },
    off: {
        icon: 'glyphicon glyphicon-unchecked'
    }
};
// Actions
updateDisplay = function($widget, $checkbox) {
    color = ($widget.data('color') ? $widget.data('color') : "info"),
    style = ($widget.data('style') == "button" ? "btn-" : "list-group-item-")
    var isChecked = $checkbox.is(':checked');

    // Set the button's state
    $widget.data('state', (isChecked) ? "on" : "off");

    // Set the button's icon
    $widget.find('.state-icon')
        .removeClass()
        .addClass('state-icon ' + settings[$widget.data('state')].icon);

    // Update the button's color
    if (isChecked) {
        $widget.addClass(style + color + ' active');
    } else {
        $widget.removeClass(style + color + ' active');
    }
}

initListChecked = function () {
  $('.list-group.checked-list-box .list-group-item').each(function () {

      // Settings
      var $widget = $(this),
          $checkbox = $('<input type="checkbox" class="hidden" />')
          // color = ($widget.data('color') ? $widget.data('color') : "info"),
          // style = ($widget.data('style') == "button" ? "btn-" : "list-group-item-")

      $widget.css('cursor', 'pointer')
      $widget.append($checkbox);

      // Event Handlers
      $widget.on('click', function () {
          $checkbox.prop('checked', !$checkbox.is(':checked'));
          $checkbox.triggerHandler('change');
          updateDisplay($widget, $checkbox);
      });
      $checkbox.on('change', function () {
          updateDisplay($widget, $checkbox);
      });


      // Initialization
      function init() {

          if ($widget.data('checked') == true) {
              $checkbox.prop('checked', !$checkbox.is(':checked'));
          }

          updateDisplay($widget, $checkbox);

          // Inject the icon if applicable
          if ($widget.find('.state-icon').length == 0) {
              $widget.prepend('<span class="state-icon ' + settings[$widget.data('state')].icon + '"></span>');
          }
      }
      init();
  });

  $('.btn-mark-all').on('click', function(){
    $('.list-group.checked-list-box .list-group-item').each(function () {
      $widget = $(this)
      $checkbox = $widget.find('input')
      $checkbox.prop('checked', true);
      updateDisplay($widget, $checkbox);
    })
  })

};

getCheckedFields = function() {
  checkedItems = {
    keys:[],
    text:{}
  };
  counter = 0;
  $(".checked-list-box li.active").each(function(idx, li) {
      checkedItems['keys'].push($(li).attr('name'))
      checkedItems['text'][$(li).attr('name')] = $(li).text()
      counter++;
  });
  return checkedItems
};
// = require_self
$(document).ready(function () {
  let selectedQuestionsCount = function() {
    return $('.table-list .js-check-all-question:checked').length
  }

  window.selectedQuestionsCountUpdate = function() {
    if(selectedQuestionsCount() == 0){
      $("#js-selected-questions-count").text("")
    } else {
      $("#js-selected-questions-count").text(selectedQuestionsCount());
    }

    if(selectedQuestionsCount() >= 2) {
      $('button[data-action="merge-questions"]').parent().show();
    } else {
      $('button[data-action="merge-questions"]').parent().hide();
    }
  }

  let showBulkActionsButton = function() {
    if(selectedQuestionsCount() > 0){
      $("#js-bulk-actions-button").removeClass('hide');
    }
  }

  let hideBulkActionsButton = function(force = false) {
    if(selectedQuestionsCount() == 0 || force == true){
      $("#js-bulk-actions-button").addClass('hide');
      $("#js-bulk-actions-dropdown").removeClass('is-open');
    }
  }

  window.showOtherActionsButtons = function() {
    $("#js-other-actions-wrapper").removeClass('hide');
  }

  let hideOtherActionsButtons = function() {
    $("#js-other-actions-wrapper").addClass('hide');
  }

  window.hideBulkActionForms = function() {
    return $(".js-bulk-action-form").addClass('hide');
  }

  if ($('.js-bulk-action-form').length) {
    window.hideBulkActionForms();
    $("#js-bulk-actions-button").addClass('hide');

    $("#js-bulk-actions-dropdown ul li button").click(function(e){
      e.preventDefault();
      let action = $(e.target).data("action");

      if(action) {
        $(`#js-form-${action}`).submit(function(){
          $('.layout-content > .callout-wrapper').html("");
        })

        $(`#js-${action}-actions`).removeClass('hide');
        hideBulkActionsButton(true);
        hideOtherActionsButtons();
      }
    })

    // select all checkboxes
    $(".js-check-all").change(function() {
      $(".js-check-all-question").prop('checked', $(this).prop("checked"));

      if ($(this).prop("checked")) {
        $(".js-check-all-question").closest('tr').addClass('selected');
        showBulkActionsButton();
      } else {
        $(".js-check-all-question").closest('tr').removeClass('selected');
        hideBulkActionsButton();
      }

      selectedQuestionsCountUpdate();
    });

    // question checkbox change
    $('.table-list').on('change', '.js-check-all-question', function (e) {
      let question_id = $(this).val()
      let checked = $(this).prop("checked")

      // uncheck "select all", if one of the listed checkbox item is unchecked
      if ($(this).prop("checked") === false) {
        $(".js-check-all").prop('checked', false);
      }
      // check "select all" if all checkbox questions are checked
      if ($('.js-check-all-question:checked').length === $('.js-check-all-question').length) {
        $(".js-check-all").prop('checked', true);
        showBulkActionsButton();
      }

      if ($(this).prop("checked")) {
        showBulkActionsButton();
        $(this).closest('tr').addClass('selected');
      } else {
        hideBulkActionsButton();
        $(this).closest('tr').removeClass('selected');
      }

      if ($('.js-check-all-question:checked').length === 0) {
        hideBulkActionsButton();
      }

      $('.js-bulk-action-form').find(".js-question-id-"+question_id).prop('checked', checked);
      selectedQuestionsCountUpdate();
    });

    $('.js-cancel-bulk-action').on('click', function (e) {
      window.hideBulkActionForms()
      showBulkActionsButton();
      showOtherActionsButtons();
    });
  }
});

$(document).ready(function() {
  aggregate();
  assignCustomerMachine();
  checkAll();
  checkErrors();
  clickableTr();
  collapseIconChange();
  colspans();
  fakeDateField();
  initilizeUppy();
  inlineUpdate();
  orderDetails();
  popover();
  popup();
  selectpicker();
  spinner();
  toggleFields();
  toggles();
  tooltip();
});

$(document).ajaxComplete(function() {
  initilizeUppy();
  orderDetails();
  selectpicker();
  toggleFields();
});

$(window).on('scroll', function(event) {
  var scrollValue = $(window).scrollTop();
  if (scrollValue >= 98) {
    $('#top_assign_customer_machine').addClass('d-none');
    $('#bigger-btn-div').removeClass('d-none')
    $('#scroll_assign_customer_machine').removeClass('d-none')
  } else if (scrollValue <= 98) {
    $('#top_assign_customer_machine').removeClass('d-none');
    $('#bigger-btn-div').addClass('d-none')
    $('#scroll_assign_customer_machine').addClass('d-none')
  }
});

window.spinner = function() {
  $('[data-spinner="true"]').on('click',function(){
    $("#spinner").show();
  });
}

window.assignCustomerMachine = function() {
  $("#top_assign_customer_machine, #scroll_assign_customer_machine").click(function(){
    var url = "/line_items/assign_customer_machine";
    var line_item_ids = $('.check_line_item:checkbox:checked').map(function() {
      return this.value;
    }).get();
    if (line_item_ids.length > 0) {
      $.ajax({
        type: 'GET',
        url: url,
        data: { line_item_ids: line_item_ids },
        dataType: 'script'
      });
      return false;
    } else {
      alert('Selezionare almeno una riga di commessa.')
    }
  });
}

window.inlineUpdate = function() {
  $(".int_inline_select").each(function(i,el) {
    $(el).change(function() {
      id = $(el).data("id");
      var int_customer_machine_id = $(el).closest('.int_customer_machine_id');
      var url = "/line_items/" + id + "/inline_update";
      $.ajax({
        type: 'PATCH',
        url: url,
        beforeSend: function() {
          $(el).prop("disabled", true);
        },
        error: function(data) {
          $(el).prop("disabled", false);
          $("#int_p_" + id).closest('p').removeClass('alert-success').addClass('alert-danger').fadeIn('slow');
          $("#int_p_" + id).closest('p').html('<span>Errore. Riprovare!</span>');
          setTimeout(function() { $("#int_p_" + id).fadeOut('slow'); }, 3000);
        },
        success: function(data) {
          $(el).prop("disabled", false);
          if (data['code'] == '500') {
            $("#int_p_" + id).closest('p').removeClass('alert-success').addClass('alert-danger').html('<span>Errore. Riprovare!</span>');
            $("#int_p_" + id).closest('td').removeClass('alert-danger', 1000, "easeInBack");
          } else if (data['code'] == '400') {
            $("#int_p_" + id).closest('p').removeClass('alert-success').addClass('alert-danger').html('<span>Errore. Riga ordine già lavorata!</span>');
            $("#int_p_" + id).closest('td').removeClass('alert-danger', 1000, "easeInBack");
          } else if (data['code'] == '401') {
            $("#int_p_" + id).closest('p').removeClass('alert-success').addClass('alert-danger').html('<span>Errore. La macchina selezionata non è valida!</span>');
            $("#int_p_" + id).closest('td').removeClass('alert-danger', 1000, "easeInBack");
          } else {
            $("#int_p_" + id).closest('td').removeClass('alert-danger').addClass('alert-success');
            $("#int_p_" + id).closest('td').removeClass('alert-success', 1000, "easeInBack");
            // setTimeout(() => {$("#int_p_" + id).closest('td').removeClass('alert-success', 1000, "easeInBack");}, 1000);
          }
          $("#int_p_" + id).closest('p').fadeIn('slow');
          setTimeout(function() { $("#int_p_" + id).fadeOut('slow'); }, 3000);
          // location.reload();
        },
        data: {
          value: $(el).val(),
          int_customer_machine_changed: true,
          int_customer_machine_id: $(int_customer_machine_id).val(),
        },
        dataType: 'json'
      });
    });
  });
};

window.checkErrors = function() {
  $(".check_errors").each(function(i, el) {
    $(el).hover(function() {
      var children = $(el).children(".errors_tooltip:first");
      children.toggleClass("d-none");
    });
  });
}


window.aggregate = function() {
  $("#aggregate").click(function(){
    var url = "/aggregated_jobs/aggregate";
    var li_ids = $('.check_job:checkbox:checked').map(function() {
      return this.value;
    }).get();
    $.ajax({
      type: 'GET',
      url: url,
      data: { li_ids: li_ids },
      dataType: 'script'
    });
    return false;
  });
}

window.clickableTr = function() {
  $(".clickable_tr td:not(:has(a[href]))").each(function(i, el) {
    $(el).click(function() {
      var link  = $(this.closest('tr')).data("href")
      var remote  = $(this.closest('tr')).data("remote")
      if (remote) {
        $.ajax({
          url: link,
          type: "GET",
          dataType: 'script'
        });
      } else {
        window.location = link;
      }
    })
  });
}

window.collapseIconChange = function() {
  $("[data-toggle='collapse']").each(function(i,el) {
    $(el).click(function() {
      target = $($(el).data('target'));
      children = $(el).find("svg");
      if ($(el).data('parent') && !target.hasClass('show')) {
        $('.fa-caret-square-down').each(function(j, obj) {
          $(obj).removeClass('fa-caret-square-up');
          $(obj).addClass('fa-caret-square-down');
        });
      }
      if (children.hasClass('fa-caret-square-up')) {
        children.removeClass('fa-caret-square-up').addClass('fa-caret-square-down');
      } else {
        children.removeClass('fa-caret-square-down').addClass('fa-caret-square-up');
      }
    });
  });
}

window.colspans = function() {
  $('td.colspan').each(function(i, el) {
    var count = 0
    $(el).closest('table').find('tr th').each(function(i, el) {
      if ($(el).attr('colspan')) {
        count += parseInt($(el).attr('colspan'));
      } else {
        count += 1;
      }
    });
    $(el).attr('colspan', count);
  });
}

window.popover = function() {
  $('[data-toggle="popover"]').popover();
}

window.popup = function() {
  $('.flyout').hide();
  $(".popup").each(function(i,el) {
    $(this).hover(function(){
      $(el).find('.flyout').show();
      $(el).find('.description').hide();
    },function(){
      $(el).find('.flyout').hide();
      $(el).find('.description').show();
    });
  });
};

window.checkAll = function() {
  $("#check_all").click(function(){
    $("input[type=checkbox]").prop('checked', $(this).prop('checked'));
  });
}

window.fakeDateField = function() {
  $(".fake_date_field").each(function(i,el) {
    if ($(el).val()) {
      this.type = 'date';
    }
    $(el).on('focus', function () {
      this.type = 'date';
      this.click();
    });
    $(el).on('focusout', function () {
      if (this.value == '') {
        this.type = 'text';
      }
    });
  });
}

window.orderDetails = function() {
  $(".show_details").each(function(i, el) {
    $(el).click(function() {
      event.preventDefault();
      id = $(el).data('id')
      wrapper = $("#wrapper_" + id)
      wrapper_tr = wrapper.closest("tr")
      if ($(el).attr('data-status') == 'closed') {
        $(el).attr('data-status', 'open');
        $(el).find('svg').toggleClass('fa-box fa-box-open')
        // wrapper_tr.fadeIn()
        wrapper_tr.removeClass("d-none")
      } else if ($(el).attr('data-status') == 'open') {
        $(el).attr('data-status', 'closed');
        $(el).find('svg').toggleClass('fa-box fa-box-open')
        // wrapper_tr.fadeOut()
        wrapper_tr.addClass("d-none")
      }
    });
  });
}

window.selectpicker = function() {
  $('.selectpicker').selectpicker();
}

window.toggleFields = function() {
  $("select[data-behaviour='toggle_fields']").each(function(i, el) {
    toggleFieldsVisibility(el);
    $(el).change(function() {
      toggleFieldsVisibility(el);
    });
  });
}

window.toggleFieldsVisibility = function() {
  $("[data-dependency]").each(function(i,el) {
    target = $(this).data("dependency");
    values = $(this).data('dependencyvalue').toString().split(',');
    condition = $(this).data('dependencycondition');
    target_value = $("#" + target).val();
    switch(condition) {
      case 'Not-equals':
        if ($.inArray( target_value, values ) == -1 && target_value != '') {
          $(el).show();
          $(el).find('*').filter(':input:first').prop( "disabled", false );
        } else {
          $(el).hide();
          $(el).find('*').filter(':input:first').prop( "disabled", true );
        }
        break;
      case 'Equals':
        if ($.inArray( target_value, values ) != -1 && target_value != '') {
          $(el).show();
          $(el).find('*').filter(':input:first').prop( "disabled", false );
        } else {
          $(el).hide();
          $(el).find('*').filter(':input:first').prop( "disabled", true );
        }
        break;
      case 'Contains':
        if ( String(target_value).indexOf(String(values)) >= 0 && target_value != '' ) {
          $(el).show();
          $(el).find('*').filter(':input:first').prop( "disabled", false );
        } else {
          $(el).hide();
          $(el).find('*').filter(':input:first').prop( "disabled", true );
        }
      case 'Does not contain':
        if ( String(target_value).indexOf(String(values)) == -1 && target_value != '' ) {
          $(el).show();
          $(el).find('*').filter(':input:first').prop( "disabled", false );
        } else {
          $(el).hide();
          $(el).find('*').filter(':input:first').prop( "disabled", true );
        }
      case 'Starts with':
        if (String(target_value).match("^" + String(values)) && target_value != '') {
          $(el).show();
          $(el).find('*').filter(':input:first').prop( "disabled", false );
        } else {
          $(el).hide();
          $(el).find('*').filter(':input:first').prop( "disabled", true );
        }
      case 'Does not start with':
        if ( String(target_value).match("^" + String(values)) == null && target_value != '') {
          $(el).show();
          $(el).find('*').filter(':input:first').prop( "disabled", false );
        } else {
          $(el).hide();
          $(el).find('*').filter(':input:first').prop( "disabled", true );
        }
      case 'IsNil':
        if (target_value == '' && values == '') {
          $(el).show();
          $(el).find('*').filter(':input:first').prop( "disabled", false );
        } else {
          $(el).hide();
          $(el).find('*').filter(':input:first').prop( "disabled", true );
        }
        break;
      }
  });
}

window.initilizeUppy = function() {
  $(".upload_file").on("dragover", function(e) {
    $(this).click();
  });
  if($("#drag-drop-area").length > 0) {
    const Uppy = require('@uppy/core')
    const XHRUpload = require('@uppy/xhr-upload')
    const Dashboard = require('@uppy/dashboard')
    require('@uppy/core/dist/style.css')
    require('@uppy/dashboard/dist/style.css')
    const Italian = require('@uppy/locales/lib/it_IT')
    if ($("#drag-drop-area[data-uppy-max-files]").length) {
      uppy_max_files = $('#drag-drop-area').data("uppy-max-files");
    } else {
      uppy_max_files = 1
    }
    const uppy = Uppy({
      autoProceed: false,
      locale: Italian,
      restrictions: {
        // maxFileSize: 300000,
        maxNumberOfFiles: uppy_max_files,
        minNumberOfFiles: 1
        // allowedFileTypes: ['image/*', 'video/*']
      }
    })
    uppy.use(Dashboard, {
        target: '#drag-drop-area',
        inline: true,
        height: 300
    });
    uppy.use(XHRUpload, {
      endpoint: $('#drag-drop-area').data('url'),
      timeout: 300 * 1000,
      bundle: true
    })
    uppy.on('complete', (result) => { location.reload(); })
    $('.uppy-Dashboard-poweredBy').hide();
  }
}

window.toggles = function() {
  $("[data-behaviour='toggle']").each(function(i, el) {
    var div = $(el);
    div.children('a').on('click', function () {
      var url = $(this).data('url');
      $.ajax({
        type: 'PATCH',
        url: url,
        beforeSend: function() {
          $(this).removeClass('btn-success').removeClass('btn-danger').addClass('btn-warning');
        },
        success: function(data) {
          div.replaceWith(data);
        },
        dataType: 'html'
      });
    });
  });
}

window.tooltip = function() {
  $('[data-toggle="tooltip"]').tooltip();
}

window.spinner = function() {
  $(window).on("load",function(){
    $("#spinner").hide();
  });
  $('[data-spinner="true"]').on('click',function(){
    $("#spinner").show();
  });
}

// Smile specific
function initOrFilters() {
  $('#add_or_filter_select').change(function() {
    addOrFilter($(this).val(), '', []);
  });
  $('#or-filters-table td.field input[type=checkbox]').each(function() {
    toggleOrFilter($(this).val());
  });
  $('#or-filters-table').on('click', 'td.field input[type=checkbox]', function() {
    toggleOrFilter($(this).val());
  });
  $('#or-filters-table').on('click', '.toggle-multiselect', function() {
    toggleMultiSelect($(this).siblings('select'));
  });
  $('#or-filters-table').on('keypress', 'input[type=text]', function(e) {
    if (e.keyCode == 13) $(this).closest('form').submit();
  });
}

// Smile specific
function addOrFilter(field, operator, values) {
  var fieldId = field.replace('.', '_');
  var tr = $('#or_tr_'+fieldId);

  var filterOptions = availableFilters[field];
  if (!filterOptions) return;

  if (filterOptions['remote'] && filterOptions['values'] == null) {
    $.getJSON(filtersUrl, {'name': field}).done(function(data) {
      filterOptions['values'] = data;
      addOrFilter(field, operator, values) ;
    });
    return;
  }

  if (tr.length > 0) {
    tr.show();
  } else {
    buildOrFilterRow(field, operator, values);
  }
  $('#or_cb_'+fieldId).prop('checked', true);
  toggleOrFilter(field);
  $('#add_or_filter_select').val('').find('option').each(function() {
    if ($(this).attr('value') == field) {
      $(this).attr('disabled', true);
    }
  });
}

// Smile specific
function buildOrFilterRow(field, operator, values) {
  var fieldId = field.replace('.', '_');
  var filterTable = $("#or-filters-table");
  var filterOptions = availableFilters[field];
  if (!filterOptions) return;
  var operators = operatorByType[filterOptions['type']];
  var filterValues = filterOptions['values'];
  var i, select;

  var tr = $('<tr class="filter">').attr('id', 'or_tr_'+fieldId).html(
    '<td class="field"><input checked="checked" id="or_cb_'+fieldId+'" name="or_f[]" value="'+field+'" type="checkbox"><label for="or_cb_'+fieldId+'"> '+filterOptions['name']+'</label></td>' +
    '<td class="operator"><select id="or_operators_'+fieldId+'" name="or_op['+field+']"></td>' +
    '<td class="values"></td>'
  );
  filterTable.append(tr);

  select = tr.find('td.operator select');
  for (i = 0; i < operators.length; i++) {
    var option = $('<option>').val(operators[i]).text(operatorLabels[operators[i]]);
    if (operators[i] == operator) { option.attr('selected', true); }
    select.append(option);
  }
  select.change(function(){ toggleOrOperator(field); });

  switch (filterOptions['type']) {
  case "list":
  case "list_optional":
  case "list_status":
  case "list_subprojects":
    tr.find('td.values').append(
      '<span style="display:none;"><select class="value" id="or_values_'+fieldId+'_1" name="or_v['+field+'][]"></select>' +
      ' <span class="toggle-multiselect">&nbsp;</span></span>'
    );
    select = tr.find('td.values select');
    if (values.length > 1) { select.attr('multiple', true); }
    for (i = 0; i < filterValues.length; i++) {
      var filterValue = filterValues[i];
      var option = $('<option>');
      if ($.isArray(filterValue)) {
        option.val(filterValue[1]).text(filterValue[0]);
        if ($.inArray(filterValue[1], values) > -1) {option.attr('selected', true);}
        if (filterValue.length == 3) {
          var optgroup = select.find('optgroup').filter(function(){return $(this).attr('label') == filterValue[2]});
          if (!optgroup.length) {optgroup = $('<optgroup>').attr('label', filterValue[2]);}
          option = optgroup.append(option);
        }
      } else {
        option.val(filterValue).text(filterValue);
        if ($.inArray(filterValue, values) > -1) {option.attr('selected', true);}
      }
      select.append(option);
    }
    break;
  case "date":
  case "date_past":
    tr.find('td.values').append(
      '<span style="display:none;"><input type="text" name="or_v['+field+'][]" id="or_values_'+fieldId+'_1" size="10" class="value date_value" /></span>' +
      ' <span style="display:none;"><input type="text" name="or_v['+field+'][]" id="or_values_'+fieldId+'_2" size="10" class="value date_value" /></span>' +
      ' <span style="display:none;"><input type="text" name="or_v['+field+'][]" id="or_values_'+fieldId+'" size="3" class="value" /> '+labelDayPlural+'</span>'
    );
    $('#or_values_'+fieldId+'_1').val(values[0]).datepicker(datepickerOptions);
    $('#or_values_'+fieldId+'_2').val(values[1]).datepicker(datepickerOptions);
    $('#or_values_'+fieldId).val(values[0]);
    break;
  case "string":
  case "text":
    tr.find('td.values').append(
      '<span style="display:none;"><input type="text" name="or_v['+field+'][]" id="or_values_'+fieldId+'" size="30" class="value" /></span>'
    );
    $('#or_values_'+fieldId).val(values[0]);
    break;
  case "relation":
    tr.find('td.values').append(
      '<span style="display:none;"><input type="text" name="or_v['+field+'][]" id="or_values_'+fieldId+'" size="6" class="value" /></span>' +
      '<span style="display:none;"><select class="value" name="or_v['+field+'][]" id="or_values_'+fieldId+'_1"></select></span>'
    );
    $('#or_values_'+fieldId).val(values[0]);
    select = tr.find('td.values select');
    for (i = 0; i < filterValues.length; i++) {
      var filterValue = filterValues[i];
      var option = $('<option>');
      option.val(filterValue[1]).text(filterValue[0]);
      if (values[0] == filterValue[1]) { option.attr('selected', true); }
      select.append(option);
    }
  case "integer":
  case "float":
  case "tree":
    tr.find('td.values').append(
      '<span style="display:none;"><input type="text" name="or_v['+field+'][]" id="or_values_'+fieldId+'_1" size="14" class="value" /></span>' +
      ' <span style="display:none;"><input type="text" name="or_v['+field+'][]" id="or_values_'+fieldId+'_2" size="14" class="value" /></span>'
    );
    $('#or_values_'+fieldId+'_1').val(values[0]);
    $('#or_values_'+fieldId+'_2').val(values[1]);
    break;
  }
}

// Smile specific
function toggleOrFilter(field) {
  var fieldId = field.replace('.', '_');
  if ($('#or_cb_' + fieldId).is(':checked')) {
    $("#or_operators_" + fieldId).show().removeAttr('disabled');
    toggleOrOperator(field);
  } else {
    $("#or_operators_" + fieldId).hide().attr('disabled', true);
    enableOrValues(field, []);
  }
}

// Smile specific
function enableOrValues(field, indexes) {
  var fieldId = field.replace('.', '_');
  $('#or_tr_'+fieldId+' td.values .value').each(function(index) {
    if ($.inArray(index, indexes) >= 0) {
      $(this).removeAttr('disabled');
      $(this).parents('span').first().show();
    } else {
      $(this).val('');
      $(this).attr('disabled', true);
      $(this).parents('span').first().hide();
    }

    if ($(this).hasClass('group')) {
      $(this).addClass('open');
    } else {
      $(this).show();
    }
  });
}

// Smile specific
function toggleOrOperator(field) {
  var fieldId = field.replace('.', '_');
  var operator = $("#or_operators_" + fieldId);
  switch (operator.val()) {
    case "!*":
    case "*":
    case "t":
    case "ld":
    case "w":
    case "lw":
    case "l2w":
    case "m":
    case "lm":
    case "y":
    case "o":
    case "c":
    case "*o":
    case "!o":
      enableOrValues(field, []);
      break;
    case "><":
      enableOrValues(field, [0,1]);
      break;
    case "<t+":
    case ">t+":
    case "><t+":
    case "t+":
    case ">t-":
    case "<t-":
    case "><t-":
    case "t-":
      enableOrValues(field, [2]);
      break;
    case "=p":
    case "=!p":
    case "!p":
      enableOrValues(field, [1]);
      break;
    default:
      enableOrValues(field, [0]);
      break;
  }
}


$(document).on('turbolinks:load', function() {
  $('select').dropdown({ placeholder: true });
  
  $(".js-update-transaction-select select").on("change", updateTransaction);

  $(".js-export-item").on("click", function() {
    setTimeout(() => {
      $(".js-sage-text").text("Export for SAGE");
      $(".js-cash-report-text").text("Export for cash report");
    });
  })

  $('.js-transactions-all').on('click', () => changeView('all'));
  $('.js-transactions-uncategorized').on('click', () => changeView('uncategorized'));

  function changeView(name) {
    if (name === 'uncategorized') {
      window.location = '/admin/transactions?scope=uncategorized'
    }
    else {
      window.location = '/admin/transactions'
    }
    $('select').dropdown({ placeholder: true });
  }

  function refreshTransactionRow(parentRow, transaction) {
    parentRow.find('.js-group').text(transaction.group);
    if (transaction.transaction.budget_category_id) {
      parentRow.removeClass('uncategorized');
    } else {
      parentRow.addClass('uncategorized');
    }
  }  
  
  function refreshUncategorized(count) {
    const label = $('.js-transactions-uncategorized .label');
    label.text(count);
    if (count === 0) {
      label.removeClass('purple');
    }
    else {
      label.addClass('purple');
    }
  }

  function updateTransaction(event) {
    const target = event.currentTarget;
    const parentRow = $(target).closest("tr");
    const transactionId = parentRow.data().transactionId;
    const data = { [target.name]: target.value }

    $.ajax({
      type: 'PUT',
      url: `/admin/transactions/${transactionId}`,
      contentType: 'application/json',
      accept: 'application/json',
      data: JSON.stringify(data),
      success: function(response) {
        refreshTransactionRow(parentRow, response);
        refreshUncategorized(response.uncategorized);
      },
      error: function(response) {
        console.log('error');
        console.log(response);
      }
    })
  }
});

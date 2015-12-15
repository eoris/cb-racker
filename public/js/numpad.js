$('#numPad button').click(function() {
    var value = $(this).text();
    var input = $('#guess_input');
    if (input.val().length < 4) {
      input.val(input.val() + value);
      return false;
    }
});

$('#numClr').click(function() {
    var value = $(this).text();
    var input = $('#guess_input');
    input.val('');
    return false;
});

$('#numDel').click(function() {
    var str = $('#guess_input').val();
    $('#guess_input').val(str.substring(0, str.length - 1));
    return false;
});
$(function() {
  $('form').submit(function() {
    var emptyFlag = false;
    $(this).find('input').each(function() {
      if ($(this).val() === '') {
        emptyFlag = true;
      }
    });
    var content = $('#homework-content').val();
    if (content === '') {
      emptyFlag = true;
    }
    if (emptyFlag) {
      alert('表单不能有空');
      return false;
    }
  });
});
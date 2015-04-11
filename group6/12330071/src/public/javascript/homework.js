$(function() {
    $('.set-grade').click(function() {
        var studentId = $(this).attr('data-id');
        var homeworkId = $('#homework').attr('data-id');
        var grade = $('#student' + studentId).val();
        if (grade === '') {
            alert('表单为空或者为无效数字');
        } else {
            $.post('/homework/grade/' + homeworkId, {
                grade: grade,
                studentId: studentId
            }, function(data) {
                if (data['result']) {
                    $('#grade' + studentId).html(grade);
                } else {
                    alert('有bug, 赶紧修复');
                }
            }, 'json');
        }
    });
});
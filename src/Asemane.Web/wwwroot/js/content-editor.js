(function ($) {
    'use strict';
    $('.content-editor').summernote({
        lang: 'fa-IR', height: 360, disableDragAndDrop: true,
        styleTags: ['p', 'h2', 'h3', 'h4', 'blockquote', 'pre'],
        toolbar: [
            ['history', ['undo', 'redo']], ['style', ['style']],
            ['font', ['bold', 'italic', 'underline', 'strikethrough', 'clear']],
            ['color', ['color']], ['paragraph', ['ul', 'ol', 'paragraph']],
            ['insert', ['table', 'link', 'hr']], ['view', ['fullscreen', 'codeview', 'help']]
        ],
        callbacks: { onInit: function () { $(this).next('.note-editor').find('.note-editable').attr('dir', 'ltr').css('text-align', 'left'); }, onImageUpload: function () { window.alert('تصاویر را از صفحه مدیریت تصاویر محتوا بارگذاری کنید.'); } }
    });
    $('.content-editor').closest('form').on('submit', function () {
        $(this).find('.content-editor').each(function () { $(this).val($(this).summernote('code')); });
    });
})(jQuery);

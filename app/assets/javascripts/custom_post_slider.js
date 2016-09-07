$(function () {
    $('.attachment-slide-wrapper .slide-item').click(function () {
        newSrc = $(this).find('img').attr('src');
        $(this).parent().find('.slide-item').removeClass('current');
        $(this).addClass('current');
        bigAttachmentWrapper = $(this).parents('.post-attachment-wrapper').find('.attachment-big');
        console.log(bigAttachmentWrapper.find('img'));
        bigAttachmentWrapper.find('img').attr('src', newSrc);
    });
});
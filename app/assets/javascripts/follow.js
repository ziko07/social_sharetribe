window.ST.onFollowButtonAjaxComplete = function (event, xhr) {
    var target = $(event.target);
    var newButtonContainer = $(xhr.responseText);

    // Work around "Unfollow" showing up too soon
    $(".button-hoverable", newButtonContainer).addClass("button-disable-hover");
    newButtonContainer.on(
        "mouseleave", function () {
            $(".button-disable-hover", newButtonContainer).removeClass("button-disable-hover");
        }
    );

    target.parents(".follow-button-container:first").replaceWith(newButtonContainer);
    $(".follow-button", newButtonContainer).on("ajax:complete", window.ST.onFollowButtonAjaxComplete);
};

$('#description').focus(function () {
    if (!$('.attachment-submit').is(':visible')) {
        $('.attachment-submit').slideDown('fast');
        $(this).animate({
            height: "65"
        }, 500, function () {
        });
    }
});

$(document).on('click', '.reply-comments', function () {
    commentsWrapper = $(this).parents('.wall-post-content-wrapper').find('.comments-wrapper');
    if (!commentsWrapper.is(':visible')) {
        $('.comments-wrapper').slideUp('fast');
        commentsWrapper.slideDown('fast');
    }
});

$(document).on('click', '.cancel-comments', function () {
    $(this).parents('.comments-wrapper').slideUp('fast');
});

//$('.reply-comments').click(function () {
//
//});

//$('.cancel-comments').click(function () {
//    $(this).parents('.comments-wrapper').slideUp('fast');
//});

$(document).ready(function () {
    $(".user-notification-wrapper").niceScroll();
});

$('#notification-list ul').scroll(function () {
    var count = $('#notification-list').find(("li")).length;
    if ($(this).scrollTop() + $(this).innerHeight() == this.scrollHeight) {
        $.ajax({
            url: '/notification',
            type: 'get',
            dataType: 'script',
            data: {count: count},
            success: function (res) {

            },
            error: function (e) {

            }
        });
    }
});


window.ST.initializeFollowButtons = function () {
    $(".follow-button").on("ajax:complete", window.ST.onFollowButtonAjaxComplete);
};

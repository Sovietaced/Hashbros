//colors
//same as in _variables.scss
//keep it synchronized
var $lime = "#8CBF26",
    $red = "#e5603b",
    $redDark = "#d04f4f",
    $blue = "#6a8da7",
    $green = "#56bc76",
    $orange = "#eac85e",
    $pink = "#E671B8",
    $purple = "#A700AE",
    $brown = "#A05000",
    $teal = "#4ab0ce",
    $gray = "#666",
    $white = "#fff",
    $textColor = $gray;

//turn off charts is needed
var chartsOff = false;
if (chartsOff){
    nv.addGraph = function(){};
}

COLOR_VALUES = [$red, $orange, $green, $blue, $teal, $redDark];

var colors = function(){
    if (!window.d3) return false;
    return d3.scale.ordinal().range(COLOR_VALUES);
}();

function keyColor(d, i) {
    return colors(d.key)
}

function closeNavigation(){
    var $accordion = $('#side-nav').find('.accordion-body.in');
    $accordion.collapse('hide');
    $accordion.siblings(".accordion-toggle").addClass("collapsed");
}

function resetContentMargin(){
    if ($(window).width() > 767){
        $(".content").css("margin-top", '');
    }
}

$(function(){

    $("#sidebar").on("mouseleave",function(){
        if (($(this).is(".sidebar-icons") || $(window).width() < 1049) && $(window).width() > 767){
            setTimeout(function(){
                closeNavigation();
            }, 300); // some timeout for animation
        }
    });

    $(window).resize(function(){
        closeNavigation();
        resetContentMargin();
    });

    //class-switch for button-groups
    $(".btn-group > .btn[data-toggle-class]").click(function(){
        var $this = $(this),
            $parent = $this.parent();

        if ($parent.data("toggle") == "buttons-radio"){
            $parent.children(".btn[data-toggle-class]").removeClass(function(){
                return $(this).data("toggle-class")
            }).addClass(function(){
                    return $(this).data("toggle-passive-class")
                });
            $this.removeClass($(this).data("toggle-passive-class")).addClass($this.data("toggle-class"));
        } else {
            $this.toggleClass($(this).data("toggle-passive-class")).toggleClass($this.data("toggle-class"));
        }
    });

    var $sidebar = $('#sidebar'),
        menuToggler = $('#menu-toggler');

    $("#search-toggle").click(function(){
        //first hide menu if open

        if ($sidebar.data('collapse')){
            $sidebar.collapse('hide');
        }

        var $notifications = $('.notifications'),
            notificationsPresent = !$notifications.is(':empty');

        $("#search-form").css('height', function(){
            var $this = $(this);
            if ($this.height() == 0){
                $this.css('height', 40);
                notificationsPresent && $notifications.css('top', 86);
            } else {
                $this.css('height', 0);
                notificationsPresent && $notifications.css('top', '');
            }
        });
    });

    menuToggler.on('click', function(e) {
        $sidebar.collapse({toggle : true});
        if ($sidebar.is(":visible")) {
            $sidebar.removeClass('open');
        }
        if (!$sidebar.hasClass('in')) {
            $sidebar.addClass('open');
        }
    });

    $sidebar.on('hide', function() {
        console.log('hidden');
        $sidebar.removeClass('open');
    });

    //hide search field if open
    $sidebar.on('show', function () {
        var $notifications = $('.notifications'),
            notificationsPresent = !$notifications.is(':empty');
        $("#search-form").css('height', 0);
        notificationsPresent && $notifications.css('top', '');
    });

    /*   Move content down when second-level menu opened */
    $("#side-nav").find("a.accordion-toggle").click(function(){
        var $this = $(this),
            initialContentMargin = 370; //if changed in css change here!
        if ($(window).width() < 768){
            var $secondLevelMenu = $this.find("+ ul"),
                $menuChildren = $secondLevelMenu.find("> li"),
                menuHeight = $menuChildren.length * $menuChildren.height(),
                $content = $(".content");
            if (!$secondLevelMenu.is(".in")){
                $content.css("margin-top", initialContentMargin + menuHeight + 'px');
            } else {
                $content.css("margin-top", '');
            }
        }
    });

    // Include the UserVoice JavaScript SDK (only needed once on a page)
    UserVoice=window.UserVoice||[];(function(){var uv=document.createElement('script');uv.type='text/javascript';uv.async=true;uv.src='//widget.uservoice.com/NZ2vyT96xE2wujWR3X2efg.js';var s=document.getElementsByTagName('script')[0];s.parentNode.insertBefore(uv,s)})();

    //
    // UserVoice Javascript SDK developer documentation:
    // https://www.uservoice.com/o/javascript-sdk
    //

    // Set colors
    UserVoice.push(['set', {
      accent_color: '#448dd6',
      trigger_color: 'white',
      trigger_background_color: 'rgba(46, 49, 51, 0.6)'
    }]);

    // Identify the user and pass traits
    // To enable, replace sample data with actual user traits and uncomment the line
    UserVoice.push(['identify', {
      //email:      'john.doe@example.com', // User’s email address
      //name:       'John Doe', // User’s real name
      //created_at: 1364406966, // Unix timestamp for the date the user signed up
      //id:         123, // Optional: Unique id of the user (if set, this should not change)
      //type:       'Owner', // Optional: segment your users by type
      //account: {
      //  id:           123, // Optional: associate multiple users with a single account
      //  name:         'Acme, Co.', // Account name
      //  created_at:   1364406966, // Unix timestamp for the date the account was created
      //  monthly_rate: 9.99, // Decimal; monthly rate of the account
      //  ltv:          1495.00, // Decimal; lifetime value of the account
      //  plan:         'Enhanced' // Plan name for the account
      //}
    }]);

    // Add default trigger to the bottom-right corner of the window:
    UserVoice.push(['addTrigger', { mode: 'smartvote', trigger_position: 'bottom-right' }]);

    // Or, use your own custom trigger:
    //UserVoice.push(['addTrigger', '#id', { mode: 'smartvote' }]);

    // Autoprompt for Satisfaction and SmartVote (only displayed under certain conditions)
    UserVoice.push(['autoprompt', {}]);
});

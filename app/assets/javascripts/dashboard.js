//We're going to need to set the headers for all AJAX requests to include the CSRF token
$.ajaxSetup({
	headers: {
		'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
	}
});

$(document).ready(function() {
	// Will need to move this into a nicer function later, but this
	// allows us to have any elements with .twipsy to have a tooltip
	$('.twipsy').tooltip();
	$('.tablesorter').tablesorter();
	var refreshCountdown = $('#refresh-countdown'),
		countdown = 90000,
		notificationsMenuToggle = $('#notifications-menu-toggle'),
		unreadNotificationCount = $('#unread-notification-count');

	if (refreshCountdown.length) {
		setInterval(function(e) {
			if (countdown === 0) {
				refreshDashboard();
				countdown = 90000;
			}
			countdown -= 1000;
			refreshCountdown.html(countdown / 1000);
		}, 1000);
	}

	setInterval(function(e) {
		$.post('/notifications/poll', function(response) {
			$('#notifications-menu').replaceWith(response.data.markup);
			$('unreadNotificationCount').html(response.data.count);
		},'json');
	}, 90000);

	function refreshDashboard() {
		// Post to the URL that is in the data-url field of the reload button
		$.post('/users/dashboard-info', function(response) {
			if (response.status === 'success') {
				$('#visits-info').replaceWith(response.data.markup.visits_info);
				$('#pool-stats').replaceWith(response.data.markup.pool_stats);
				$('#user-latest-rounds').replaceWith(response.data.markup.user_latest_rounds);
				$('#basic-stats').replaceWith(response.data.markup.hashbros_basic_stats);
				var userHashRateGraphWrapper = $('#user-hashrate-graph-wrapper');
				userHashRateGraphWrapper.replaceWith(response.data.markup.user_hash_rate_graph);
				graphs.drawHashrateGraph(userHashRateGraphWrapper.find('#user-hashrate-graph'), response.data.user_metrics_data);
				$('.response').empty();
				$('.tablesorter').tablesorter();
			} else {
				$('.response').empty();
				$('.response').html(createAlert(response.status, response.message));
			}
		}, 'json')
		.error(function(response) {
			$('.response').empty();
			$('.response').html(createAlert(response.status, response.message));
		}, 'json');
	};

	notificationsMenuToggle.on('click', function(e) {
		$.get('/users/notifications/mark-all-as-read', function(response) {

		});
		unreadNotificationCount.html('0');
	});

});

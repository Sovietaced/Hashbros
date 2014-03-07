$(document).ready(function() {
	var signUpForm = $('#new_user'),
		redeemUserPayoutsButton = $('#redeem-user-payouts-button'),
		gauthTestButton = $('#gauth_test');

	signUpForm.validate({
		rules: {
			 "user[email]": {
				 required: true
			 },
			 "user[username]": {
				 required: true
			 },
			 "user[pin]": {
				 required: true,
				 digits: true,
				 maxlength: 4,
				 minlength: 4
			 },
			 "user[password]": {
				 required: true
			 },
			 "user[password_confirmation]": {
				 required: true
			 }
		 }
	});

	redeemUserPayoutsButton.on('click', function(e) {
		var el = $(this);

		e.preventDefault();

		$.post('/users/load-reauthenticate-modal', function(response) {
			if (response.status === 'success') {
				var modal = $('#verify-credentials-modal');
				if (!modal.length) {
					$(document.body).append($(response.data.modal_markup));
				} else {
					modal.replaceWith($(response.data.modal_markup));
				}
				modal = $('#verify-credentials-modal');
				var form = modal.find('form');
				bindReauthenticateModal(modal);
				// Disable submit button
				$('button[type="submit"]').hide();
				modal.modal('show');
			}
		},'json');
	});

	var bindReauthenticateModal = function(m) {
		var modal = $(m),
			form = modal.find('form');

		$('button[type="verify"]').on('click', function(e) {
			e.preventDefault();

			$.post('/users/reauthenticate', form.serialize(), function(response) {
				if (response.status === 'success') {
					$('button[type="verify"]').hide();
					$('button[type="submit"]').show();
					modal.find('.response').html(createSuccessAlert(response.message));
				} else {
					modal.find('.response').html(createErrorAlert(response.message));
				}
			},'json');
		});
	};

	gauthTestButton.on('click', function(e) {
		e.preventDefault();
		var el = $(this);

		$.post(el.data('url'), {gauth_code: $('#gauth_code').val()}, function(response) {
			var responseDiv = $('#response');
			responseDiv.empty();
			responseDiv.html(response.message);
		});
	});
});

var graphs = {
	defaultHighChartsSettings: {
		chart: {
			type: 'area',
			backgroundColor:'rgba(255, 255, 255, 0.1)'
		},
		title: {
			text: ''
		},
		credits: {
			enabled: false
		},
		legend: {
			enabled: false
		}
	},
	drawHashrateGraph: function(div, metrics_data) {
		var hashrateData = graphs.extractHashRates(metrics_data);
		var hashrateGraphSettings = $.extend({
			xAxis: {
				categories: graphs.extractDates(metrics_data),
				labels: {
					style: {
						color: 'white',
					}
				},
				title: {
					style: {
						color: 'white',
					},
					text: 'Date/Time'
				},
				tickInterval: 600
			},
			yAxis: {
				labels: {
					style: {
						color: 'white',
					}
				},
				title: {
					style: {
						color: 'white',
					},
					text: 'User Hash Rate in MHs'
				}
			},
			series: [{
				name: 'User Hash Rate in MHs',
				color: '#56bc76',
				data: hashrateData
			},
			{
				name: 'User Hash Rate Line of Best Fit',
				type: 'line',
				marker: { enabled: false },
				data: (function() { return fitData(hashrateData).data; })()
			}]
		}, graphs.defaultHighChartsSettings);
		div.highcharts(hashrateGraphSettings);
	},
	extractDates: function(data) {
		var dates = [];
		$.each(data, function(i, val) {
			var newDate = new Date(val['created_at']);
			dates.unshift(newDate);
		});
		return dates;
	},
	extractHashRates: function(data) {
		var hashrates = [];
		$.each(data, function(i, val) {
			hashrates.unshift(val['hash_rate_mhs']);
		});
		return hashrates;
	},
};

$(document).ready(function() {
	var hashrateGraph = $('#user-hashrate-graph');

	// Check to see if we're doing this on the metrics page
	if (hashrateGraph.length) {
		graphs.drawHashrateGraph(hashrateGraph, metrics_data);
	}
});



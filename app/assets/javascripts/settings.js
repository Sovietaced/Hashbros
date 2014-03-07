$(document).ready(function() {
	var coinSelectorDropdown = $('#coin_id'),
		userRedemptionSettingsForm = $('#user_redemption_settings_form');

	// Seed it
	userRedemptionSettingsForm.validate({
		rules: {
			btc_threshold: {
					required: true,
					range: [0.0005, 1.0]
			},
		}
	});

	coinSelectorDropdown.on('change', function(e) {
		e.preventDefault();
		$.get("/users/load_setting/" + $("#coin_id").val(), function(response) {
			$('#exchange_address').val(response.setting.payout_address);
			$('#is_auto_trading').prop('checked', response.setting.is_auto_trading);
		},'json');
	});
});

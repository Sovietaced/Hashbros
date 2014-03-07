$(document).ready(function() {
	var tfaCheckbox = $('#user_gauth_enabled'),
		warningDiv = $('#warning');

	tfaCheckbox.change(function(){
		var el = $(this),
			checked = el.prop('checked');

		if (checked) {
			warningDiv.removeClass('hide');
		} else {
			warningDiv.addClass('hide');
		}
		console.log(warningDiv);
	});
});

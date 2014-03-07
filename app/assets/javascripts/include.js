function createAlert(status, message) {
	if (status === 'success') {
		return createSuccessAlert(message);
	} else if (status === 'error') {
		return createErrorAlert(message);
	} else if (status === 'info') {
		return createInfoAlert(message);
	}
};

function createInfoAlert(message) {
	return '<div class="alert alert-info alert-dismissable">' +
			'<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
			'<strong>Info</strong> ' + message + '</div>'
};

function createErrorAlert(message) {
	return '<div class="alert alert-danger alert-dismissable">' +
			'<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
			'<strong>Error</strong> ' + message + '</div>'
};

function createSuccessAlert(message) {
	return '<div class="alert alert-success alert-dismissable">' +
			'<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
			'<strong>Success</strong> ' + message + '</div>'
};

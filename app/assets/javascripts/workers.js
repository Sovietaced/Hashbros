$(document).ready(function() {
	var hashrateGraph = $('#worker-hashrate-graph');

	// Check to see if we're doing this on the metrics page
	if (hashrateGraph.length) {
		var defaultHighChartsSettings = {
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
		};

		function drawHashrateGraph(div, hashrateData, dateData) {
			var hashrateGraphSettings = $.extend({
				xAxis: {
					categories: dateData,
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
						text: 'Worker Hash Rate in MHs'
					}
				},
				series: [{
					name: 'Worker Hash Rate in MHs',
					color: '#56bc76',
					data: hashrateData
				}]
			}, defaultHighChartsSettings);
			div.highcharts(hashrateGraphSettings);
		}

		function extractDates(data) {
			var dates = [];
			$.each(data, function(i, val) {
				var newDate = new Date(val['created_at']);
				dates.unshift(newDate);
			});
			return dates;
		}

		function extractHashRates(data) {
			var hashrates = [];
			$.each(data, function(i, val) {
				hashrates.unshift(val['hash_rate_mhs']);
			});
			return hashrates;
		}

		var extractedDates = extractDates(metrics_data);
		drawHashrateGraph(hashrateGraph, extractHashRates(metrics_data), extractedDates);
	}
});


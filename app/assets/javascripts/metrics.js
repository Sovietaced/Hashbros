$(document).ready(function() {
	var hashrateGraph = $('#hashrate-graph');

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
						text: 'Pool Hash Rate in MHs'
					},
					min: 0
				},
				series: [{
					name: 'Pool Hashrate in MHs',
					color: '#56bc76',
					type: 'area',
					data: hashrateData
				},
				{
					name: 'Hashrate Line of Best Fit',
					type: 'line',
					marker: { enabled: false },
					data: (function() { return fitData(hashrateData).data; })()
				}]
			}, defaultHighChartsSettings);
			div.highcharts(hashrateGraphSettings);
		}

		function drawActiveWorkersGraph(div, activeWorkersData, dateData) {
			var activeWorkersGraphSettings = $.extend({
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
						text: 'Active Workers Count'
					}
				},
				series: [{
					name: 'Active Workers',
					color: '#56bc76',
					type: 'area',
					data: activeWorkersData
				},
				{
					name: 'Active Workers Line of Best Fit',
					type: 'line',
					marker: { enabled: false },
					data: (function() { return fitData(activeWorkersData).data; })()
				}]
			}, defaultHighChartsSettings);
			div.highcharts(activeWorkersGraphSettings);
		}

		function drawEarningsGraph(div, earningsData) {
			var earningsGraphSettings = $.extend({
				xAxis: {
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
					ordinal: false
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
						text: 'Estimated Earnings in BTC'
					}
				},
				rangeSelector:{
					enabled:false
				},
				series: [{
					name: 'Estimated Earnings in BTC',
					color: '#56bc76',
					type: 'area',
					data: earningsData
				}]
			}, defaultHighChartsSettings);
			div.highcharts('StockChart', earningsGraphSettings);
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
				hashrates.unshift(val['pool_hash_rate_mhs']);
			});
			return hashrates;
		}

		function extractActiveWorkers(data) {
			var activeWorkers = [];
			$.each(data, function(i, val) {
				activeWorkers.unshift(val['workers_count']);
			});
			return activeWorkers;
		}

		function extractEstimatedEarnings(data) {
			var estimatedEarnings = [];
			$.each(data, function(i, val) {
				estimatedEarnings.push({x: new Date(val['created_at']), y: val['estimated_earnings']});
			});
			return estimatedEarnings;
		}

		var extractedDates = extractDates(earnings_data[0].earnings_data);
		drawHashrateGraph(hashrateGraph, extractHashRates(earnings_data[0].metrics_data), extractedDates);
		drawActiveWorkersGraph($('#active-workers-graph'), extractActiveWorkers(earnings_data[0].metrics_data), extractedDates);
		drawEarningsGraph($('#estimated-earnings-graph'), extractEstimatedEarnings(earnings_data[0].earnings_data));
	}
});

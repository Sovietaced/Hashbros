$(document).ready(function() {
	var profitabilityTable = $('#coin-tabs');

	if (profitabilityTable.length) {
		var rows = profitabilityTable.find('tbody tr');

		function convertStringsToFloats(arr) {
			var coinData = [];
			// Convert all the strings to floats so HighCharts can use it
			$.each(arr, function(j, k) {
				if (k != null) {
					coinData.push(parseFloat(k));
				} else {
					coinData.push(0);
				}
			});
			return coinData;
		}

		// Determine the color of the area plot for the chart
		// shouldInvert tells us if we should flip around what we see as "good" or "bad"
		// shouldInvert should be true for a graph like "difficulty" since the lower difficulty, the better
		// shouldInvert should be false for a graph like "profitability" since higher profitability, the better
		function determineChartColor(arr, shouldInvert) {
			var greenColor = '#56bc76',
				redColor = '#e5603b',
				goodColor = shouldInvert ? redColor : greenColor,
				badColor = shouldInvert ? greenColor : redColor;

			if (arr[arr.length - 2] > arr[arr.length - 1]) {
				return badColor;
			} else {
				return goodColor;
			}
		}

		$.each(rows, function(i, val) {
			var el = $(val),
				rowId = el.data('id'),
				profitabilityChart = el.find('.profitability-chart'),
				profitabilityData = convertStringsToFloats(coin_average_profitabilities[rowId]),
				difficultyChart = el.find('.difficulty-chart'),
				difficultyData = convertStringsToFloats(coin_average_difficultues[rowId]),
				exchangeChart = el.find('.exchange-chart'),
				exchangeData = convertStringsToFloats(coin_average_exchanges[rowId]),
				networkHashRateChart = el.find('.network-hash-rate-chart'),
				networkHashRateData = convertStringsToFloats(coin_average_network_hash_rates[rowId]),
				today = new Date();

			var defaultHighChartsSettings = {
				chart: {
					type: 'area',
					backgroundColor:'rgba(255, 255, 255, 0.1)'
				},
				xAxis: {
					title: {
						enabled: true
					},
					labels: {
						enabled: false
					}
				},
				yAxis: {
					title: {
						enabled: false
					},
					labels: {
						enabled: false
					}
				},
				title: {
					text: ''
				},
				credits: {
					enabled: false
				},
				legend: {
					enabled: false
				},
				tooltip: {
					formatter: function() {
						var d = new Date();
						d.setDate(today.getDate() - (number_of_days - this.x));
						var dateString = (d.getMonth() + 1) + "/" + d.getDate() + "/" + d.getFullYear();
						return dateString + ': ' + this.y.toFixed(6);
					}
				}
			};

			var profitabilityChartSettings = $.extend({series: [{
					name: 'Avg Profitability',
					color: determineChartColor(profitabilityData, false),
					data: profitabilityData
				}]}, defaultHighChartsSettings);

			profitabilityChart.highcharts(profitabilityChartSettings);

			var difficultyChartSettings = $.extend({series: [{
					name: 'Avg Difficulty',
					color: determineChartColor(difficultyData, true),
					data: difficultyData
				}]}, defaultHighChartsSettings);

			difficultyChart.highcharts(difficultyChartSettings);

			var exchangeChartSettings = $.extend({series: [{
					name: 'Avg Exchange Rate',
					color: determineChartColor(exchangeData, false),
					data: exchangeData
				}]}, defaultHighChartsSettings);

			exchangeChart.highcharts(exchangeChartSettings);

			var networkHashRateChartSettings = $.extend({series: [{
					name: 'Avg Network Hash Rate',
					color: determineChartColor(networkHashRateData, false),
					data: networkHashRateData
				}]}, defaultHighChartsSettings);

			networkHashRateChart.highcharts(networkHashRateChartSettings);
		});
	}
});

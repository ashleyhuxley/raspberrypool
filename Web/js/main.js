var poolChart;

var baseUrl = "";
var dateFormat = "YYYY-MM-DD HH:mm:ss";
var customDateDialog = null;
var tempDialog = null;
var wait = 0;
var preset = "last24hours";


function GetData() {
	$.ajax(baseUrl + "/data/air/latest").done(function(data) { $("#air-latest").text(tempFormat(data)) });
	$.ajax(baseUrl + "/data/pool/latest").done(function(data) { $("#pool-latest").text(tempFormat(data)) });
	$.ajax(baseUrl + "/data/output/latest").done(function(data) { $("#heater-latest").text(tempFormat(data)) });
	
	$.ajax(baseUrl + "/data/heater/status").done(function(data) { setStatus("heater", data); } );
	$.ajax(baseUrl + "/data/pump/status").done(function(data) { setStatus("pump", data); } );
	
	$.ajax(baseUrl + "/data/timer").done(function(data) { 
		$("#desired-temp").val(data.desiredTemperature);
		$("#temp-start").val(data.startTime);
		$("#temp-end").val(data.endTime);
	});
}

function GetChartData() {
	var now = moment.utc().format(dateFormat);
	var from = moment.utc().add(-24, "hours").format(dateFormat);
	var p = 2;
	var unit = "minute";
	
	if (preset == "last7days") {
		from = moment.utc().add(-7, "days").format(dateFormat);
		unit = "hour";
		p = 3;
	} else if (preset == "last3days") {
		from = moment.utc().add(-3, "days").format(dateFormat);
		unit = "hour";
		p = 4;
	} else if (preset == "lastmonth") {
		from = moment.utc().add(-1, "months").format(dateFormat);
		poolChart.options.scales.xAxes[0].time.unit = "day";
		unit = "day";
		p = 4;
	}
	
	poolChart.options.scales.xAxes[0].time.unit = unit;
	
	dateQuery = "from=" + from + "&to=" + now;
	
	$.ajax(baseUrl + "/data/pool?" + dateQuery + "&precision=3").done(function(data) { wait++; setChartData("pool", data); } );
	$.ajax(baseUrl + "/data/air?" + dateQuery + "&precision=3").done(function(data) { wait++; setChartData("air", data); } );
	$.ajax(baseUrl + "/data/output?" + dateQuery + "&precision=3").done(function(data) { wait++; setChartData("output", data); } );
	
	$.ajax(baseUrl + "/data/heater?" + dateQuery).done(function(data) { wait++; setChartData("heater", data); } );
	$.ajax(baseUrl + "/data/pump?" + dateQuery).done(function(data) { wait++; setChartData("pump", data); } );
}

function setChartData(sensor, data) {
	var max = 0;
	var min = 100;
	
	for (var i = 0; i < data.length; i++) {
		var y = data[i].y;
		if (y > max) { max = y }
		if (y < min) { min = y }
	}
	
	$("#" + sensor + "-max").text(tempFormat(max));
	$("#" + sensor + "-min").text(tempFormat(min));
	
	switch (sensor) {
		case "pool":
			poolChart.data.datasets[0].data = data;
			break;
		case "air":
			poolChart.data.datasets[1].data = data;
			break;
		case "output":
			poolChart.data.datasets[2].data = data;
			break;
		case "heater":
			poolChart.data.datasets[3].data = data;
			break;
		case "pump":
			poolChart.data.datasets[4].data = data;
			break;
	}
	
	wait--;
	if (wait == 0) { poolChart.update(); }
}

function setStatus(appliance, value) {
	if (value) {
		$("#" + appliance + "-on").show();
		$("#" + appliance + "-off").hide();
	} else {
		$(appliance + "-on").hide();
		$(appliance + "-off").show();
	}
}

function tempFormat(number) {
	return (Math.round(number * 10) / 10) + "°C";
}

function setCustomDate()  {
	customDateDialog.dialog("close");
}

function setTemp() {
	tempDialog.dialog("close");
	$.ajax(baseUrl + "/data/timer", {
		method: "POST",
		contentType: 'application/json',
		data: JSON.stringify( {
			desiredTemperature: parseInt($("#desired-temp").val()),
			startTime: $("#temp-start").val(),
			endTime: $("#temp-end").val()
		})
	});
}

$(document).ready(function() {
	customDateDialog = $("#custom-dialog").dialog({
		autoOpen: false,
		height: 260,
		width: 350,
		model: true,
		buttons: {
			"OK": setCustomDate
		}
	});
	
	tempDialog = $("#temp-dialog").dialog({
		autoOpen: false,
		height: 260,
		width: 360,
		model: true,
		buttons: {
			"OK": setTemp
		}
	});

	$(".timepick").flatpickr({enableTime: true, time_24hr: true});

	GetData();

	var ctx = document.getElementById('chart').getContext('2d');

	poolChart = new Chart(ctx, {
		type: 'line',
		data: {
			datasets: [
				{
					label: 'Pool',
					data: [],
					borderColor: [
						'rgba(54, 162, 235, 1)'
					],
					backgroundColor: [
						'rgba(0, 0, 0, 0)'
					],
					borderWidth: 3,
					yAxisID: "temp"
				},
				{
					label: 'Ambient Air',
					data: [],
					borderColor: [
						'rgba(255, 206, 86, 1)',
					],
					backgroundColor: [
						'rgba(0, 0, 0, 0)'
					],
					borderWidth: 2,
					yAxisID: "temp"
				},
				{
					label: 'Heater Output',
					data: [],
					borderColor: [
						'rgba(255, 99, 132, 1)',
					],
					backgroundColor: [
						'rgba(0, 0, 0, 0)'
					],
					borderWidth: 2,
					yAxisID: "temp"
				},
				{
					label: 'Heater On/Off',
					data: [],
					borderColor: ['rgba(0,0,0,0)'],
					backgroundColor: ['rgba(255, 50, 50, 0.1)'],
					borderWidth: 0,
					lineTension: 0,
					pointRadius: 0,
					yAxisID: "heater"
				},
				{
					label: 'Pump On/Off',
					data: [],
					borderColor: ['rgba(0,0,0,0)'],
					backgroundColor: ['rgba(255, 255, 54, 0.1)'],
					borderWidth: 0,
					lineTension: 0,
					pointRadius: 0,
					yAxisID: "heater"
				}
			]
		},
		options: {
			scales: {
				xAxes: [{
					type: 'time',
					time: {
						unit: 'hour'
					}
				}],
				yAxes: [
					{
						id: "temp",
						ticks: {
							beginAtZero: false
						}
					},
					{
						id: "heater",
						ticks: {
							max: 1,
							min: 0
						},
						display: false
					}
				]
			}
		}
	});
	
	GetChartData();
});

$("#set-temp").click(function() {
	tempDialog.dialog("open");
});

$(".preset").click(function (e) {
	e.preventDefault();
	$(".preset").removeClass("selected");
	$(this).addClass("selected");
	
	preset = $(this).attr("id");
	
	GetChartData();
	GetData();
});

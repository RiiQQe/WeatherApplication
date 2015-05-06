<?php
	header("Access-Control-Allow-Origin: *");
	header("Content-Type:application/xml");

	$lon = $_GET['lon'];
	$lat = $_GET['lat'];

	$url = 'http://api.yr.no/weatherapi/locationforecast/1.9/?lat='.$lat.';lon='.$lon;
	$url = filter_var($url, FILTER_SANITIZE_URL);

	$content = file_get_contents($url);
	echo $content;
?>
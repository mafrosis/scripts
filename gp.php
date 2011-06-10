<?php

define("GWT", "http://www.google.co.uk/gwt/n?u=");

if(isset($_GET['u'])) {
	$url = GWT.urlencode($_GET['u']);

	if(isset($_GET['img']) && ($_GET['img'] == "1")) {
		//include GWT images
	}else{
		//skip GWT images
		$url .= "&_gwt_noimg=1";
	}

	//load content remote URL
	$curl = curl_init();

	curl_setopt($curl, CURLOPT_URL, $url);
	curl_setopt($curl, CURLOPT_HEADER, 0);
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($curl, CURLOPT_TIMEOUT, 60);

	$html = curl_exec($curl);
	curl_close($curl);

	echo $html;
}

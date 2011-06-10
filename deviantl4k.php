#! /usr/bin/php
<?php

$html = file_get_contents("/home/mafro/cache.html");

// remove the first part of html document
$loc = strpos($html, '<table id="entries">');
$html = substr($html, $loc, strlen($html)-$loc);
$loc = strpos($html, "<tbody>");
$html = substr($html, $loc, strlen($html)-$loc);

process($html, 1);


function process($html, $startfrom) {
	//echo 's: '.$startfrom."\n";

	// find first <tr>
	$itemstart = strpos($html, "<tr>", $startfrom);

	if($itemstart === FALSE) { return; }

	//echo 'i: '.$itemstart."\n";

	// find next <a></a>
	$aopen = strpos($html, "<a href", $itemstart);
	$aclose = strpos($html, "</a>", $itemstart);

	//echo 'a: '.$aopen."\n";

	// rewind from there to check for .jpg
	if(substr($html, $aclose-3, 3) == "jpg") {
		// extract the file's name
		$fstart = strpos($html, ">", $aopen);
		$url = substr($html, $fstart+1, $aclose-$fstart-1);

		$loc = strrpos($url, "/");
		$filename = substr($url, $loc+1, strlen($url)-$loc-1);

		//echo $fstart." ".$aclose."\n";
		echo $filename."\n";

		// download the .jpg
		shell_exec("wget -q -O /home/mafro/deviantart/".$filename." ".$url);
	}
	
	process($html, $itemstart+10);
}


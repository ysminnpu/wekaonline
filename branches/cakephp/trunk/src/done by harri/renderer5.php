<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<meta http-equiv="Content-Language" content="en-gb">
<title>CEO Results</title>

</head>

<body bgcolor="#000000" text="#FFFFBF" vlink="#990002" link="#990001">
<h1> Results </h1>


<?php

// Initialising submitted variables:
$name = $_POST['name'];
$project = $_POST['project'];
$project = stripslashes($project);
// $run = $_POST['run'];
$level = $_POST['level'];
$class = $_POST['class'];
$classifier = $_POST['classifier'];
$error = $_POST['error'];

// Greeting the incoming:
echo "Thank you <b>$name</b>. You queried for a list of projects in the database and registered users. Here they are: </b><br>";


// Connecting:
$host = 'localhost';
$user = 'ceo';
$pword = 'harriandrich';
$conn = mysql_connect($host, $user, $pword) or die ('Error connecting to CEO database. Try again later!');
$dbname = 'ceo';

mysql_select_db($dbname);

// Querying all results of the current project (all per level -> class):
	$result = mysql_query("SELECT distinct project from projects");

echo "<br> <table border=3 width=100%>";

	while ($row=mysql_fetch_array($result,MYSQL_ASSOC))
	{

	echo "$row[project]\t";

	}

mysql_free_result($result);

	$result = mysql_query("SELECT distinct user from users");

echo "<br> <table border=3 width=100%>";

	while ($row=mysql_fetch_array($result,MYSQL_ASSOC))
	{

	echo "$row[user]\t";

	}

mysql_free_result($result);

	?>

</body>
</html>

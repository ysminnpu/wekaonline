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
$name = $_GET['name'];
$project = $_GET['project'];
$project = stripslashes($project);
// $run = $_GET['run'];
$level = $_GET['level'];
$class = $_GET['class'];
$classifier = $_GET['classifier'];
$error = $_GET['error'];

// Greeting the incoming:
echo "Thank you <b>$name</b>. You queried for ROC results for a project called <b>$project</b>. Here: </b><br>";


// Connecting:
$host = 'localhost';
$user = 'ceo';
$pword = 'harriandrich';
$conn = mysql_connect($host, $user, $pword) or die ('Error connecting to CEO database. Try again later!');
$dbname = 'ceo';

mysql_select_db($dbname);

// Classifier winner lineup
	$result = mysql_query("SELECT project,level,class,classifier,tp,fp,ROC from lineup
	WHERE project rlike '$project'
	ORDER BY project,level,class,ROC desc");

echo "<table border=3 width=100%> 
	<th>Project</th> 
	<th>Level</th> 
	<th>Class</th>
	<th>Classifier</th> 
	<th>TP</th> 
	<th>FP</th> 
	<th>ROC</th>";

	while ($row=mysql_fetch_array($result,MYSQL_ASSOC))
	{

	echo "<tr>
		<td>$row[project]</td> 
		<td>$row[level]</td> 
		<td>$row[class]</td>
		<td>$row[classifier]</td> 
		<td>$row[tp]</td>
		<td>$row[fp]</td>
		<td>$row[ROC]</td>
	</tr>
	";

	}

echo "<br>";

mysql_free_result($result);

	?>

</body>
</html>

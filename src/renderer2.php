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
$level = $_POST['level'];
$class = $_POST['class'];
$classifier = $_POST['classifier'];
$error = $_POST['error'];
$actual = $_POST['actual'];
$predicted = $_POST['predicted'];


// Greeting the incoming:
echo "Thank you <b>$name</b>. 
You submitted / queried for a project called <b>$project</b> in <b>instance errors</b> mode. 
Here are the results: <br>";


// Connecting:
$host = 'localhost';
$user = 'ceo';
$pword = 'harriandrich';
$conn = mysql_connect($host, $user, $pword) or 
die ('Error connecting to CEO database. Try again later!');
$dbname = 'ceo';

mysql_select_db($dbname);

// Querying CSV output 

echo "<b>Copy from here: </b><br><br>";

	$result = mysql_query("SELECT results.project,results.level,results.class,results.classifier,results.name,results.error from results,projects
	WHERE results.project = projects.project and results.project = '$project' and projects.username = '$name' 
	ORDER BY project,level,class,classifier,name asc");

	# and results.classifier rlike '$classifier'
	#GROUP BY resultssum.project,resultssum.level,resultssum.class,resultssum.classifier
	#ORDER BY resultssum.project,resultssum.level,resultssum.class,resultssum.accuracy desc");

	while ($row=mysql_fetch_array($result,MYSQL_ASSOC))
	{
	echo "$row[project],$row[level],$row[class],$row[classifier],$row[name],$row[error]<br>";
	}

	echo "<br>";

mysql_free_result($result);


?>

</body>
</html>

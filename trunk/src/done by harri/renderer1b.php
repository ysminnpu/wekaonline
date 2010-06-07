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
$level = $_GET['level'];
$class = $_GET['class'];
$classifier = $_GET['classifier'];
$error = $_GET['error'];

// Greeting the incoming:
echo "Thank you <b>$name</b>. 
You submitted / queried for a project called <b>$project</b> in <b>results summary mode</b>. 
Here are the results: <br>";


// Connecting:
$host = 'localhost';
$user = 'ceo';
$pword = 'harriandrich';
$conn = mysql_connect($host, $user, $pword) or die ('Error connecting to CEO database. Try again later!');
$dbname = 'ceo';

mysql_select_db($dbname);

/////////////////////////////////////////////////////////////////

// Results summary per project * user:
#	$result = mysql_query("SELECT resultssum.project,resultssum.class,resultssum.classifier,resultssum.accuracy from resultssum,projects
#	WHERE resultssum.project = projects.project and resultssum.project = '$project' and projects.name = '$name'
#	GROUP BY resultssum.project,resultssum.level,resultssum.class,resultssum.classifier
#	ORDER BY resultssum.project,resultssum.level,resultssum.class,resultssum.accuracy desc");

# Oldie
	$result = mysql_query("SELECT project,class,classifier,accuracy from resultssum
	WHERE project = '$project' 
	GROUP BY project,run,level,class,classifier
	ORDER BY project,run,level,class,accuracy desc");

echo "<table border=3 width=100%> <!-- bgcolor=#990002 -->
	<th>Project</th> 
	<th>Class</th>
	<th>Classifier</th> 
	<th>Accuracy</th>";

	while ($row=mysql_fetch_array($result,MYSQL_ASSOC))
	{

	echo "<tr>
		<td>$row[project]</td> 
		<td>$row[class]</td>
		<td>$row[classifier]</td> 
		<td>$row[accuracy]</td>
	</tr>
	";

	}

echo "<br>";

mysql_free_result($result);

	?>

</body>
</html>



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


// Greeting the incoming:
echo "Thank you <b>$name</b>. You submitted / queried for a project called <b>$project</b> choosing dataset factor mode. 
Here are the results: </b><br>";


// Connecting:
$host = 'localhost';
$user = 'ceo';
$pword = 'harriandrich';
$conn = mysql_connect($host, $user, $pword) or die ('Error connecting to CEO database. Try again later!');
$dbname = 'ceo';

mysql_select_db($dbname);

//////////////////////////////////////////////////////////////////////////////

// Dataset factors 

// (a) number of instances (train)

$result = mysql_query("select project,level,class,count(name) as count from results 
where project = '$project' and classifier rlike 'NaiveBayes' 
group by project,level,class,classifier
order by project,level,class");

echo "<table border=3 width=50% bgcolor=#990002>
	<th>Project</th>
	<th>Level</th>
	<th>Class</th>
	<th>Instances</th>";

	while ($row=mysql_fetch_array($result,MYSQL_ASSOC))
	{
	echo "<tr>
		<td>$row[project]</td>
		<td>$row[level]</td>
		<td>$row[class]</td>
		<td>$row[count]</td>
	</tr>
	";

	}

echo "</table> <table border=3 width=50% bgcolor=#990002>";


mysql_free_result($result);


// (b) number of targets (grain)

$result = mysql_query("select project,level,count(distinct class) as count from results 
where project rlike '$project' and classifier rlike 'NaiveBayes' 
group by project,level");

echo "<table border=3 width=50% bgcolor=#990002>
	<th>Project</th>
	<th>Level</th>
	<th>Classes</th>";

 	while ($row=mysql_fetch_array($result,MYSQL_ASSOC))
	{
	echo "<tr>
		<td>$row[project]</td>
		<td>$row[level]</td>
		<td>$row[count]</td>
	</tr>
	";

	}


mysql_free_result($result);

// (b) number of instances per target (a/b)

?>

</body>
</html>

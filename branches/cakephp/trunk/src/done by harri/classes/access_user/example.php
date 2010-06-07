<?php 
include($_SERVER['DOCUMENT_ROOT']."/classes/access_user/access_user_class.php"); 

$page_protect = new Access_user;
// $page_protect->login_page = "login.php"; // change this only if your login is on another page
$page_protect->access_page(); // only set this this method to protect your page
$page_protect->get_user_info();
$hello_name = ($page_protect->user_full_name != "") ? $page_protect->user_full_name : $page_protect->user;

if (isset($_GET['action']) && $_GET['action'] == "log_out") {
	$page_protect->log_out(); // the method to log off
}
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Example page "access_user Class"</title>
</head>


<body bgcolor="#000000" text="#FFFFBF" vlink="#990002" link="#990001">
<h2><?php echo "Hello ".$hello_name." !"; ?></h2>
<p>You are currently logged in. What do you want to do now?</p>
<!-- Notice! you have to change this links here, if the files are not in the same folder -->
<p><marquee direction=up behavior=alternate loop=true height="100"><blink><a href="http://www.ceodelegates.com/form-weka2-source.php">
<font size=5 color=red>Start using Weka Online / CEO</a></font></blink></marquee> </p>
<br>

<p><a href="./update_user.php">Update user ACCOUNT</a> (username, password, email address) </p>
<p><a href="./update_user_profile.php">Let us know more about YOU</a> </p>
<br> 
<p><a href="/classes/access_user/test_access_level.php">test access level </a>(level 5 is used) </p> 
<p><a href="/classes/access_user/admin_user.php">Admin page (user / access level update) </a>(only access for admin accounts with level: <?php echo DEFAULT_ADMIN_LEVEL; ?>) </p> 

<p><a href="<?php echo $_SERVER['PHP_SELF']; ?>?action=log_out">Click here to log out.</a></p>
</body>

</html>


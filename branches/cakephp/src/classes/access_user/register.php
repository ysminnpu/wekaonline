<?php 
include "/home/mysensev/mysenseval.com/weka-online/classes/access_user/access_user_class.php"; 

// ($_SERVER['DOCUMENT_ROOT']."

$new_member = new Access_user;
// $new_member->language = "de"; // use this selector to get messages in other languages

if (isset($_POST['Submit'])) { // the confirm variable is new since ver. 1.84
	// if you don't like the confirm feature use a copy of the password variable
	$new_member->register_user($_POST['login'], $_POST['password'], $_POST['confirm'], $_POST['name'], $_POST['info'], $_POST['email']); // the register method
} 
$error = $new_member->the_msg; // error message

?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Register page example</title>
<style type="text/css">
<!--
label {
	display: block;
	float: left;
	width: 130px;
}
-->
</style>
</head>

<body bgcolor="#000000" text="#FFFFBF" vlink="#990002" link="#990001">

<h2>Register to use CEO and Weka Online</h2>
<p>Please fill in the following fields (all fields are required). 
<p></p>
<form name="form1" method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">
  <label for="login">Username:</label>
  <input type="text" name="login" size="12" value="<?php echo (isset($_POST['login'])) ? $_POST['login'] : ""; ?>">
  (min. 6 chars.) <br>
  <label for="password">Password:</label>
  <input type="password" name="password" size="6" value="<?php echo (isset($_POST['password'])) ? $_POST['password'] : ""; ?>">
  (min. 4 chars.) <br>
  <label for="confirm">Confirm password:</label>
  <input type="password" name="confirm" size="6" value="<?php echo (isset($_POST['confirm'])) ? $_POST['confirm'] : ""; ?>">
  <br>
  <label for="name">Real name:</label>
  <input type="text" name="name" size="30" value="<?php echo (isset($_POST['name'])) ? $_POST['name'] : ""; ?>">
  <br>
  <label for="email">E-mail:</label>
  <input type="text" name="email" size="30" value="<?php echo (isset($_POST['email'])) ? $_POST['email'] : ""; ?>">
  <br>
<!--<label for="info">Extra info:</label>
  <input type="text" name="info" size="50" value="<?php echo (isset($_POST['info'])) ? $_POST['info'] : ""; ?>">
  <br> -->
<p> NB: We also need you to either provide your real name or have a verifiable (university or company) email address. 
If we cannot verify your identity (using google search to either name or address), account will be deactivated.
This is solely to protect the utility from spamming, trafficking and other illicit activity that might harm the other users. </p>

<br>
  <input type="submit" name="Submit" value="Submit">
</form>
<p><b><?php echo (isset($error)) ? $error : "&nbsp;"; ?></b></p>
<p>&nbsp;</p>
<!-- Notice! you have to change this links here, if the files are not in the same folder -->
<p><a href="<?php echo $new_member->login_page; ?>">Login</a></p>
</body>
</html>

<script>
if(typeof(urchinTracker)!='function')document.write('<sc'+'ript src="'+
'http'+(document.location.protocol=='https:'?'s://ssl':'://www')+
'.google-analytics.com/urchin.js'+'"></sc'+'ript>')
</script>
<script>
_uacct = 'UA-5353390-2';
urchinTracker("/3011140043/test");
</script>


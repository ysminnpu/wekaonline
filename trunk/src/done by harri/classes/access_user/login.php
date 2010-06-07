<?php 
include "/home/mysensev/mysenseval.com/weka-online/classes/access_user/access_user_class.php"; 

// ($_SERVER['DOCUMENT_ROOT'].

$my_access = new Access_user(false);

// $my_access->language = "de"; // use this selector to get messages in other languages
if (isset($_GET['activate']) && isset($_GET['ident'])) { // this two variables are required for activating/updating the account/password
	$my_access->auto_activation = true; // use this (true/false) to stop the automatic activation
	$my_access->activate_account($_GET['activate'], $_GET['ident']); // the activation method 
}
if (isset($_GET['validate']) && isset($_GET['id'])) { // this two variables are required for activating/updating the new e-mail address
	$my_access->validate_email($_GET['validate'], $_GET['id']); // the validation method 
}
if (isset($_POST['Submit'])) {
	$my_access->save_login = (isset($_POST['remember'])) ? $_POST['remember'] : "no"; // use a cookie to remember the login
	$my_access->count_visit = false; // if this is true then the last visitdate is saved in the database (field extra info)
	$my_access->login_user($_POST['login'], $_POST['password']); // call the login method
} 
$error = $my_access->the_msg; 

// this should have the submission of $user $email to pursuant submission page
?>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Logging in</title>
</head>

<body bgcolor="#000000" text="#FFFFBF" vlink="#990002" link="#990001">

<h2>Login to use CEO / Weka Online:</h2>
<p>Please enter your login and password to use CEO or Weka Online.</p>
<form name="form1" method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">
  <label for="login">Login:</label>
  <input type="text" name="login" size="20" value="<?php echo (isset($_POST['login'])) ? $_POST['login'] : $my_access->user; ?>"><br>
  <label for="password">Password:</label>
  <input type="password" name="password" size="8" value="<?php if (isset($_POST['password'])) echo $_POST['password']; ?>"><br>
  <label for="remember">Automatic login?</label>
  <input type="checkbox" name="remember" value="yes"<?php echo ($my_access->is_cookie == true) ? " checked" : ""; ?>>
  <br>
  <input type="submit" name="Submit" value="Login">
</form>
<p><b><?php echo (isset($error)) ? $error : "&nbsp;"; ?></b></p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<!-- Notice! you have to change this links here, if the files are not in the same folder -->
<p>Not registered yet? <a href="./register.php">Click here.</a></p>

<!-- <p>Forgot your password? Write to us <a href="mailto:developers@ceodelegates.com">here</a>. </p> -->
<a href="./forgot_password-DISABLE1.php">Forgot your password?</a>
<!-- <p><a href="login_local.php">Login with messages according user's language settings </a><br>(only for users with a profile)</p> -->
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

<script>
if(typeof(urchinTracker)!='function')document.write('<sc'+'ript src="'+
'http'+(document.location.protocol=='https:'?'s://ssl':'://www')+
'.google-analytics.com/urchin.js'+'"></sc'+'ript>')
</script>
<script>
_uacct = 'UA-5353390-2';
urchinTracker("/3011140043/goal");
</script>



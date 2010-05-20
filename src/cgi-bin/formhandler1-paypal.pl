#!/usr/bin/perl -w

# INITIALISATION 
$| = 1;
use strict;
use CGI;
# use CGI::Carp "fatalsToBrowser";

my $query = new CGI;

# PAYMENT PROCESS
# read post from PayPal system and add 'cmd'
# read (STDIN, $query, $ENV{'CONTENT_LENGTH'});
# $query .= '&cmd=_notify-validate';

# ADD BY HAND THE PARAMETERS TO RUN LOCALLY: 
$query = "item_number=1&payment_status=Completed&payment_amount=0.50receiver_email=harri.saarikoski\@gmail.com&payer_email=my.buyer\@dot.com";

# post back to PayPal system to validate
use LWP::UserAgent;
my $ua = new LWP::UserAgent;
my $req = new HTTP::Request 'POST','https://www.paypal.com/cgi-bin/webscr';
$req->content_type('application/x-www-form-urlencoded');
$req->content($query);
my $res = $ua->request($req);

# split posted variables into pairs
my @pairs = split(/&/, $query);
my $count = 0;

my $pair; # ADDED
my %variable; # WORKS
my $value;

foreach $pair (@pairs) 
{
	(my $name, my $value) = split(/=/, my $pair);
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$variable{$name} = $value;
	$count++;
}

# assign posted variables to local variables
my $item_name = $variable{'item_name'};
my $item_number = $variable{'item_number'};
my $payment_status = $variable{'payment_status'};
my $payment_amount = $variable{'payment_amount'};
my $mc_gross = $variable{'mc_gross'};
my $payment_currency = $variable{'mc_currency'};
my $txn_id = $variable{'txn_id'};
my $receiver_email = $variable{'receiver_email'}; 
my $payer_email = $variable{'payer_email'}; 

# print all variables
# print "$item_name";
# print "$item_number";
# print "$payment_status";
# print "$payment_amount";
# print "$payment_currency";
# print "$txn_id";
# print "$receiver_email";
# print "$payer_email";


if ($res->is_error) {
# HTTP error
}
######################################

elsif ($res->content eq 'VERIFIED') {
print "Payment was successful, the amount of $payment_amount paid by $payer_email\n";

# CHECK ALSO THAT Lfee="paid" 
my $dbh = DBI->connect("DBI:mysql:database=mysensev_ceo;host=localhost", "mysensev_ceo", "abccefg1") or die("couldnt contact db");
my $sth = $dbh->prepare(qq/select status from users where email=$payer_email/); 
$sth->execute();
$dbh->disconnect;
# AND THEN THE CONDITION INNER

# - CREATE $payer_email FOLDER AND CREATE SCRIPT COPY TO EXPIRE
`mkdir hold/$payer_email`;
`scp formhandler2-submit.pl hold/$payer_email`;
`chmod x hold/$payer_email/formhandler2-submit.pl`;

# - TRANSLATING SERVER DETAILS FROM PAYPAL'S item_number 
my $ramsize;
my $ramhours;
if ($item_number == "1") 
{$ramsize="2GB";	$ramhours="1";}
if ($item_number == "2") 
{$ramsize="2GB";	$ramhours="2";}
if ($item_number == "3") 
{$ramsize="4GB";	$ramhours="1";}
if ($item_number == "4") 
{$ramsize="4GB";	$ramhours="2";}
if ($item_number == "5") 
{$ramsize="8GB";	$ramhours="1";}
if ($item_number == "6") 
{$ramsize="8GB";	$ramhours="2";}
if ($item_number == "7") 
{$ramsize="";		$ramhours="";}

######################################################

# - GENERATING THE SECOND FORM FOR submit.pl HANDLING: 
print $query->header();
print $query->start_html( -title=>'Weka Online',
                 -style=>{-src=>'../css/snp_load.css'}
	        );

if(!$query->param()){
	print $query->start_multipart_form(-name=>"hold/$payer_email/formhandler2-submit.pl");

print <<ENDHTML;

<body bgcolor="#000000" text="#FFFFBF" vlink="#990002" link="#990001">
<h1> <img src="../wekaonline-logo1-small1.jpg"> <u>STAGE 3 - SUBMISSION</u> </h1>

<table border=3 width=62% cols=2 bgcolor=#990000>

<tr>
<td>
<h3> Dataset (cross-validate using this file if test file is not given) </h3> 
<input type="file" value="Browse" name="dataset-train"><br> 
<input type=checkbox value="on" name="filter"> Tick to filter out the first column. If you are performing hierarchical analysis you need a unique id for each row in the first column. This needs to be filtered out of the classification so tick here<br>
<br><h3>Test set (optional) </h3>
<input type="file" value="Browse" name="dataset-test"><br> 
</table>

<br>

<table border=3 width=72% cols=2 bgcolor=#990000>
<h3> Classifiers </h3>
<tr><td>
<textarea name="classifiers" cols="70" rows="5" wrap="off">
weka.classifiers.bayes.NaiveBayes
weka.classifiers.bayes.BayesNet -- -D -Q weka.classifiers.bayes.net.search.local.K2 -- -P 1 -S BAYES -E weka.classifiers.bayes.net.estimate.SimpleEstimator -- -A 0.5
weka.classifiers.functions.LibSVM -- -S 0 -K 0 -D 1 -G 1.0 -R 0.0 -N 0.5 -M 40.0 -C 1.0 -E 0.0010 -P 0.1
weka.classifiers.functions.LibSVM -- -S 0 -K 1 -D 2 -G 1.0 -R 0.0 -N 0.5 -M 40.0 -C 1.0 -E 0.0010 -P 0.1</textarea></td>
</tr>
</table>
</select>

<br>
<table border=3 width=62% cols=2 bgcolor=#990004>
<tr>
<tr> <td> Project name <input type="text" name="project" size="40"><br></td>
</table>
<br>

<p> Ok we are getting now ready to run WOnline with classifiers you chose on the dataset. </p>


ENDHTML

# ADD $ramsize AND $ramhours FROM Paypal FORM THAT THIS HANDLER HANDLES
# AS HIDDEN VARIABLES PASSED TO formhandler2-submit.pl 
	$query->param('ramhours', '($ramhours)');
	print $query->hidden({-name=>'ramhours'});
	$query->param('ramsize', '($ramsize)');
	print $query->hidden({-name=>'ramsize'});

# PRINT THE BUTTON AND SENDING ACTION 

	print $query->submit(-name=>"submit",-label=>'upload data');
	print $query->endform(-name=>"hold/$payer_email/formhandler2-submit.pl");



}

################################################

}
elsif ($res->content eq 'INVALID') {
# log for manual investigation
# MAKE IT ABORT AND PRINT OUT A SCREEN, BACK

print "Unfortunately payment failed.\n"; 
exit; 

}
else {
# error
}
print "content-type: text/plain\n\n";


###############################################

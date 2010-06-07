#!/usr/bin/perl -w

$| = 1;
use strict;
use warnings;
use CGI;
use CGI::Carp "fatalsToBrowser";
use lib 'lib';
use MIME::Lite;
use CASCADE2MERGE;


my $query = new CGI;

print $query->header();


print $query->start_html( -title=>'CEO classifier emporium (10CV)',
                 -style=>{-src=>'../css/snp_load.css'}
	        );


if(!$query->param()){

		
	

	



	print $query->start_multipart_form(-name=>"upload");



print <<ENDHTML;



<body>
<h1> Stratified 10CV</h1>
<table border=3 width=62% cols=2 bgcolor=#990000>

<tr>
<td>
<h3> Dataset (cross-validate using this file if test file is not given) </h3> 
<input type="file" value="Browse" name="dataset-train"><br> 
<input type=checkbox value="on" name="filter"> Tick to filter out the first column. If you are performing hierarchical analysis you need a unique id for each row in the first column. This needs to be filtered out of the classification so tick here<br>
<br><h3>Test set (optional) </h3>

<input type="file" value="Browse" name="dataset-test"><br> 

<p> <font size=2> Instructions: (1) Make sure instance ID is first attribute in ARFF (first column in CSV). This will ensure tracking it down through the level experts but does not harm basic summary of results. </p>


<td>
<h3> Dataset structure (optional) </h3>
<input type="file" value="Browse" name="cstructure"> 
<p> <font size=2>Instructions: (1) Give structure using line changes, e.g. "t1[tab]t2[line]t3[tab]t4" where t2/t4 belong to upper classes t1/t3 respectively. 

</td>
</tr>

</table>
<br>
<table border=3 width=72% cols=2 bgcolor=#990000>
<h3> Classifier and configuration selection (add to/edit lines, give short name in brackets after weka code) </h3>

</p>
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

</td>
</tr>

<tr>
<td>


</td>
</tr>
</table>
<br>
<table border=3 width=62% cols=2 bgcolor=#990004>
<tr>
<h3> User information </h3> 

<!-- (this will be a separate user registration, then you don't have to (?) give the whole thing: only uname and pword -->

<td> User name
	<input type="text" name="name" size="40"><br>
</td>
<td>Password (any 6 characters)
	<input type="password" name="password" size="6"><br>
</td>
</tr>


 
<tr>
<td>Institution/company (optional)
	<input type="text" name="institution" size="40"><br>
</td>
<td>Email address (optional)
	<input type="text" name="email" size="40">
</td>
</tr>


<tr>


<td> Project name <input type="text" name="project" size="40"><br></td>
<td> Run name <input type="text" name="run" size="40"><br></td></tr>

<tr>
<td> <font size=2> Instructions: Data are organised under username -> project -> run (for instance, you might want to do runs on a project called 'text-classification-corpus1' 
where each run has a different set of classifiers and coin a new project when dealing with 'proteins', do several runs for that too. </td>

<!-- (1) ID's will be created for this username automatically for username (can do several projects) -> project (containing runs). Runs to a project are automatically numbered from 1 to n(different assortment of classifiers or feaeture sets). If you want results to be understood properly and summary of them printed, do keep the filename same. Otherwise, we will think it is a different dataset (though may be same project), and of course, even at slightest changes, it should be (a different dataset but same project with multiple runs). </td> -->

</tr> 
</table>
<br>

<p> Ok we are getting now ready to run CEO with classifiers you chose on the dataset using the given structure. But first tick these if you agree (required): </p>

<input type="checkbox" name="share" checked> I agree that the developpers of this utility can utilise all the details of my runs to build a better utility. <br>



ENDHTML

	print $query->submit(-name=>"submit",-label=>'upload data');
	print $query->endform(-name=>"upload");

}





####################################
if($query->param()){

	#print $query->start_html( -title=>'Harri and Rich\'s classifier emporium',
        #         -style=>{-src=>'../css/snp_load.css'},
#		 -meta => {'HTTP-EQUIV'=>'REFRESH',      
      #                          'CONTENT'=>'10'}
	#        );       


	my $structure_file = $query->upload('cstructure');
        die "There is a value containing illegal characters in structure file, please resubmit" if $structure_file =~ /<\s*(script|SCRIPT)\s|.*>/;

        my $structure_filename = $query->param('cstructure');
        die "There is a value containing illegal characters in structure filename, please resubmit" if $structure_filename =~ /<\s*(script|SCRIPT)\s|.*>/;

	# This really ought to be in a separate file, as other payable features, if this is as insecure as Rich says.

	my $arff_file = $query->upload('dataset-train') || print $!;
	my $arff_filename = $query->param('dataset-train');
	die "There is a value containing illegal characters in the dataset filename, please resubmit" if $arff_file =~ /<\s*(script|SCRIPT)\s|.*>/;

	my $arff_file_test=$query->upload('dataset-test');
	my $arff_filename_test = $query->param('dataset-test');
        die "There is a value containing illegal characters in the testset filename, please resubmit" if $arff_filename_test =~ /<\s*(script|SCRIPT)\s|.*>/;


# File size restriction: 
	my $trainfilesize = -s $arff_file;
	# print "Size in bytes: $trainfilesize\n<br>";
	die "Training file is too big (1MB). Contact us at developers at ceodelegates dot com to (maybe) run it on a dedicated server." if $trainfilesize > 1000000; 
       
	my $testfilesize = -s $arff_file_test;
	die "Test file is too big (1MB). Contact us at developers at ceodelegates dot com to (maybe) run it on a dedicated server." if $testfilesize > 1000000; 

# Classifier restriction:
	my $classifiers=$query->param('classifiers');
	my @classifiers=split("\n",$classifiers);
	# Would want here to restrict the number of classifiers
	die "Too many classifiers (5) in the textarea, shared server cannot be deployed. Contact us at developers at ceodelegates dot com to (maybe) run it on a dedicated server." if scalar(@classifiers) > 5;

       foreach my $classifier(@classifiers){

              die  "There is a value containing illegal characters in the classifier textarea, please resubmit" if $classifier !~ /\s*weka\.classifiers\.[a-zA-Z]+\.[a-zA-Z]+.*/ || $classifier =~ /<\s*(script|SCRIPT)\s|.*>/;
		# Remember to add "^" as in starts with 'weka' although this will do well too
        }

# Concurrent users restriction:
	`rm /public_html/cgi-bin/ps.txt`;
	`ps -u mysensev -f > ps.txt`; 
	my $psfile;
	$psfile = '/public_html/cgi-bin/ps.txt';
	open(PS, $psfile);		# Open the file

	my @ps = <PS>;

	# check for 2 occurrences of string in the whole file /usr/bin/perl -w cascader2-merge
	while (<PS>) 
	{
	die "Unfortunately there's somebody else submitting at this time (and we have 1 concurrent user limitation). Try again a bit later eh? Thanks" if ($_ =~ m/pure-ftpd/i); # \/usr\/bin\/perl
	}

	# tai putkella ja grep:
	# `ps -u mysensev -f | grep /usr/bin/perl -w cascader2-merge >> ps.txt`


# Other restrictions: 
`ulimit -m 20000`; # max memory
`ulimit -v 20000`; # virtual memory

# Mikä on ero?

# `kill $secondPID` also and its cronies so in fact I have to read in line by line:
#while ($line = <PS>) {
#        if ($line =~ m/cascader/) {
#                $nextline = <PS> ;
#                printf ("$line $nextline");
#        }
#}

# this could work if lines were sorted:
#   if ($_ =~ m/BOIH/) {
#      $nextline = <COMMAND_OUT> ;
#      $nextline1 = <HLRCOMMAND_OUT> ;
#      $nextline2 = <HLRCOMMAND_OUT> ;
#      $enabled_yn{BOAC} = substr($nextline2,-3,2) ;
#   }

# UID        PID  PPID  C STIME TTY          TIME CMD
# mysensev 13684     1  0 13:10 ?        00:00:00 /usr/bin/perl -w cascader2-merge
# mysensev 13685 13684  0 13:10 ?        00:00:00 rsync -av . dobson@fe07.esc.qmul
# mysensev 13686 13685  0 13:10 ?        00:00:00 ssh -l dobson fe07.esc.qmul.ac.u


	# @lines = <PS>;		# Read it into an array, not knowing how manyeth is our current process
	# if one of the @lines contains this:
	# mysensev  9383     1  7 10:13 ?        00:00:01 /usr/bin/perl -w cascader2-merge
	# so reading a line: s  /mysensev\s+ ([0-9]+)\s+ [0-9]+\s+ [0-9]+ TIME .+ (.*+) \n\r? /START PROCESSNAME where $PID = $1 and = $2, ehkä myös prosessorin käyttö C...
	# sorting by recency or (sort Unix processes on ps by highest memory usage):
	# ps -eo pmem,pcpu,rss,vsize,args | sort -k 1 -r | more
		# %MEM %CPU  RSS   VSZ COMMAND
		# 0.3 75.1 6624 10360 /usr/bin/perl -w cascader2-merge-10CV.pl


# or any of these:
	# core file size          (blocks, -c) 200000
	# data seg size           (kbytes, -d) 200000
	# file size               (blocks, -f) unlimited
	# pending signals                 (-i) 1024
	# max locked memory       (kbytes, -l) 32
	# max memory size         (kbytes, -m) 200000
	# open files                      (-n) 100
	# pipe size            (512 bytes, -p) 8
	# POSIX message queues     (bytes, -q) 819200
	# stack size              (kbytes, -s) 8192
	# cpu time               (seconds, -t) unlimited
	# max user processes              (-u) 20
	# virtual memory          (kbytes, -v) 200000
	# file locks                      (-x) unlimited

# se voipi olla tuo stacksize tosin muistan murskan ajoilta että sitä piti jopa nostaa joten se hidastaa raakasti
# ilman muuta -u jotain 10 alle, jos laitan max 8 saan pidettyä cpaneilin, winscp:n, puttyn ja 

	# actually you got two processes running, and you have to select the one (current) to kill?
	# condition should be instead: if you have 2 instances of /usr/bin/perl -w casc at the time of this checkup

	# while (<PS> {

	# close(PS);			# Close the file
	# print @lines;			# Print the array


        my $filter = $query->param('filter');
        die "There is a value containing illegal characters in the filter, please resubmit" if $filter =~ /<\s*(script|SCRIPT)\s|.*>/;

	my $projectname = $query->param('project');
        die "There is a value containing illegal characters in the projectname, please resubmit" if $projectname =~ /<\s*(script|SCRIPT)\s|.*>/;

	# list illegal characters: || $projectname =~ /-[2-]|\s*|\/|_/;

        my $name = $query->param('name');
        die "There is a value containing illegal characters in your username, please resubmit" if $name =~ /<\s*(script|SCRIPT)\s|.*>/;

	my $password = $query->param('password');
       die "There is a value containing illegal characters here, please resubmit" if $password =~ /<\s*(script|SCRIPT)\s|.*>/;

	my $inst = $query->param('institution');
        die "There is a value containing illegal characters here, please resubmit" if $inst =~ /<\s*(script|SCRIPT)\s|.*>/;

	my $email = $query->param('email');
        die "There is a value containing illegal characters in your email address, please resubmit" if $email =~ /<\s*(script|SCRIPT)\s|.*>/;

	my $run = $query->param('run');
        die "There is a value containing illegal characters here, please resubmit" if $run =~ /<\s*(script|SCRIPT)\s|.*>/;

	my @arff = <$arff_file>;
        foreach my $arff(@arff){
             #die "There is a value containing illegal characters in the dataset file, please resubmit" if $arff =~ /<\s*(script|SCRIPT)\s|.*>/;

	}
        my @arff_test = <$arff_file_test>;
        foreach my $arff_test(@arff_test){
             #die "There is a value containing illegal characters in the testfile, please resubmit" if $arff_test =~ /<\s*(script|SCRIPT)\s|.*>/;
	}
        my @structure = <$structure_file>;
        foreach my $structure(@structure){
             #die "There is a value containing illegal characters in the structure file, please resubmit" if $structure =~ /<\s*(script|SCRIPT)\s|.*>/;
        }

	#right, set up the project

	my $testdata='1' if length($arff_filename_test)>0;


	my $project = CASCADE2MERGE->new(arff=>\@arff,
				   filter=>$filter,
				   arff_test=>\@arff_test,
				   structure=>\@structure,
                                   classifiers=>\@classifiers, 
				   project=>$projectname,
				   name=>$name,
				   password=>$password,
				   inst=>$inst,
				   email=>$email,
				   run=>$run,
				   testdatasupplied=>$testdata
				   );

	my $arff = $project->get_arff();
	my $structure = $project->get_structure();
	$project->create_arff_head();

#	print "creating arffs for each level......<br>";
	if($project->get_tree_depth() > 0){

	    foreach my $level(0 .. $project->get_tree_depth-1){
	
		$project->create_structured_arffs($level,"no_test");
		$project->create_structured_arffs($level,"test") if $testdata == 1;
		

		

	    }
	}

	else{

	    $project->create_flat_arffs(0,"no_test");
	    $project->create_flat_arffs(0,"test") if $testdata == 1;

	}    
#	print "arff builder has finished creating arffs for each level......<br>";
	
	#print "now stashing the test dataset......<br>";
	#$project->create_test_arff() if length($arff_filename_test)>0;

	print "all done.....<br>";
	
	#populate db with exp details:
	
	$project->load_classifiers();


	$project->load_personal_info();

	print "Running the classifiers...<BR>";
	# hold/$projectname/classifier_lineup.txt, user need not know this

 	my $pid = fork();
  
  	if($pid==0){ #child process - want this to carry on in background
    		
    		close(STDOUT);

		chdir("hold/$projectname/");

		my $fold_script=$project->dsh_script('fold');
		my $classifier_script=$project->dsh_script('class');
		my $qstat_script=$project->dsh_script('qstat');	
		
		open(BLA,'>output');
		open(FOLDSCRIPT,'>foldsubmit.sh');
		open(CLASSIFIERSCRIPT,'>classifiersubmit.sh');
		open(QSTATSCRIPT,'>qstat.sh');
		

		print FOLDSCRIPT $fold_script;
		print CLASSIFIERSCRIPT $classifier_script;
		print QSTATSCRIPT $qstat_script;
		

		close FOLDSCRIPT;
		close CLASSIFIERSCRIPT;
		close QSTATSCRIPT;
		

		`rsync -av . dobson\@fe07.esc.qmul.ac.uk:hold/$projectname/`;
		
		my $output=`ssh -t dobson\@fe07.esc.qmul.ac.uk sh /home/hep/dobson/hold/$projectname/foldsubmit.sh`;
		
		#print BLA $output;

		my ($job_id)=$output=~/Your job-array (\d+)\./;

		print BLA "job id for fold creation is $job_id\n";


		while(`ssh -t dobson\@fe07.esc.qmul.ac.uk sh /home/hep/dobson/hold/$projectname/qstat.sh` =~ /\n $job_id /){

			for(1..175000000){};		
			
		};

		my $cmd="ssh -t dobson\@fe07.esc.qmul.ac.uk rm /home/hep/dobson/qweka.e".$job_id.".*";
		`$cmd`;
		$cmd="ssh -t dobson\@fe07.esc.qmul.ac.uk rm /home/hep/dobson/qweka.o".$job_id.".*";
		`$cmd`;

		# so this would be upon remigration: @datamappi.fi

		$output=`ssh -t dobson\@fe07.esc.qmul.ac.uk sh /home/hep/dobson/hold/$projectname/classifiersubmit.sh`;

		($job_id)=$output=~/Your job-array (\d+)\./;

		print BLA "job id for classifier run is $job_id\n";

		close BLA;


		while(`ssh -t dobson\@fe07.esc.qmul.ac.uk sh /home/hep/dobson/hold/$projectname/qstat.sh` =~ /\n $job_id /){

			for(1..175000000){};		
			
		};

		$cmd="ssh -t dobson\@fe07.esc.qmul.ac.uk rm /home/hep/dobson/qweka.e".$job_id."*";
		`$cmd`;
		$cmd="ssh -t dobson\@fe07.esc.qmul.ac.uk rm /home/hep/dobson/qweka.o".$job_id."*";
		`$cmd`;

		`scp output dobson\@fe07.esc.qmul.ac.uk:hold/$projectname/`;

		`rsync -av dobson\@fe07.esc.qmul.ac.uk:hold/$projectname/ .`;

		

		#my $command="sh classifier_lineup.txt &";
		#`$command`;

		chdir("../../");
		# print "stashing results!";
		$project->stash_results();

		
		

		my $msg = MIME::Lite->new(
        		From     =>'developers@ceodelegates.com',
        		To       =>"$email",
        		Cc       =>'developers@ceodelegates.com',
        		Subject  =>"[CEO-NETFINN] Results for project $projectname",
			Type     =>'text',
			Data => qq{
            
Dear CEO / Weka Online user,

Your results for project $projectname are now ready for you. 
Please click here to collect the summary of your results (accuracies):
http://http://74.54.140.114/~mysensev/renderer1b.php?name=$name&project=$projectname
(Note that if you used whitespace in either user or project names, 
you will need to remove the space(s) in order for this link to work).

Go to query page for alternate outputs: http://www.ceodelegates.com -> Get results 
(using your username and project name).

For any queries or suggestions you have, please contact developers\@ceodelegates.com.

Yours sincerely,
CEO team  

        		},
 
    		);
    
    		#just incase we wanted to send the file as an attachment
    		#$msg->attach(
    		#    Type     =>'text/html',
    		#    Encoding =>'base64',
    		#    Path     =>$path   
    		#);

		$msg->send('smtp','localhost', Debug=>1);

		exit(0);

   	}
  	else{ 
		#parent process - want to give us back a webpage NOW
	    	print "You will be notified via email (if you gave your email address) when the project is finished.<br>
		Please be patient: depending on queue and size of your dataset etc. this may take some time.";

		print "<br><br>Click <a href=\"http:\/\/compbio.mds.qmw.ac.uk/cgi-bin/ceo/cascader2.pl\">here</a> to submit another dataset or hit Back button";

  	}

    }


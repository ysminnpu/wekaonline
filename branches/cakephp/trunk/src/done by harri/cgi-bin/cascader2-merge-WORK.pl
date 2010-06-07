#!/usr/bin/perl -w

# VERSION
# This version tests 
# - zipping up sent/processed files (effect on dealer side cpu)
# - rsync replacement (effect on dealer cpu)
# - migration to cloud (removing QWEKA SPECIFIC operations)
# - gogrid perl api call (start/delete of servers)

$| = 1;
use strict;
use CGI;
use CGI::Carp "fatalsToBrowser";
use lib 'lib';
use MIME::Lite;
use CASCADE2MERGE;
# use File::Basename;

my $query = new CGI;

print $query->header();


print $query->start_html( -title=>'Classifier Emporium Operator (10cv / test)',
                 -style=>{-src=>'../css/snp_load.css'}
	        );


if(!$query->param()){

		
	

	



	print $query->start_multipart_form(-name=>"upload");



print <<ENDHTML;



<body>
<h1> Submit form </h1>
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
        my $structure_filename = $query->param('cstructure');
        die "There is a value containing illegal characters here, please resubmit" if $structure_filename =~ /<\s*(script|SCRIPT)\s|.*>/;

	my $arff_file = $query->upload('dataset-train') || print $!;
	my $arff_filename = $query->param('dataset-train');

	die "There is a value containing illegal characters in the dataset filename, please resubmit" if $arff_file =~ /<\s*(script|SCRIPT)\s|.*>/;

        my $filter = $query->param('filter');
        die "There is a value containing illegal characters in the filter, please resubmit" if $filter =~ /<\s*(script|SCRIPT)\s|.*>/;

	my $arff_file_test=$query->upload('dataset-test');
	my $arff_filename_test = $query->param('dataset-test');
        die "There is a value containing illegal characters in the testset filename, please resubmit" if $arff_filename_test =~ /<\s*(script|SCRIPT)\s|.*>/;
       
	my $classifiers=$query->param('classifiers');
	my @classifiers=split("\n",$classifiers);
        foreach my $classifier(@classifiers){

              die  "There is a value containing illegal characters in the classifier textarea, please resubmit" if $classifier !~ /\s*weka\.classifiers\.[a-zA-Z]+\.[a-zA-Z]+.*/ || $classifier =~ /<\s*(script|SCRIPT)\s|.*>/;
		# Remember to add "^" as in starts with 'weka'
        }


	my $projectname = $query->param('project');
        die "There is a value containing illegal characters in the projectname, please resubmit" if $projectname =~ /<\s*(script|SCRIPT)\s|.*>/;

	# || $projectname =~ /-[2-]|\s*|\/|_/;

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

	my $testdata='1' if length($arff_filename_test)>0; # what's this?


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

	print "creating arffs for each level......<br>";
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
	print "arff builder has finished creating arffs for each level......<br>";
	
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

		my $output=`ssh dobson\@fe07.esc.qmul.ac.uk sh /home/hep/dobson/hold/$projectname/foldsubmit.sh`;
		# KORVAA: my $output=`ssh dobson\@fe07.esc.qmul.ac.uk sh /home/hep/dobson/hold/$projectname/foldsubmit.sh`;
		
		#print BLA $output;

		my ($job_id)=$output=~/Your job-array (\d+)\./; # QWEKA SPECIFIC
		print BLA "job id for fold creation is $job_id\n"; # QWEKA SPECIFIC

		while(`ssh dobson\@fe07.esc.qmul.ac.uk sh /home/hep/dobson/hold/$projectname/qstat.sh` =~ /\n $job_id /){
		# QWEKA SPECIFIC

			for(1..175000000){};		
			
		};

		my $cmd="ssh dobson\@fe07.esc.qmul.ac.uk rm /home/hep/dobson/qweka.e".$job_id.".*"; # QWEKA SPECIFIC
		`$cmd`;
		$cmd="ssh dobson\@fe07.esc.qmul.ac.uk rm /home/hep/dobson/qweka.o".$job_id.".*"; # QWEKA SPECIFIC
		`$cmd`;


		$output=`ssh dobson\@fe07.esc.qmul.ac.uk sh /home/hep/dobson/hold/$projectname/classifiersubmit.sh`;

		($job_id)=$output=~/Your job-array (\d+)\./; # QWEKA SPECIFIC

		print BLA "job id for classifier run is $job_id\n";

		close BLA;


		while(`ssh dobson\@fe07.esc.qmul.ac.uk sh /home/hep/dobson/hold/$projectname/qstat.sh` =~ /\n $job_id /){

			for(1..175000000){};		# TÄTÄ EN YMMÄRRÄ, JOKU ID JUTTU SE ON, MUTTA SITÄ EI TARVI, FOLDER/PROJECTNAME BASED
			
		};

		$cmd="ssh dobson\@fe07.esc.qmul.ac.uk rm /home/hep/dobson/qweka.e".$job_id."*"; # QWEKA SPECIFIC
		`$cmd`;
		$cmd="ssh dobson\@fe07.esc.qmul.ac.uk rm /home/hep/dobson/qweka.o".$job_id."*"; # QWEKA SPECIFIC
		`$cmd`;

		`scp output dobson\@fe07.esc.qmul.ac.uk:hold/$projectname/`; # QWEKA SPECIFIC output file (ID's)

		`rsync -av dobson\@fe07.esc.qmul.ac.uk:hold/$projectname/ .`;
		# WE REPLACE THIS WITH LESS MEM-CONSUMING OPTION OF MOVING FILES, WHILE STILL SECURE
		# WE DO AS ABOVE: `tar cvfpz - * | ssh dobson\@fe07.esc.qmul.ac.uk cd /hold/$projectname; tar xvfpz -`;
		# BUT THE OPPOSITE WAY

		#my $command="sh classifier_lineup.txt &";
		#`$command`;

		chdir("../../");
		print "stashing results!";
		$project->stash_results();

		
		

		my $msg = MIME::Lite->new(
        		From     =>'developpers@ceodelegates.com',
        		To       =>"$email",
        		Cc       =>'harri.saarikoski@gmail.com',
        		Subject  =>"[WOn-NETFINN] Results for project $projectname",
			Type     =>'text',
			Data => qq{
            
Dear CEO / Weka Online user,

Your results for project $projectname are now ready for you. 
Please click here to collect your classifiers' accuracies:
http://74.54.140.114/~mysensev/renderer1b.php?name=$name&project=$projectname

For any queries or suggestions you have, please contact us.

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

		$msg->send('smtp','localhost', Debug=>1); # REPLACEd smtp.qmul.ac.uk KNOWN

		exit(0);

   	}
  	else{ 
		#parent process - want to give us back a webpage NOW
	    	print "You will be notified via email (if you gave your email address) when the project is finished.<br>
		Please be patient: depending on queue and size of your dataset etc. this may take some time.";

		print "<br><br>Hit Back button to submit another dataset";

  	}

    }


#!/usr/bin/perl -w

$| = 1;
use strict;
use CGI;
use CGI::Carp "fatalsToBrowser";
use lib 'lib';
use MIME::Lite;
use CASCADE2MERGE;
use File::Basename;

my $query = new CGI;

print $query->header();


print $query->start_html( -title=>'Classifier Emporium of Ours',
                 -style=>{-src=>'../css/snp_load.css'}
	        );


if(!$query->param()){

		
	

	



	print $query->start_multipart_form(-name=>"upload");



print <<ENDHTML;

<body bgcolor="#000000" text="#FFFFBF" vlink="#990002" link="#990001">



<body>
<br>

<body>
<table border=3 width=32% cols=2 bgcolor=#990000>

<tr>
<td>
<h3> Train set (restricted to 1MB) </h3> 
<input type="file" value="Browse" name="dataset-train"><br> 
<input type=checkbox value="on" name="filter"> Tick to filter out the first column (instance ID, see Instructions). 
<br><h3>Test set (restricted to 1MB) </h3>

<input type="file" value="Browse" name="dataset-test"><br> 


<!-- <td>
<h3> Structure </h3>
<input type="file" value="Browse" name="cstructure"> 
</td> -->
</tr>

</table>
<br>
<table border=3 cols=2 bgcolor=#990000> 
<h3> Classifiers (restricted to 5 classifiers) </h3> 

</p>
<tr><td>
<textarea name="classifiers" cols="74" rows="5" wrap="off">
weka.classifiers.trees.J48
weka.classifiers.trees.SimpleCART
weka.classifiers.bayes.NaiveBayes
weka.classifiers.bayes.BayesNet -- -D -Q weka.classifiers.bayes.net.search.local.K2 -- -P 1 -S BAYES -E weka.classifiers.bayes.net.estimate.SimpleEstimator -- -A 0.5
weka.classifiers.functions.LibSVM -- -S 0 -K 0 -D 1 -G 1.0 -R 0.0 -N 0.5 -M 40.0 -C 1.0 -E 0.0010 -P 0.1</textarea></td>
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
<table border=3 width=32% cols=2 bgcolor=#990004>
<tr>

<!-- <td> User <td>
	<input type="text" name="name" size="40"><br>
</td> -->
<td>Email address (to send results link to)<td>
	<input type="text" name="email" size="40">
</td>

</tr>

<tr>
<td> Project name (unique!) <td><input type="text" name="project" size="40"><br></td>
<!-- <td> Run <td><input type="text" name="run" size="40"><br></td></tr> -->

<tr>
</tr> 
</table>
<br>

<p> Ok we need to do sth before we run CEO with classifiers you chose on the dataset using the given structure. 
<p> Send this form to us and we'll analyse it how long it takes to process it with given classifiers. <br><br>

<input type="checkbox" name="share" checked> I agree to the <a href="agreement.html" target=main>terms of use</a>.<br>

ENDHTML

	print $query->submit(-name=>"submit",-label=>'Submit');
	print $query->endform(-name=>"upload");

}





####################################
if($query->param()){

	#print $query->start_html( -title=>'Our classifier emporium',
        #         -style=>{-src=>'../css/snp_load.css'},
#		 -meta => {'HTTP-EQUIV'=>'REFRESH',      
      #                          'CONTENT'=>'10'}
	#        );       

	my $structure_file = $query->upload('cstructure');
        my $structure_filename = $query->param('cstructure');
        die "There is a value containing illegal characters in the structure filename, please resubmit" if $structure_filename =~ /<\s*(script|SCRIPT)\s|.*>/;

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
#        foreach my $arff(@arff){
 #            die "There is a value containing illegal characters in the dataset file, please resubmit" if $arff =~ /<\s*(script|SCRIPT)\s|.*>/;
#
#	}
        my @arff_test = <$arff_file_test>;
#        foreach my $arff_test(@arff_test){
#             die "There is a value containing illegal characters in the testfile, please resubmit" if $arff_test =~ /<\s*(script|SCRIPT)\s|.*>/;
#	}
        my @structure = <$structure_file>;
        foreach my $structure(@structure){
             die "There is a value containing illegal characters in the structure file, please resubmit" if $structure =~ /<\s*(script|SCRIPT)\s|.*>/;
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
		print "stashing results!";
		$project->stash_results();

		
		

		my $msg = MIME::Lite->new(
        		From     =>'developers@ceodelegates.com',
        		To       =>"$email",
        		Cc       =>'developers@ceodelegates.com',
        		Subject  =>"[Weka Online] Results for project $projectname",
			Type     =>'text',
			Data => qq{
            
Dear Weka Online user,

Your results for project $projectname are now ready for you. 
Please click here to collect the summary of your results (accuracies):
http://74.54.140.114/~mysensev/renderer1b.php?name=$name&project=$projectname
(Note that if you used space character in either user or project names, 
you will need to remove the space(s) from this link in order for it to work).

For any queries or suggestions you have, please contact developers\@ceodelegates.com.

Yours sincerely,
CEO team  

ps. Let us know if you are interested in higher accuracy algorithm (CEO) 
or have us do analytical work of results for you or the whole thing we can. 

# Go to query page for alternate outputs: http://www.ceodelegates.com -> Get results 
# (using your username and project name).


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


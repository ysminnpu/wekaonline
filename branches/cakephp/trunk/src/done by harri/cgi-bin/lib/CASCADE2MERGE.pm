package CASCADE2MERGE;
use DBI;
use strict;


#BEGIN {
#       our @ISA = qw(Graph::Undirected);
#       require Graph::Undirected;

#}


sub new {


        my $invocant=shift;
        my $class=ref($invocant) || $invocant;

        my $self={
                #'weighted'=>0,
                @_
        };


	return bless $self,$class;


}

sub get_structure {

        my $self=shift;

        return $self->{'structure'};

}

sub get_arff {

        my $self=shift;

        return $self->{'arff'};

}

sub get_tree_depth{

	my $self=shift;

	$self->{'depth'}=scalar(split(/\t|\s/,${$self->{'structure'}}[0]));

	return $self->{'depth'};

}



sub create_arff_head {


	my $self=shift;
	my $arff=$self->{'arff'};

	
	my $previousline;
	foreach my $line(@{$arff}){

		die "This does not appear to be ARFF, if it is, contact us at developers\@ceodelegates.com" 
		if($line!~/^\@(relation|RELATION).*|
		(^\@(attribute|ATTRIBUTE)\s+.*(numeric|integer|real|string|date|relational|{.*}))+|
		^\@(data|DATA).*|.*|
		(([0-9]+\.[0-9]+)(,\s*|\n\r?))+/);

		# This is accepting ething if ".*" is set. 

		# Commented lines "%" have been ignored already. There can also be "%" at the end of each line. 

		# More detailed injunction:
		# |(.*,.*|\n\r?)
		# ^{?(('?.*'?)|
		# ([0-9]+\s+\[0-9]+),)+
		# ('?\w+'?|\'?[0-9]+'?)}?(\s*%\s*.*));
	    
		# or in place of this: java call to weka method for opening the dataset, failure -> abort: "this is not arff"

	    	next if $line=~/^%/;
		if($line=~/^\@data/i){

			$self->{'arffheader'}=~s/(.*\n\r*).*\n\r*/$1/s;	
			last;
	
		}
		elsif($line=~/^\@/){
			
			$self->{'arffheader'} .= $line;
			$previousline=$line;
					
		}
		

		

	}
	


}

sub create_flat_arffs{

    	my $self=shift;
    	my $level=shift;
	my $test=shift;
	my @arff;
	if($test ne "test"){
    		@arff=@{$self->{'arff'}};
	}
	else{
		@arff=@{$self->{'arff_test'}};
	}
    	my $project=$self->{'project'};



    	unless(-d "hold/$project"){

		mkdir("hold/$project") || print "can't make directory for $project $!<br>";

    	}

    	my $file="hold/$project/".$project."_level".$level.".arff" unless $test eq "test";

	$file="hold/$project/".$project."_level".$level."_test.arff" if $test eq "test";

	open(OUT,">$file");
	print OUT @arff;
	close OUT;
   
}

#sub create_test_arff{
    
#    my $self=shift;
#    my @arff=@{$self->{'arff_test'}};
#    my $project=$self->{'project'};
    
#    my $hStructure;
#    my $targets;
   
#    my $file="hold/$project/".$project."_test.arff";

#    open(OUTTEST,">$file") || "die can't open file $!\n";
#    print OUTTEST @arff;
#    close OUTTEST;

#}

sub load_classifiers{
    my $self = shift;

    my @classifiers = @{$self->{'classifiers'}};

    my $dbh = DBI->connect("DBI:mysql:database=ceo;host=localhost", "ceo", "harriandrich"); # connect to db
    
	

    my $sth = $dbh->prepare(qq/insert into classifiers values(?,?)/);
   
    my $out_fold="hold/".$self->{'project'}."/create_folds.txt";
    my $out_class="hold/".$self->{'project'}."/classifier_lineup.txt";
	

    open(OUTFOLD,">$out_fold") || print "can't create the fold lineup script : $!<br>";
    open(OUTCLASS,">$out_class") || print "can't create the classifier lineup script : $!<br>";

    my $arff_dir="hold/".$self->{'project'};
    
    my $project = $self->{'project'};


# Move foldgen loop here, to do it once only. 

#	opendir(DIR,$arff_dir) || print "can't opendir $arff_dir: $!";

#		my $folds=11;
#		for (my $nrfold=1; $nrfold < $folds; $nrfold++ ){

#			unless(-e "/home/hep/dobson/hold/".$project."/".$arff."_test_fold".$nrfold.".arff"){
#				print OUTFOLD "java -Xmx2500M -cp /home/hep/dobson/weka-3-5-7/weka.jar weka.filters.supervised.instance.StratifiedRemoveFolds -c last -S 1 -N 10 -F $nrfold -i /home/hep/dobson/hold/$project/$arff > /home/hep/dobson/hold/".$project."/".$arff."_test_fold".$nrfold.".arff\n" || print "cant print to $arff test fold<br>";
#			} # test fold

#			unless(-e "/home/hep/dobson/hold/".$project."/".$arff."_train_fold".$nrfold.".arff"){
#				print OUTFOLD "java -Xmx2500M -cp /home/hep/dobson/weka-3-5-7/weka.jar weka.filters.supervised.instance.StratifiedRemoveFolds -c last -S 1 -V -N 10 -F $nrfold -i /home/hep/dobson/hold/$project/$arff > /home/hep/dobson/hold/".$project."/".$arff."_train_fold".$nrfold.".arff\n" || print "cant print to $arff train fold<br>";
#			} # training folds

#		}

    foreach my $i (0 .. $#classifiers){
	$classifiers[$i] =~ tr/\cM//d; # remove the ctr M characters at the end of each classifier line
	opendir(DIR,$arff_dir) || print "can't opendir $arff_dir: $!";
        $sth->execute($self->{'project'},$classifiers[$i]);


	while(my $arff=readdir(DIR)){
		    
	    	next unless $arff=~/level\d+\.arff$/;

		# did the user supply a test dataset?
		if($self->{'testdatasupplied'} == 1){

			my $filter;

			if ($self->{'filter'} eq 'on'){
				$filter=qq/ weka.classifiers.meta.FilteredClassifier -F "weka.filters.unsupervised.attribute.Remove -R first" -W /;
			}
		
			my ($prefix)=$arff=~/(.*?)\.arff/;

	    		my $insert=" -T /home/hep/dobson/hold/".$project."/".$prefix."_test.arff -t  /home/hep/dobson/hold/".$project."/".$arff." -o -p 1 ";

	    		my $classifier=$classifiers[$i];
	    		my $success=$classifier=~s/\s/$insert/;

	    		$classifier=$classifier.$insert unless $success>0;
	
			print OUTCLASS "java -Xmx2500M -cp /home/hep/dobson/weka-3-5-7/weka.jar:/home/hep/dobson/WLSVM/lib/libsvm.jar:/home/hep/dobson/WLSVM/lib/wlsvm.jar: $filter $classifier >> /home/hep/dobson/hold/".$project."/$arff.$i.res\n" || print "can't print to $arff.$i.res<br>";

		}
		#if they didn't we perform 10xval
		else{
			
			my $folds=11;

			for (my $nrfold=1; $nrfold < $folds; $nrfold++ ){

				my $filter;

				if ($self->{'filter'} eq 'on'){
					$filter=qq/ weka.classifiers.meta.FilteredClassifier -F "weka.filters.unsupervised.attribute.Remove -R first" -W /;
				}
		
	    			my $insert=" -T /home/hep/dobson/hold/".$project."/".$arff."_test_fold".$nrfold.".arff -t  /home/hep/dobson/hold/".$project."/".$arff."_train_fold".$nrfold.".arff -o -p 1 ";

	    			my $classifier=$classifiers[$i];
	    			my $success=$classifier=~s/\s/$insert/;

	    			$classifier=$classifier.$insert unless $success>0;
	
				unless(-e "/home/hep/dobson/hold/".$project."/".$arff."_test_fold".$nrfold.".arff"){
					print OUTFOLD "java -Xmx2500M -cp /home/hep/dobson/weka-3-5-7/weka.jar weka.filters.supervised.instance.StratifiedRemoveFolds -c last -S 1 -N 10 -F $nrfold -i /home/hep/dobson/hold/$project/$arff > /home/hep/dobson/hold/".$project."/".$arff."_test_fold".$nrfold.".arff\n" || print "cant print to $arff test fold<br>";
				} # test fold

				unless(-e "/home/hep/dobson/hold/".$project."/".$arff."_train_fold".$nrfold.".arff"){
					print OUTFOLD "java -Xmx2500M -cp /home/hep/dobson/weka-3-5-7/weka.jar weka.filters.supervised.instance.StratifiedRemoveFolds -c last -S 1 -V -N 10 -F $nrfold -i /home/hep/dobson/hold/$project/$arff > /home/hep/dobson/hold/".$project."/".$arff."_train_fold".$nrfold.".arff\n" || print "cant print to $arff train fold<br>";
				} # training folds
		
	    			print OUTCLASS "java -Xmx2500M -cp /home/hep/dobson/weka-3-5-7/weka.jar:/home/hep/dobson/WLSVM/lib/libsvm.jar:/home/hep/dobson/WLSVM/lib/wlsvm.jar: $filter $classifier >> /home/hep/dobson/hold/".$project."/$arff.$i.res.$nrfold\n" || print "can't print to $arff.$i.res<br>";

			} 

		}

	}
	closedir DIR;
    }
    close OUT;
    
    $dbh->disconnect;
    
}

sub load_personal_info{

    my $self = shift;
    

    my $dbh = DBI->connect("DBI:mysql:database=ceo;host=localhost", "ceo", "harriandrich"); # connect to db
    


    my $sth = $dbh->prepare(qq/insert into projects values(?,?,?,?,?,?)/);

    my $email=$dbh->quote($self->{'email'});

    $sth->execute($self->{'project'},$self->{'run'},$self->{'name'},$self->{'inst'},$self->{'password'},$email);

    $dbh->disconnect;

}
####################################################


sub create_structured_arffs {

	my $self=shift;
	my $level=shift;
	my $test=shift;
	my @arff;


	

	if($test ne "test"){
    		@arff=@{$self->{'arff'}};
	}
	else{
		@arff=@{$self->{'arff_test'}};
	}


	my $project=$self->{'project'};

	my $hStructure;
	my $targets;


	unless(-d "hold/$project"){

		mkdir("hold/$project");

	}


	foreach my $row(@{$self->{'structure'}}){


		#eg hybrid  53931   100879
		my @aRow=split(/\t|\s/,$row);
		
		my $leaf=@aRow[$#aRow];

		$leaf=~s/\s$//;	
		

		@{$hStructure->{$leaf}}=@aRow;


		

		#if($level>0){


		#	my $prevlevel=$level-1;
		#	chomp $aRow[$prevlevel];
			chomp $aRow[$level];
			$aRow[$level]=~s/\r//;
			$targets->{$aRow[$level]}++;
			
		#}
		#else{
		#	chomp $aRow[$level];
		#	$aRow[$level]=~s/\r//;
		#	$targets->{$aRow[$level]}++;
		#}
		

	}



	my $indata=0;

	foreach my $line(@arff){

		$line=~s/\r//;

		if($line=~/^\@data$/){	
			$indata=1; 
			next;
		}
		if($indata == 1){

			my $prevlevel;
			#my $nextlevel;
			my $file;
			if($level>0){

				$prevlevel=$level-1;
				#$nextlevel=$level+1; 
				$line=~s/(.*,)(.+)$/$1$hStructure->{$2}[$level]\n/;
				$file="hold/$project/".$project."_".${$hStructure->{$2}}[$prevlevel]."_level".$level.".arff";		
				$file="hold/$project/".$project."_".${$hStructure->{$2}}[$prevlevel]."_level".$level."_test.arff" if $test eq "test";

		
				
			}
			else{
				$line=~s/(.*,)(.+)$/$1$hStructure->{$2}[$level]\n/;
				$file="hold/$project/".$project."_level".$level.".arff";

				$file="hold/$project/".$project."_level".$level."_test.arff"  if $test eq "test";
		
			}

				

		
			unless(-e $file){
				open(OUT,">$file") || print "can't open file $!\n";
				print OUT $self->{'arffheader'};
				print OUT '@attribute class {',join(',',keys %{$targets}),"}\n";
				print OUT "\@data\n";
				close OUT;

			}
			open(OUT,">>$file") || print "can't open file $file :$!\n";
			chomp $line;
			print OUT $line  || print "can't write to open file $file :$!\n";
			close OUT;
			

		}
	}

}

sub stash_results{

	my $self = shift;
    	my @classifiers = @{$self->{'classifiers'}};

    	my $dbh = DBI->connect("DBI:mysql:database=ceo;host=localhost", "ceo", "harriandrich"); # connect to db



	my $sth = $dbh->prepare(qq/insert into results values(?,?,?,?,?,?,?,?,?,?)/);	

	my $res_dir="hold/".$self->{'project'};

	opendir(DIR,$res_dir) || print "can't opendir $res_dir: $!";

	chdir("hold/".$self->{'project'});

	my $sum;

	my $project=$self->{'project'};
	my $run=$self->{'run'};

	while(my $res=readdir(DIR)){

		
		next unless $res=~/\.res/;

		#project, level  , class, classifier ,actual ,predicted ,  error , prediction, name )
		
		my ($level)=$res=~/_level(\d+)/;
		my ($class)=$res=~/_(.*?)_level[1-9]+/;
		my ($classifier)=$res=~/\.arff\.(\d+)\.res/;
		$classifier=$classifiers[$classifier];
		chomp $classifier;
		$classifier =~ tr/\cM//d;

		

		open(IN,$res);

		
		
		while(my $line=<IN>){
 			## inst#     actual  predicted error prediction (ID)

			next if $line=~/^Zero Weights processed/;
			next if $line=~/^ inst/; 
			next if $line=~/^\s*$/;

			my @line_parts=split(/\s+/,$line);
                	my $name=$line_parts[-1];
                	$name=~s/\(//;
                	$name=~s/\)//;
                	my $actual=$line_parts[2];
                	$actual=~s/\d+\://;
                	my $predicted=$line_parts[3];
                	$predicted=~s/\d+\://;

			my $error='+' if $actual ne $predicted;

			$sum->{$level}{$class}{$classifier}{'correct'}++ unless $error eq '+';
			$sum->{$level}{$class}{$classifier}{'total'}++;	


			my $prediction=$line_parts[-2];

    			$sth->execute("$project","$run","$level","$class","$classifier","$actual","$predicted","$error","$prediction","$name");
		}

	}

	foreach my $level(keys %{$sum}){
		foreach my $class(keys %{$sum->{$level}}){
			foreach my $classifier(keys %{$sum->{$level}{$class}}){
				my $accuracy=$sum->{$level}{$class}{$classifier}{'correct'}/$sum->{$level}{$class}{$classifier}{'total'}*100 unless $sum->{$level}{$class}{$classifier}{'total'}<1;
				my $tth = $dbh->prepare(qq/insert into resultssum values ("$project","$run","$level","$class","$classifier","$accuracy")/);

				$tth->execute();
			}
		}
	}

    	$dbh->disconnect;

	my $cmd="dsh -m dobson\@fe07.esc.qmul.ac.uk rm /home/hep/dobson/hold/$project/*.res";
	`$cmd`;	
	$cmd="dsh -m dobson\@fe07.esc.qmul.ac.uk rm /home/hep/dobson/hold/$project/*fold*.arff";
	`$cmd`;
	`rm *.res`;
	`rm *fold*.arff`;

}

sub dsh_script{

	my $self = shift;
	my $type = shift;
	my $project = $self->{'project'};

	my $script=
"
#!/bin/bash
HOSTNAME=fe07
SGE_CELL=htc
SSH_TTY=/dev/pts/1
USER=dobson
SGE_NO_CA_LOCAL_ROOT=1
MAIL=/var/spool/mail/dobson
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11
INPUTRC=/etc/inputrc
PWD=/home/hep/dobson
LANG=en_US.UTF-8
SGE_ROOT=/usr/share/sge
SHLVL=1
HOME=/home/hep/dobson
MATLAB=/opt/shared/matlab7
LOGNAME=dobson
export SGE_CELL HOSTNAME TERM SHELL HISTSIZE SGE_NO_CA_LOCAL_ROOT PATH INPUTRC SGE_ROOT SHLVL LOGNAME SSH_CONNECTION LESSOPEN G_BROKEN_FILENAMES

";

	if($type eq 'fold'){

		$script.="chmod 755 ~/hold/".$project."/create_folds.txt;";
		$script.="/home/hep/dobson/qweka ~/hold/".$project."/create_folds.txt";
	}
	elsif($type eq 'class'){

		$script.="chmod 755 ~/hold/".$project."/classifier_lineup.txt;";
		$script.="/home/hep/dobson/qweka ~/hold/".$project."/classifier_lineup.txt";
	}
	elsif($type eq 'qstat'){
	
		$script.="qstat -u dobson";
	}
	return $script;
}


#####################################################

1;


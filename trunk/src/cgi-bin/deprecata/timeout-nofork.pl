#!/usr/bin/perl

eval {

   local %SIG;
   $SIG{ALRM}=
     sub{ die "timeout reached, after 3 seconds!\n"; };
   alarm 3;
   `ls -al`; 	# ssh sh classifier_lineup.txt;
   print "sleeping for 3 seconds\n";
   # sleep 6; 	# This is where to put your code, between the alarms
   alarm 0;
};

alarm 0;

if($@) { print "Error: $@\n"; }

exit(0);
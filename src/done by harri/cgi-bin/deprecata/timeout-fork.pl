package Timed;

use strict;
use warnings;

use Exporter ();

our @ISA    = qw /Exporter/;
our @EXPORT = qw /timed_system/;


sub timed_system {
    my $time = shift;

    my $pid;
 
    local $SIG {ALRM} = sub {kill 15, $pid or die "kill: $!";
                             die "Timeout!"}; # Just SIGTERM.
 
    eval {
        $pid = fork;
 
        die "Fork failed: $!" unless defined $pid;
 
        unless ($pid) {
            cd ..; # system('ls -al'); # exec @_ where is the list of incoming parameters to a sub

            die "Exec failed: $!";
        }
 
        alarm $time;
 
        waitpid $pid => 0;
    };
    die $@ if $@ && $@ !~ /^Timeout!/;
}

1;

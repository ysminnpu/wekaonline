#!/usr/bin/perl -w

use lib 'lib';
use GoGridClient;
use strict;

# Create a new GoGridClient object with the default values
my $myObject = GoGridClient->new();

# Create the paramets to the method call
my %params = ("format","xml"); # changed this from json to xml

#############################################

# Create the request for the server/list method
# my $requestURL = $myObject->getRequestURL("grid/server/list",%params);

# List of IP addresses available in the grid:
# my $requestURL = $myObject->getRequestURL("grid/ip/list",%params);

# List server images
# my $requestURL = $myObject->getRequestURL("grid/image/list",%params);

# Start a server
# my $requestURL = $myObject->getRequestURL("grid/server/add",%params);

# Stop/delete a server
my $requestURL = $myObject->getRequestURL("grid/server/delete",%params);

# Get password for a server (to be shown on screen for client to proceed)

# Get billing summary (sent to my gmaiul.com)

#############################################

# Print the request
print "\nRequest :\n$requestURL";

# Send the request
my $results = $myObject->sendAPIRequest($requestURL);

#print the results
print "\n\nResponse :\n$results";

package GoGridClient;
use strict;

# Constructor that initializes all values.
sub new {
  my $class = shift;
  my $self  = {
    _format  => @_ ? shift : "xml",
    _server  => @_ ? shift : "https://api.gogrid.com/api",
    _apikey  => @_ ? shift : "d2104c2002b0f6aa",
    _secret  => @_ ? shift : "babypleaseme",
    _version => @_ ? shift : "1.0",
    _name    => @_ ? shift : "server1",
    _image   => @_ ? shift : "rhel51_64_apache",
    _ram     => @_ ? shift : "512MB",
    _ip      => @_ ? shift : "173.1.93.243"

  };

# These were sent but bad request:
# https://api.gogrid.com/api/grid/server/add?
# &sig=21cc77bd2a0e1f36dad788c5a138f05a
# &format=xml
# &ip=173.1.93.242
# &name=server1
# &v=1.0
# &api_key=d2104c2002b0f6aa
# &ram=512MB
# &image=centos44_32_apache22php5

# SWITCH IMAGE TO: rhel51_64_apache

  bless $self, $class;
  return $self;
}

# PARAMEISTA:
# &name on server_index
# &image on aina sama centos44_32_apache22php5
# &ram määrittyy optimointialgorithmin mukaan
# &ip tulee grid.ip.list callista sieltä eka


# Construct a request URL for the GoGrid API based on method and parameters passed in
sub getRequestURL {
  use URI::Escape;

  # Initialize locals from arguments
  my ( $self, $method, %params ) = @_;

  # Create an array containing default parameter values
  my %_params = ( 
    "api_key", $self->{_apikey},
    "v", $self->{_version},
    "format",  $self->{_format},
    "sig", $self->getSignature( $self->{_apikey}, $self->{_secret} ),
    "name", $self->{_name},
    "image", $self->{_image},
    "ram", $self->{_ram},
    "ip", $self->{_ip} );

  # Merge in the passed in parameters, url encoding any values
  while ( ( my $key, my $value ) = each %params ) {
    $_params{$key} = uri_escape($value);
  }

  # Start building the URL using the server and method
  my $url = $self->{_server} . "/" . $method . "?";
  
  # Append the parameter values to the URL
  while ( ( my $key, my $value ) = each %_params ) {
    $url .= "&$key=$value";
  }

  # Return the URL
  return $url;
}

# Generate request signature from key and secret members
sub getSignature {
  my ($self) = @_;

  use Digest::MD5;

  my $key       = $self->{_apikey};
  my $secret    = $self->{_secret};
  my $timestamp = time();

  my $md5 = Digest::MD5->new;
  $md5->add( $key, $secret, $timestamp );
  my $digest = $md5->hexdigest;

  return $digest;
}

# This method sends the HTTP request and returns the response, handling any HTTP errors
sub sendAPIRequest {
  my ( $self, $url ) = @_;
  require LWP::UserAgent;

  my $ua = LWP::UserAgent->new;
  $ua->timeout(10);
  $ua->env_proxy;

  my $response = $ua->get($url);

  if ( $response->is_success ) {
    # If successful return the body of the response
    return $response->content;    
  }
  else {
    # If failure return the error message
    return $response->status_line;
  }
}
1;


#! /usr/bin/perl
#===============================================================================
#
#         FILE:  hotel.pl
#
#        USAGE:  ./hotel.pl
#
#  DESCRIPTION:  Default script for api_calls from the hotel service
#
#      OPTIONS:
# REQUIREMENTS:
#         BUGS:
#        NOTES:
#       AUTHOR:  James Bree,
#      COMPANY:
#      VERSION:  1.0
#      CREATED:  08/04/20 17:39:39
#     REVISION:  0.000
#===============================================================================

use strict;
use warnings;

use CGI;
use JSON;
use HotelAuthentication;
use HotelTemplate;
use HotelDB;
use HotelUpdateInsert;

my $cgi = CGI->new();

print( $cgi->header( -access_control_allow_origin => '*' ) );

my $request    = $cgi->param('request');
my $type       = $cgi->param('type');
my $system_ref = $cgi->param('system_ref');

my $system_config = create_system_config();
my $db = HotelDB->new( config => $system_config );
update_system_config_from_db();

unless ($request) {
    print("No request specified");
    exit;
}

$request = decode_json($request);

my $auth = HotelAuthentication->new( DB => $db, config => $system_config );

my $allowed = $auth->auth_check( $request->{Authentication} );

if ( $allowed->{error} ) {
    print '{"error": "true", "error_message": "There has been an error: '
      . $allowed->{error} . '"}';
    exit;
}

if ( $type eq "login" ) {
    print '{"cookie": "'
      . $allowed->{cookie}
      . '", "csrf_token": "'
      . $allowed->{csrf_token} . '"}';
}

my $response;

if ( $type =~ /updateinsert/ ) {

    my $updateinsert =
      HotelUpdateInsert->new( DB => $db, request => $request, type => $type );

    $response = $updateinsert->update_insert_record();
}
else {
    my $template =
      HotelTemplate->new( DB => $db, request => $request, type => $type );

    $response = $template->new_template();
}

print $response if $response;

#################### subroutine header begin ####################

=head2 create_system_config

 Usage     : create_system_config()
 Purpose   : Constructs stored system config from server config file
 Returns   : A system config hash
 Argument  : Nothing
 Throws    : 
 Comment   : 

See Also   :

=cut

#################### subroutine header end ####################

sub create_system_config {
    my $system_config_file = "/etc/hotel/$system_ref.json";

    open my $fh, '<', $system_config_file;
    read $fh, my $config, -s $fh;
    close $fh;

    return decode_json($config);
}

#################### subroutine header begin ####################

=head2 update_system_config_from_db

 Usage     : update_system_config_from_db()
 Purpose   : Adds system config from DB
 Returns   : Nothing
 Argument  : Nothing
 Throws    : 
 Comment   : 

See Also   :

=cut

#################### subroutine header end ####################

sub update_system_config_from_db {
    my $lookup_config_query_string = "SELECT name, value FROM system_config";
    my $lookup_config_query_results =
      $db->run_query($lookup_config_query_string);

    foreach my $config_option ( @{$lookup_config_query_results} ) {
        $system_config->{ $config_option->{name} } = $config_option->{value};
    }
}

1;

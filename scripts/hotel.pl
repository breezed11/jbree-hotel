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
use DBI;
use JSON;
use HotelAuthentication;
use HotelTemplate;

my $cgi = CGI->new();

print( $cgi->header( -access_control_allow_origin => '*' ) );

my $request    = $cgi->param('request');
my $type       = $cgi->param('type');
my $system_ref = $cgi->param('system_ref');

my $system_config = create_system_config();
my $db            = create_db_connection();
update_system_config_from_db();

unless ($request) {
    print("No request specified");
    exit;
}

$request = decode_json($request);

my $auth = HotelAuthentication->new();

my $allowed = $auth->auth_check( $request->{Authentication}, $db );

if ( $allowed->{error} ) {
    print '{"error": "true", "error_message": "There has been an error: '
      . $allowed->{error} . '"}';
    exit;
}

my $template = HotelTemplate->new();

if ( $type eq "login" ) {
    print '{"cookie": "'
      . $allowed->{cookie}
      . '", "csrf_token": "'
      . $allowed->{csrf_token} . '"}';
}

if ( $type eq "left_menu" ) {
    my $html_to_print = HotelTemplate->construct_left_menu();
    print $html_to_print;
}

if ( $type eq "system_config" ) {
    my $html_to_print = HotelTemplate->construct_system_config();
    print $html_to_print;
}

if ( $type eq "system_config_results" ) {
    my $html_to_print = HotelTemplate->construct_system_config_results( $db,
        $request->{SearchFields} );
    print $html_to_print;
}

if ( $type eq "system_config_new" ) {
    my $html_to_print = HotelTemplate->construct_system_config_new($db);
    print $html_to_print;
}

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

=head2 create_db_connection

 Usage     : create_db_connection()
 Purpose   : Builds a database connection to use
 Returns   : A DBI object
 Argument  : Nothing
 Throws    : 
 Comment   : 

See Also   :

=cut

#################### subroutine header end ####################

sub create_db_connection {
    my $dbi_driver =
        "DBI:mysql:"
      . $system_config->{database_name}
      . ";port=3306;mysql_connect_timeout=5";

    return DBI->connect(
        $dbi_driver,
        $system_config->{database_username},
        $system_config->{database_password},
        { TaintIn => 1, mysql_enable_utf8 => 1 }
    );
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
    my $lookup_config_query        = $db->prepare($lookup_config_query_string);
    $lookup_config_query->execute();
    my $lookup_config_query_results =
      $lookup_config_query->fetchall_arrayref( {} );

    foreach my $config_option ( @{$lookup_config_query_results} ) {
        $system_config->{ $config_option->{name} } = $config_option->{value};
    }
}

1;

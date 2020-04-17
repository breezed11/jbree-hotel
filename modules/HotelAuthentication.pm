#===============================================================================
#
#         FILE:  Hotel::Authentication
#
#        USAGE:  Hotel::Authentication->new();
#
#  DESCRIPTION:  Handles authentication, permissions and session management
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

package HotelAuthentication;

use strict;
use warnings;

use Crypt::PBKDF2;

sub new {
    my $self = {@_};

    bless $self;

    $self->{crypt} = Crypt::PBKDF2->new();

    return $self;
}

sub auth_check {
    my $self      = shift;
    my $auth_hash = shift;
    my $db = shift;

    my $result = "";

    if ( $auth_hash->{cookie} && $auth_hash->{csrf_token} ) {
        $result =
          $self->check_session( $auth_hash->{cookie},
            $auth_hash->{csrf_token} );
    }
    else {
        $result =
          $self->login( $auth_hash->{username}, $auth_hash->{password}, $db );
    }

    return $result;
}

sub check_session {
    my $self       = shift;
    my $cookie     = shift;
    my $csrf_token = shift;

    return "PASS";
}

sub login {
    my $self     = shift;
    my $username = shift;
    my $password = shift;
    my $db = shift;

    my $lookup_query_string =
      "SELECT pw, active FROM users WHERE username = '$username'";
    my $lookup_query = $db->prepare($lookup_query_string);
    $lookup_query->execute();
    my $lookup_query_results = $lookup_query->fetchall_arrayref( {} );

    unless ( $lookup_query_results->[0] ) {
        return { error => "No user found.", final_result => "FAIL" };
    }

    if ( $lookup_query_results->[1] ) {
        return { error => "Too many users found.", final_result => "FAIL" };
    }

    if ( $lookup_query_results->[0]->{active} ne "Y" ) {
        return { error => "User not active.", final_result => "FAIL" };
    }

    unless (
        $self->{crypt}->validate( $lookup_query_results->[0]->{pw}, $password )
      )
    {
        return { error => "Incorrect password.", final_result => "FAIL" };
    }

    return { final_result => "PASS" };
}

1;

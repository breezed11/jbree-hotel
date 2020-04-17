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

sub new {
    my $self = {@_};

    bless $self;

    return $self;
}

sub auth_check {
    return { "result" => "PASS" };
    my $self      = shift;
    my $auth_hash = shift;

    my $result = "";

    if ( $auth_hash->{cookie} && $auth_hash->{csrf_token} ) {
        $result =
          $self->check_session( $auth_hash->{cookie},
            $auth_hash->{csrf_token} );
    }
    else {
        $result =
          $self->login( $auth_hash->{username}, $auth_hash->{password} );
    }

    return { error => $result };
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

    return "PASS";
}

1;

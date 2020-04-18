#===============================================================================
#
#         FILE:  HotelAuthentication
#
#        USAGE:  HotelAuthentication->new();
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

#################### subroutine header begin ####################

=head2 new

 Usage     : new()
 Purpose   : Constructs an object to handle sessions and authentication
 Returns   : A HotelAuthentication object
 Argument  : Nothing
 Throws    : 
 Comment   : 

See Also   :

=cut

#################### subroutine header end ####################

sub new {
    my $self = {};

    bless $self;

    $self->{crypt} = Crypt::PBKDF2->new();

    return $self;
}

#################### subroutine header begin ####################

=head2 auth_check

 Usage     : $self->auth_check(auth_hash)
 Purpose   : Checks for an existing session for a user if cookie 
 and CSRF token are supplied, if not then attempts to login via password
 Returns   : Authentication status
 Argument  : auth_hash
 Throws    : 
 Comment   : 

See Also   :

=cut

#################### subroutine header end ####################

sub auth_check {
    my $self      = shift;
    my $auth_hash = shift;
    my $db        = shift;

    my $result = "";

    if ( $auth_hash->{cookie} && $auth_hash->{csrf_token} ) {
        $result =
          $self->check_session( $auth_hash->{cookie},
            $auth_hash->{csrf_token}, $db );
    }
    else {
        $result =
          $self->login( $auth_hash->{username}, $auth_hash->{password}, $db );
    }

    return $result;
}

#################### subroutine header begin ####################

=head2 check_session

 Usage     : $self->check_session(cookie, csrf_token, db)
 Purpose   : Checks the given session is valid and updates the expiry 
 if so.
 Returns   : Session authentication status
 Argument  : cookie, csrf_token, db
 Throws    : 
 Comment   : 

See Also   :

=cut

#################### subroutine header end ####################

sub check_session {
    my $self       = shift;
    my $cookie     = shift;
    my $csrf_token = shift;
    my $db         = shift;

    my $lookup_query_string =
"SELECT id FROM sessions WHERE cookie = '$cookie' AND csrf_token = '$csrf_token' AND ( last_active > NOW() - INTERVAL 10 MINUTE )";
    my $lookup_query = $db->prepare($lookup_query_string);
    $lookup_query->execute();
    my $lookup_query_results = $lookup_query->fetchall_arrayref( {} );

    unless ( $lookup_query_results->[0] ) {
        return { error => "Session has expired.", final_result => "FAIL" };
    }

    if ( $lookup_query_results->[1] ) {
        return { error => "Too many sessions found.", final_result => "FAIL" };
    }

    # Update the session

    my $update_session_query_string = "UPDATE sessions SET last_active = NOW()";
    my $update_session_query = $db->prepare($update_session_query_string);
    $update_session_query->execute();

    $self->{cookie}     = $cookie;
    $self->{csrf_token} = $csrf_token;

    return {
        final_result => "PASS",
        cookie       => $self->{cookie},
        csrf_token   => $self->{csrf_token}
    };
}

#################### subroutine header begin ####################

=head2 login

 Usage     : $self->login(username, password, db)
 Purpose   : Logs the user in if possible and creates a session
 Returns   : Login status
 Argument  : username, password, db
 Throws    : 
 Comment   : 

See Also   :

=cut

#################### subroutine header end ####################

sub login {
    my $self     = shift;
    my $username = shift;
    my $password = shift;
    my $db       = shift;

    # Check user credentials

    my $lookup_query_string =
      "SELECT id, pw, active FROM users WHERE username = '$username'";
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

    # Create a new session

    $self->create_new_user_session( $username,
        $lookup_query_results->[0]->{id}, $db );

    return {
        final_result => "PASS",
        cookie       => $self->{cookie},
        csrf_token   => $self->{csrf_token}
    };
}

#################### subroutine header begin ####################

=head2 create_new_user_session

 Usage     : $self->create_new_user_session(username, db)
 Purpose   : Creates a session and clears down previous sessions
 Returns   : Cookie and CSRF token
 Argument  : username, db
 Throws    : 
 Comment   : 

See Also   :

=cut

#################### subroutine header end ####################

sub create_new_user_session {
    my $self     = shift;
    my $username = shift;
    my $userid   = shift;
    my $db       = shift;

    # Clear down any old user sessions

    my $clear_users_query_string =
      "DELETE FROM sessions WHERE user_id = '$userid'";
    my $clear_users_query = $db->prepare($clear_users_query_string);
    $clear_users_query->execute();

    # Create the new cookie and csrf token

    my ( $new_cookie, $new_csrf_token ) = $self->create_auth_cookies();
    $self->{cookie}     = $new_cookie;
    $self->{csrf_token} = $new_csrf_token;

    # Create the new session

    my $new_session_query_string =
"INSERT INTO sessions SET user_id = '$userid', last_active = NOW(), cookie = '$new_cookie', csrf_token = '$new_csrf_token'";
    my $new_session_query = $db->prepare($new_session_query_string);
    $new_session_query->execute();

    return 1;
}

#################### subroutine header begin ####################

=head2 create_auth_cookies

 Usage     : $self->create_auth_cookies()
 Purpose   : Creates random strings for cookies and csrf tokens
 Returns   : Cookie and CSRF token
 Argument  : nothing
 Throws    : 
 Comment   : 

See Also   :

=cut

#################### subroutine header end ####################

sub create_auth_cookies {
    my $self = shift;

    my @chars = ( "A" .. "Z", "a" .. "z" );
    my ( $cookie, $csrf_token );
    $cookie     .= $chars[ rand @chars ] for 1 .. 16;
    $csrf_token .= $chars[ rand @chars ] for 1 .. 16;

    return ( $cookie, $csrf_token );
}

1;

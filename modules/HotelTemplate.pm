#===============================================================================
#
#         FILE:  HotelTemplate
#
#        USAGE:  HotelTemplate->new();
#
#  DESCRIPTION:  Handles creation of templates
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

package HotelTemplate;

use strict;
use warnings;

use Template;

sub new {
    my $invocant = shift;
    my $class    = ref($invocant) || $invocant;
    my $self     = {@_};

    bless $self, $class;

    return $self;
}

sub new_template {
    my $self = shift;

    my $html_to_print;

    if ( $self->{type} eq "left_menu" ) {
        $html_to_print = $self->construct_left_menu();
    }

    if ( $self->{type} eq "system_config" ) {
        $html_to_print = $self->construct_system_config();
    }

    if ( $self->{type} eq "system_config_results" ) {
        $html_to_print = $self->construct_system_config_results();
    }

    if ( $self->{type} eq "system_config_new" ) {
        $html_to_print = $self->construct_system_config_new();
    }

    if ( $self->{type} eq "attributes" ) {
        $html_to_print = $self->construct_attributes();
    }

    if ( $self->{type} eq "attributes_results" ) {
        $html_to_print = $self->construct_attributes_results();
    }

    if ( $self->{type} eq "attribute_new" ) {
        $html_to_print = $self->construct_attribute_new();
    }

    if ( $self->{type} eq "users" ) {
        $html_to_print = $self->construct_users();
    }

    if ( $self->{type} eq "users_results" ) {
        $html_to_print = $self->construct_users_results();
    }

    if ( $self->{type} eq "user_new" ) {
        $html_to_print = $self->construct_user_new();
    }

    if ( $self->{type} eq "password_reset" ) {
        $html_to_print = $self->construct_password_reset_form();
    }

    return $html_to_print;
}

sub construct_where {
    my $self       = shift;
    my $use_equals = shift;
    my $force_id   = shift;

    my $where = "";

    foreach my $key ( keys %{ $self->{request}->{SearchFields} } ) {
        if (
            defined $self->{request}->{SearchFields}->{$key}
            && ( $self->{request}->{SearchFields}->{$key} ne ""
                || ( $force_id && $key eq "id" ) )
          )
        {
            if ($use_equals) {
                $where .=
                  " AND $key = '"
                  . $self->{request}->{SearchFields}->{$key} . "'";
            }
            else {
                $where .=
                  " AND $key LIKE '%"
                  . $self->{request}->{SearchFields}->{$key} . "%'";
            }
        }
    }

    $where = "( 1 = 1 )" . $where if $where;

    return $where;
}

sub construct_vars {
    my $self                 = shift;
    my $lookup_query_results = shift;

    my $sorted = {};
    my $count  = "0";

    foreach my $record ( @{$lookup_query_results} ) {
        $sorted->{$count} = $record;
        $count++;
    }

    return $sorted->{0} ? { 'data' => $sorted, 'has_data' => "true" } : {};
}

sub make_data {
    my $self          = shift;
    my $vars          = shift;
    my $template_file = shift;

    my $data;

    my $template = Template->new(
        {
            INCLUDE_PATH => '/var/www/html/templates'
        }
    );

    $template->process( $template_file, $vars, \$data )
      || die " Template processing failed : ", $template->error(), " \n ";

    return $data;
}

sub construct_left_menu {
    my $self = shift;

    return $self->make_data( {}, "left_menu.tt" );
}

sub construct_system_config {
    my $self = shift;

    return $self->make_data( {}, "system_config.tt" );
}

sub construct_system_config_results {
    my $self = shift;

    my $lookup_query_string =
      "SELECT id, name, display_name, value FROM system_config";

    my $lookup_query_results =
      $self->{DB}->run_query( $lookup_query_string, $self->construct_where() );

    my $vars = $self->construct_vars($lookup_query_results);

    return $self->make_data( $vars, "system_config_results.tt" );
}

sub construct_system_config_new {
    my $self = shift;

    my $lookup_query_string =
      "SELECT id, name, display_name, value FROM system_config";

    my $lookup_query_results =
      $self->{DB}->run_query( $lookup_query_string,
        $self->construct_where( "use_equals", "force_id" ) );

    my $vars = $self->construct_vars($lookup_query_results);

    return $self->make_data( $vars, "system_config_new.tt" );
}

sub construct_attributes {
    my $self = shift;

    return $self->make_data( {}, "attributes.tt" );
}

sub construct_attributes_results {
    my $self = shift;

    my $lookup_query_string = "SELECT id, name, description FROM attributes";

    my $lookup_query_results =
      $self->{DB}->run_query( $lookup_query_string, $self->construct_where() );

    my $vars = $self->construct_vars($lookup_query_results);

    return $self->make_data( $vars, "attributes_results.tt" );
}

sub construct_attribute_new {
    my $self = shift;

    my $lookup_query_string = "SELECT id, name, description FROM attributes";

    my $lookup_query_results =
      $self->{DB}
      ->run_query( $lookup_query_string, $self->construct_where("use_equals") );

    my $vars = $self->construct_vars($lookup_query_results);

    return $self->make_data( $vars, "attributes_new.tt" );
}

sub construct_users {
    my $self = shift;

    return $self->make_data( {}, "users.tt" );
}

sub construct_users_results {
    my $self = shift;

    my $lookup_query_string = "SELECT id, username, forename, surname FROM users";

    my $lookup_query_results =
      $self->{DB}->run_query( $lookup_query_string, $self->construct_where() );

    my $vars = $self->construct_vars($lookup_query_results);

    return $self->make_data( $vars, "users_results.tt" );
}

sub construct_user_new {
    my $self = shift;

    my $lookup_query_string = "SELECT id, username, forename, surname FROM users";

    my $lookup_query_results =
      $self->{DB}
      ->run_query( $lookup_query_string, $self->construct_where("use_equals") );

    my $vars = $self->construct_vars($lookup_query_results);

    return $self->make_data( $vars, "users_new.tt" );
}

sub construct_password_reset_form {
    my $self = shift;

    return $self->make_data( {}, "reset_password.tt" );
}

1;

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

    return $html_to_print;
}

sub construct_where {
    my $self       = shift;
    my $use_equals = shift;

    my $where = "";

    foreach my $key ( keys %{ $self->{request}->{SearchFields} } ) {
        if ( defined $self->{request}->{SearchFields}->{$key}
            && $self->{request}->{SearchFields}->{$key} ne "" )
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

    return $sorted ? { 'data' => $sorted } : {};
}

sub construct_left_menu {
    my $self = shift;

    my $left_menu;
    my $vars = {};

    my $template = Template->new(
        {
            INCLUDE_PATH => '/var/www/html/templates'
        }
    );

    $template->process( "left_menu.tt", $vars, \$left_menu )
      || die "Template processing failed : ", $template->error(), "\n";

    return $left_menu;
}

sub construct_system_config {
    my $self = shift;

    my $system_config;
    my $vars = {};

    my $template = Template->new(
        {
            INCLUDE_PATH => '/var/www/html/templates'
        }
    );

    $template->process( "system_config.tt", $vars, \$system_config )
      || die "Template processing failed : ", $template->error(), "\n";

    return $system_config;
}

sub construct_system_config_results {
    my $self = shift;

    my $lookup_query_string =
      "SELECT id, name, display_name, value FROM system_config";

    my $lookup_query_results =
      $self->{DB}->run_query( $lookup_query_string, $self->construct_where() );

    my $vars = $self->construct_vars($lookup_query_results);
    my $system_config_results;

    my $template = Template->new(
        {
            INCLUDE_PATH => '/var/www/html/templates'
        }
    );

    $template->process( "system_config_results.tt", $vars,
        \$system_config_results )
      || die "Template processing failed : ", $template->error(), "\n";

    return $system_config_results;
}

sub construct_system_config_new {
    my $self = shift;

    my $lookup_query_string =
      "SELECT id, name, display_name, value FROM system_config";

    my $lookup_query_results =
      $self->{DB}
      ->run_query( $lookup_query_string, $self->construct_where("use_equals") );

    my $vars = $self->construct_vars($lookup_query_results);
    my $system_config_new;

    my $template = Template->new(
        {
            INCLUDE_PATH => '/var/www/html/templates'
        }
    );

    $template->process( "system_config_new.tt", $vars, \$system_config_new )
      || die " Template processing failed : ", $template->error(), " \n ";

    return $system_config_new;
}

1;

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
    my $self = {};

    bless $self;

    return $self;
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
    my $self         = shift;
    my $db           = shift;
    my $searchfields = shift;

    my $lookup_query_string =
      "SELECT id, display_name, value FROM system_config WHERE 1 = 1";

    foreach my $key ( keys %{$searchfields} ) {
        if ( defined $searchfields->{$key} && $searchfields->{$key} ne "" ) {
            $lookup_query_string .=
              " AND $key LIKE '%" . $searchfields->{$key} . "%'";
        }
    }

    my $lookup_query = $db->prepare($lookup_query_string);
    $lookup_query->execute();
    my $lookup_query_results = $lookup_query->fetchall_arrayref( {} );

    my $sorted = {};
    my $count  = "0";

    foreach my $record ( @{$lookup_query_results} ) {
        $sorted->{$count} = $record;
        $count++;
    }

    my $vars = { 'data' => $sorted };
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
    my $db   = shift;

    my $placeholder_query_string =
      "INSERT INTO system_config SET autocreated = 'Y'";

    my $placeholder_query = $db->prepare($placeholder_query_string);
    $placeholder_query->execute();

    my $last_insert_id_query_string = "SELECT LAST_INSERT_ID() AS id";
    my $last_insert_id_query = $db->prepare($last_insert_id_query_string);
    $last_insert_id_query->execute();

    my $last_insert_id =
      $last_insert_id_query->fetchall_arrayref( {} )->[0]->{id};

    my $vars = { 'data' => $last_insert_id };

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

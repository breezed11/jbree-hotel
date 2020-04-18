#===============================================================================
#
#         FILE:  HotelDB
#
#        USAGE:  HotelDB->new();
#
#  DESCRIPTION:  Handles the DB connection and requests
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

package HotelDB;

use strict;
use warnings;

use DBI;

sub new {
    my $invocant = shift;
    my $class    = ref($invocant) || $invocant;
    my $self     = {@_};

    bless $self, $class;

    $self->create_db_connection();

    return $self;
}

sub create_db_connection {
    my $self = shift;

    my $dbi_driver =
        "DBI:mysql:"
      . $self->{config}->{database_name}
      . ";port=3306;mysql_connect_timeout=5";

    $self->{dbi} = DBI->connect(
        $dbi_driver,
        $self->{config}->{database_username},
        $self->{config}->{database_password},
        { TaintIn => 1, mysql_enable_utf8 => 1 }
    );
}

sub run_query {
    my $self         = shift;
    my $query_string = shift;
    my $where        = shift || "";
    my $joins        = shift || "";

    if ( defined $where && $where ne "" ) {
        $where = " WHERE " . $where;
    }

    my $query_string_collated = $query_string . " " . $joins . " " . $where;

    my $query = $self->{dbi}->prepare($query_string_collated);

    $query->execute();

    if (substr($query_string, 0, 6) eq "SELECT") {
        return $query->fetchall_arrayref( {} );
    }
    return 1;
}

1;

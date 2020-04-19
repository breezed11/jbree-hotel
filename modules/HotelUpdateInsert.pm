#===============================================================================
#
#         FILE:  HotelUpdateInsert
#
#        USAGE:  HotelUpdateInsert->new();
#
#  DESCRIPTION:  Handles inserting and updating records
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

package HotelUpdateInsert;

use strict;
use warnings;

sub new {
    my $invocant = shift;
    my $class    = ref($invocant) || $invocant;
    my $self     = {@_};

    bless $self, $class;

    return $self;
}

sub update_insert_record {
    my $self = shift;

    my $to_print;

    if ( $self->{type} eq "updateinsert_system_config_save" ) {
        $to_print = $self->update_insert("system_config");
    }

    if ( $self->{type} eq "updateinsert_attribute" ) {
        $to_print = $self->update_insert("attributes");
    }

    if ( $self->{type} eq "updateinsert_user" ) {
        $to_print = $self->update_insert("users");
    }

    return $to_print;
}

sub construct_set {
    my $self = shift;

    my $set = "";

    foreach my $key ( keys %{ $self->{request}->{NewEditFields} } ) {
        if ( $key eq "pw" ) {
            $self->{request}->{NewEditFields}->{$key} = $self->{auth}
              ->encrypt_password( $self->{request}->{NewEditFields}->{$key} );
        }

        $set .= (
            $set
            ? ","
            : "SET "
          )
          . " $key = '"
          . $self->{request}->{NewEditFields}->{$key} . "'"
          unless $key eq "id" || $key eq "";
    }

    return $set;
}

sub update_insert {
    my $self  = shift;
    my $table = shift;

    my $query_string = "";

    if ( $self->{request}->{DeleteRecord} ) {
        $query_string = "DELETE FROM $table WHERE id = "
          . $self->{request}->{DeleteRecord}->{id};
    }
    else {
        if ( $self->{request}->{NewEditFields}->{id} ) {
            $query_string =
                "UPDATE $table "
              . $self->construct_set()
              . " WHERE id = '"
              . $self->{request}->{NewEditFields}->{id} . "'";
        }
        else {
            $query_string = "INSERT INTO $table " . $self->construct_set();
        }
    }

    $self->{DB}->run_query($query_string);

    return $self->{DB}->run_query("SELECT LAST_INSERT_ID() AS id")->[0]->{id};
}

1;

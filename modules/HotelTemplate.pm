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

use Template::Toolkit;

#################### subroutine header begin ####################

=head2 new

 Usage     : new()
 Purpose   : Constructs an object to handle templates
 Returns   : A HotelTemplate object
 Argument  : Nothing
 Throws    : 
 Comment   : 

See Also   :

=cut

#################### subroutine header end ####################

sub new {
    my $self = {};

    bless $self;

    return $self;
}

#################### subroutine header begin ####################

=head2 construct_left_menu

 Usage     : $self->construct_left_menu(db)
 Purpose   : Constructs the HTML for the left menu
 Returns   : Raw HTML
 Argument  : db
 Throws    : 
 Comment   : 

See Also   :

=cut

#################### subroutine header end ####################

sub construct_left_menu {
    my $self = shift;
    my $db   = shift;
}
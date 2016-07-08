package PageObject::App::AR::Invoice::Lines;

use strict;
use warnings;

use Carp;
use PageObject;
use PageObject::App::AR::Invoice::Line;

use Moose;
extends 'PageObject';

__PACKAGE__->self_register(
              'invoice-lines',
              './/table[@id="invoice-lines"]',
              tag_name => 'table',
              attributes => {
                  id => 'invoice-lines',
              });

sub _verify {
    my ($self) = @_;

    return $self;
}

sub lines {
    my ($self) = @_;

    return $self->find_all('*invoice-line');
}

__PACKAGE__->meta->make_immutable;

1;

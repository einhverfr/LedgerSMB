package PageObject::App::AR::Invoice;

use strict;
use warnings;

use Carp;
use PageObject;
use PageObject::App::AR::Invoice::Lines;

use Moose;
extends 'PageObject';

__PACKAGE__->self_register(
              'ar-invoice',
              './/div[@id="AR-invoice"]',
              tag_name => 'div',
              attributes => {
                  id => 'AR-invoice',
              });



sub _verify {
    my ($self) = @_;

    return $self;
}

sub select_customer {
    my ($self, $customer) = @_;

    $self->verify;
    my $elem = $self->find("*labeled", text => "Customer");

    $elem->clear;
    $elem->send_keys($customer);

    $self->find("*button", text => "Update")->click;
    $self->session->page->body->maindiv->wait_for_content;
}

sub lines {
    my ($self) = @_;

    return $self->find('*invoice-lines')->lines;
}

__PACKAGE__->meta->make_immutable;

1;

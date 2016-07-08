package PageObject::App::AR::Invoice::Line;

use strict;
use warnings;

use Carp;
use PageObject;

use Moose;
extends 'PageObject';

__PACKAGE__->self_register(
              'invoice-line',
              './/tbody[@data-dojo-type="lsmb/InvoiceLine"]',
              tag_name => 'tbody',
              attributes => {
                  'data-dojo-type' => 'lsmb/InvoiceLine',
              });

has line_no => (is => 'ro',
                isa => 'Num',
                lazy => 1,
                builder => '_build_line_no');

sub _build_line_no {
    my ($self) = @_;
    my $id = $self->get_attribute('id');
    $id =~ m/line-(\d+)/;
    return $1;
}

sub _verify {
    my ($self) = @_;

    return $self;
}

sub get_property {
    my ($self, $name) = @_;
    my $num = $self->line_no;

    ###@@@TODO: This works except for with the textareas (description, ...)
    return $self->find(".//*[\@id='${name}_$num']");
}

sub get_property_value {
    my ($self, $name) = @_;
    return $self->get_property($name)->get_attribute('value');
}

my %header_map = (
    'Item' => 'runningnumber',
    'Number' => 'partnumber',
    'Description' => 'description',
    'Qty' => 'qty',
    'Unit' => 'unit',
    'OH' => 'onhand',
    'Price' => 'sellprice',
    '%' => 'discount',
    'Extended' => 'linetotal',
    'TaxForm' => 'taxformcheck',
    'Delivery Date' => 'deliverydate',
    'Notes' => 'notes',
    # Serial No.
    );

sub get_value {
    my ($self, $header) = @_;
    my $id = $header_map{$header};
    my $num = $self->line_no;
    return $self->find(".//*[\@id='${id}_$num']")->get_attribute('value');
}

sub is_empty {
    my ($self) = @_;
    my $num = $self->line_no;

    return ! $self->get_property_value('id');
}

__PACKAGE__->meta->make_immutable;

1;

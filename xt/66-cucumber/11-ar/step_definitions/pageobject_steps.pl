#!perl


use lib 't/lib';
use strict;
use warnings;

use LedgerSMB::App_State;
use LedgerSMB::Database;
use LedgerSMB::Entity::Person::Employee;
use LedgerSMB::Entity::User;
use LedgerSMB::PGDate;
use Selenium::Remote::WDKeys;

use Module::Runtime qw(use_module);
use PageObject::App::Login;

use Test::More;
use Test::BDD::Cucumber::StepFile;


use Data::Dumper;


When qr/I open the sales invoice entry screen/, sub {
    my @path = split /[\n\s\t]*>[\n\s\t]*/, 'AR > Sales Invoice';

    S->{ext_wsl}->page->body->menu->click_menu(\@path);
    S->{ext_wsl}->page->body->maindiv->wait_for_content;
};

When qr/I open the AR transaction entry screen/, sub {
    my @path = split /[\n\s\t]*>[\n\s\t]*/, 'AR > Sales Invoice';

    S->{ext_wsl}->page->body->menu->click_menu(\@path);
    S->{ext_wsl}->page->body->maindiv->wait_for_content;
};

When qr/I select customer "(.*)"/, sub {
    my $customer = $1;

    my $page = S->{ext_wsl}->page->body->maindiv->content;
    $page->select_customer($customer);

};

When qr/I select (part|service) "(.+)" on (the empty line|empty line (\d+))/,
    sub {
        my $type = $1;
        my $partname = $2;
        my $empty_line_no = $4 // 1;
        my $invoice = S->{ext_wsl}->page->body->maindiv->content;
        my @lines = grep { $_->is_empty } @{$invoice->lines};
        my $empty = $lines[$empty_line_no - 1];
        my $part_selector = $empty->get_property('partnumber');
        $part_selector->click;
        $part_selector->clear;
        $part_selector->send_keys($partname);
        ###@@@TODO wait-for-popup, instead of sleep 1
        sleep 1;
        $part_selector->send_keys(KEYS->{tab});
        ###@@@TODO: TAB confirms the top row (which should now be the only one)
};

Then qr/I expect to see an invoice with (these|(\d+) empty) lines?/, sub {
    my $type = $1;
    my $empty_lines = $2;
    my $invoice = S->{ext_wsl}->page->body->maindiv->content;
    my @lines =  @{$invoice->lines};
    my @empty_lines = grep { $_->is_empty } @lines;

    # the definition of an empty line is: no partnumber, empty description,
    #   Qty = 0, Unit empty, OH empty, Price = 0.00, % = 0,
    #   extended = 0.00, Delivery Date empty, notes_* empty,
    #   serialnumber_* empty
    if ($type ne 'these') {
        is(scalar(@empty_lines), $empty_lines, 'Number of empty lines matches');
        return;
    }

    my @keys = keys %{${C->data}[0]};
    # foreach my $line (@{C->data}) {
    #     foreach my $key (keys %$line) {
    #         $line->{$key} =~ s/^\s+|\s+$//g;
    #     }
    # }
    my @actual =
        map { my $line = $_;
              my %row = map { $_ => $line->get_value($_)  }  @keys;
              \%row }
        @lines;

    is_deeply(\@actual, C->data, "Invoice lines show expected data on");
};

1;

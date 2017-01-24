package LedgerSMB::PAIN;

use parent 'LedgerSMB::DBObject';
use LedgerSMB::Setting;
use List::Util qw(sum);

sub get_payment_batch {
    my ($self, $id) = @_;
    my @list = $self->call_procedure(procname => 'voucher__list', args => [ $id ]); 
    for $ref (@list) {
        my ($invoice) = $self->call_procedure(procname => 'invnumber__get', arg => [ $ref->{transaction_id} ]);
        my ($eca) = $self->call_procedure(procname => 'entity_credit__get', arg => [ $invoice->{entity_credit_account} ]);
        my ($entity) = $self->call_procedure(procname => 'entity__get', arg => [ $eca->{entity_id} ]);
        my ($entity) = $self->call_procedure(procname => 'entity__get', arg => [ $eca->{entity_id} ]);
        my ($address) = grep { $_->{location_class} == 1 } $self->call_procedure(procname => 'eca__list_locations', arg => [ $eca->{id} ]);
        my ($bank_acct) = $self->call_procedure(procname => 'entity_bank_account__get', arg => [ $eca->{bank_account_id} ]);

        $ref->{entity} = {
           name => $entity->{name}, 
           bic => $bank_acct->{bic},
           iban => $bank_acct->{iban},
           lines => [ grep {defined $_ } map {$address->{$_} } 
		      qw(line_one line_two line_three) ],
        };
	$ref->{invoice} = {
           invnumber => $invoice->{invnumber},
           invdate   => $invoice->{invdate},
        };
   }
    return \@list;
}

sub get_pain_info {
    my ($self, $id);
    my $pain = {};
    bless $pain, $self;
    $pain->{company} = { 
           map { $_ => LedgerSMB::Setting->get("pain_$_")->value }
           qw( companyname streetname buildingnumber postcode coty country )
    };
    $pain->{company}->{account} = {
           map { $_ => LedgerSMB::Setting->get("pain_$_")->value }
           qw( bic ban )
    };
    $pain->{processtime} = _get_nowstring();
    $pain->{payments} = get_payment_batch($id);
    $pain->{fx_sum} = sum(map{$_->{amount}} @{$pain->{payments}});
    return $pain;
}

1;

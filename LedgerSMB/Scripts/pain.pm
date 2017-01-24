package LedgerSMB::Scripts::pain;
use LedgerSMB::Pain;

sub pain_xml {
    my ($request) = @_;
    my $pain = PAIN->get_info($request->{id});
    my $template = LedgerSMB::Template->new(
       user     => $request->{_user},
       locale   => $request->{_locale},
       path     => 'UI/payments',
       template => 'payments_filter',
       format   => 'HTML',
    );
    $template->render($pain);
}

1;

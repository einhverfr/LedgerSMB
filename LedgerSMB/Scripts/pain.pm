package LedgerSMB::Scripts::pain;
use LedgerSMB::PAIN;

sub pain_xml {
    my ($request) = @_;
    my $pain = PAIN->get_info($request->{id});
    my $template = LedgerSMB::Template->new(
       user     => $request->{_user},
       locale   => $request->{_locale},
       path     => 'UI/payments',
       template => 'pain001-template',
       format   => 'XML',
    );
    $template->render($pain);
}

1;

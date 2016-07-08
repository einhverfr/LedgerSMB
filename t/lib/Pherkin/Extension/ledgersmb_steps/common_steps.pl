#!perl


use strict;
use warnings;

use LedgerSMB::Entity::Company;
use LedgerSMB::Entity::Credit_Account;

use Test::More;
use Test::BDD::Cucumber::StepFile;



my $company_seq = 0;

Given qr/a (fresh )?standard test company/, sub {
    my $fresh_required = $1;

    S->{ext_lsmb}->ensure_template;

    if (! S->{"the company"} || $fresh_required) {
        my $company = "standard-" . $company_seq++;
        S->{ext_lsmb}->create_from_template($company);
    }
};

Given qr/(a nonexistent|an existing) company named "(.*)"/, sub {
    my $company = $2;
    S->{"the company"} = $company;
    S->{"nonexistent company"} = ($1 eq 'a nonexistent');

    S->{ext_lsmb}->ensure_nonexisting_company($company)
        if S->{'nonexistent company'};
};

Given qr/(a nonexistent|an existing) user named "(.*)"/, sub {
    my $role = $2;
    S->{"the user"} = $role;
    S->{'nonexistent user'} = ($1 eq 'a nonexistent');

    S->{ext_lsmb}->ensure_nonexisting_user($role)
        if S->{'nonexistent user'};
};

Given qr/books closed as per (.{10})/, sub {
    my $closing_date = $1;

    my $dbh = S->{ext_lsmb}->admin_dbh;
    $dbh->do("SELECT eoy_reopen_books_at(?)", {}, $closing_date)
        or die $dbh->errstr;
    $dbh->do("SELECT eoy_create_checkpoint(?)", {}, $closing_date)
        or die $dbh->errstr;
};

Then qr/I can't post a transaction on (.{10})/, sub {
    my $posting_date = $1;

    S->{ext_lsmb}->assert_closed_posting_date($posting_date);
};

Given qr/the following GL transaction posted on (.{10})/, sub {
    S->{ext_lsmb}->post_transaction($1, C->data);
};

When qr/I post the following GL transaction on (.{10})/, sub {
    S->{ext_lsmb}->post_transaction($1, C->data);
};


Given qr/a customer named "(.*)"/, sub {
    my $customer = $1;

    # The TODO below is a consequence of being unable to connect to
    # our database with different credentials in a single process:
    #  the environment contains PGUSER='postgres', but the username
    #  was set to 'test-user-admin' -- yet the postgres value is used
    my $dbh = LedgerSMB::Database->new(
        dbname => S->{"the company"},
        usermame => $ENV{PGUSER},     ###TODO: we had 'S->{"the admin"}
        password => $ENV{PGPASSWORD}, ### but that didn't work
        host => 'localhost')
        ->connect({ PrintError => 0, RaiseError => 1, AutoCommit => 0 });

    my $company = LedgerSMB::Entity::Company->new(
        # fields from Entity
        control_code => 'C001',
        name         => $customer,
        country_id   => 232, # United States
        entity_class => 2, # customers
        # fields from Company
        legal_name   => $customer,

        # internal fields
        _DBH         => $dbh,
        );
    $company = $company->save;


    # work around the fact that the ECA api is unusable outside of the
    # realm of the web-application: it depends on LedgerSMB::PGObject
    # which directly accesses LedgerSMB::App_State (which is global state
    # we don't want to use here.
    ###TODO: So, not using LedgerSMB::Entity::Credit_Account here...
    # my $eca = LedgerSMB::Entity::Credit_Account->new(
    #     entity_id        => $company->id,
    #     entity_class     => 2, # customers
    #     ar_ap_account_id => 3,
    #     curr             => 'USD',

    #     # internal fields
    #     _DBH             => $dbh,
    #     );
    # $eca->save;

    $dbh->do(qq(INSERT INTO
        entity_credit_account (entity_id, entity_class, ar_ap_account_id,
                               curr, meta_number)
        VALUES (?, ?, ?, ?, ?)), {}, $company->id, 2, 3, 'USD', 'M001');
    $dbh->commit;

};


Given qr/a service "(.*)"/, sub {
    my $service = $1;

    my $dbh = S->{ext_lsmb}->admin_dbh;
    my $sth = $dbh->prepare(qq|
INSERT INTO parts (partnumber, description, unit, listprice, sellprice,
                   lastcost, weight, notes, income_accno_id,
                   expense_accno_id)
           VALUES (?, ?, '', 0, 0,
                   0, 0, '', (select id from account join account_link al
                                on account.id = al.account_id
                              where al.description = 'IC_income' limit 1),
                   (select id from account join account_link al
                                on account.id = al.account_id
                              where al.description = 'IC_expense' limit 1))
|);
    $sth->execute($service, $service);
};



Given qr/a part "(.*)"/, sub {
    my $part = $1;

    my $dbh = S->{ext_lsmb}->admin_dbh;
    my $sth = $dbh->prepare(qq|
INSERT INTO parts (partnumber, description, unit, listprice, sellprice,
                   lastcost, weight, notes, inventory_accno_id,
                   income_accno_id,
                   expense_accno_id)
           VALUES (?, ?, '', 0, 0,
                   0, 0, '',
                   (select id from account join account_link al
                                on account.id = al.account_id
                              where al.description = 'IC' limit 1),
                   (select id from account join account_link al
                                on account.id = al.account_id
                              where al.description = 'IC_income' limit 1),
                   (select id from account join account_link al
                                on account.id = al.account_id
                              where al.description = 'IC_expense' limit 1))
|);
    $sth->execute($part, $part);
};


1;

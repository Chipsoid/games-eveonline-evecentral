#!perl

BEGIN { chdir 't' if -d 't' }

use lib 'lib';

use Test::More tests => 2;
use Test::Mock::Class 0.0303 qw(:all);

use Games::EveOnline::EveCentral;
use Games::EveOnline::EveCentral::Request::QuickLook;

use Games::EveOnline::EveCentral::Tests qw(fake_http_response);
require LWP::UserAgent::Determined;

mock_class 'LWP::UserAgent::Determined' => 'LWP::UserAgent::Determined::Mock';
my $lwp = LWP::UserAgent::Determined::Mock->new;
$lwp->mock_return(
  get => fake_http_response('res/quicklook.xml'), args => [qr//]
);

my $client = Games::EveOnline::EveCentral->new(ua => $lwp);
isa_ok($client, 'Games::EveOnline::EveCentral');

my $xml = $client->marketstat(
  Games::EveOnline::EveCentral::Request::QuickLook->new(
    type_id => 34
  )->request
);
my $parser = $client->libxml;
my $doc = $parser->parse_string($xml);
my $type_id = $doc->findvalue('//quicklook/item/text()');
is(scalar $type_id, '34');

$lwp->mock_tally;

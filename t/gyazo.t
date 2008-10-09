use strict;
use warnings;
use Test::More tests => 4;

require 'gyazo.pl'; ## no critic

is(create_uri('aaa/bbb.png',
              { SERVER_NAME => 'localhost',
                SERVER_PORT => 80,
                REQUEST_URI => '/gyazo.pl' }),
   'http://localhost/aaa/bbb.png');

is(create_uri('ccc/ddd.png',
              { SERVER_NAME => 'example.com',
                SERVER_PORT => 3000,
                REQUEST_URI => '/~alice/gyazo.pl' }),
   'http://example.com:3000/~alice/ccc/ddd.png');

my $dbh = open_database("/tmp/database.$$");
ok($dbh);

srand(0);
is(create_alias(8), '6q3vksodv');

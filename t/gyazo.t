use strict;
use warnings;
use Test::More tests => 6;

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

my $st = $dbh->prepare('select * from schema_info');
$st->execute();
is_deeply($st->fetchrow_hashref, { version => 1 });

srand(0);
is(create_alias(8), 'aK5RzMGm');
is(length create_alias(8), 8);

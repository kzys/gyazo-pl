use strict;
use warnings;
use Test::More tests => 2;

require 'gyazo.pl'; ## no critic

is(create_uri({ SERVER_NAME => 'localhost',
                SERVER_PORT => 80,
                REQUEST_URI => '/gyazo.pl' }),
   'http://localhost/gyazo.pl');

is(create_uri({ SERVER_NAME => 'example.com',
                SERVER_PORT => 3000,
                REQUEST_URI => '/~alice/gyazo.pl' }),
   'http://example.com:3000/~alice/gyazo.pl');

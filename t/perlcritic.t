use strict;
use Test::More;

eval {
    require Test::Perl::Critic;
    Test::Perl::Critic->import;
};
if ($@) {
    plan skip_all => 'Test::Perl::Critic is not installed.';
}

all_critic_ok('.');

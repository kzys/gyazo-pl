#! /usr/bin/perl
use strict;
use warnings;

use CGI;
use Digest::MD5;
use Path::Class;
use URI;
use DBI;

my @ALIAS_CHARS = ('0'...'9', 'a'...'z', 'A'...'Z');
my $ALIAS_LENGTH = 4;

sub create_database {
    my ($fn) = @_;

    open(my $pipe, "| sqlite3 $fn"); ## no critic
    print $pipe <<END;
create table schema_info (version);
insert into schema_info (version) values (0);

create table entries (digest, type, user, alias);

update schema_info set version = 1;
END
    close($pipe);
}

sub open_database {
    my ($fn) = @_;

    if (! -f $fn) {
        create_database($fn);
    }

    return DBI->connect("dbi:SQLite:dbname=$fn");
}

sub create_uri {
    my ($path, $env_ref) = @_;

    if (! $env_ref) {
        $env_ref = \%ENV;
    }

    my $port = $env_ref->{SERVER_PORT};
    if ($port != 80) {
        $port = ":$port";
    } else {
        $port = "";
    }

    my $uri = URI->new(join('',
                            'http://', $env_ref->{SERVER_NAME}, $port,
                            $env_ref->{REQUEST_URI}));
    return URI->new_abs($path, $uri);
}

sub create_alias {
    my ($max) = @_;

    my $n = scalar @ALIAS_CHARS;
    join '', map { $ALIAS_CHARS[ int(rand($n)) ]; } (1...$max);
}

sub save_file {
    my ($args_ref) = @_;
    my $data = $args_ref->{data};

    if (! $data) {
        die "Invalid arguments (imagedata).";
    }

    my $digest = Digest::MD5::md5_hex($data);
    my $alias = create_alias($ALIAS_LENGTH);

    my $dbh = open_database('data/index.db');
    $dbh->prepare(
        'insert into entries (digest, type, user, alias) values (?, "image/png", ?, ?)'
        )->execute($digest, $args_ref->{id}, $alias);
    $dbh->disconnect;

    my $path = file(file(__FILE__)->dir, "data/$digest.png");
    my $file = $path->openw;
    print $file $data;
    close($file);

    return create_uri("?_=$alias");
}

sub query_with_alias {
    my ($fn) = @_;
    my $dbh = open_database($fn);

    my $st = $dbh->prepare('select * from entries where alias=?');
    $st->execute($alias);

    my $row = $st->fetchrow_hashref;
    return $row->{type}, $row->{digest};
}

sub entry_from_alias {
    my ($alias) = @_;

    my ($type, $digest) = query_with_alias('data/index.db', $alias);

    my $suffix = $type eq 'image/png' ? 'png' : 'unknown';
    my $path = file(file(__FILE__)->dir, "data/$digest.$suffix");

    return $type, scalar $path->slurp;
}

if (__FILE__ eq $0) {
    my $cgi = CGI->new;

    my $imagedata = $cgi->param('imagedata');

    if ($imagedata) {
        my $uri = eval {
            save_file({ id => $cgi->param('id'), data => $imagedata });
        };

        print $cgi->header('text/plain');
        if (! $@) {
            print "$uri";
        } else {
            print STDERR "Error: $@";
            print "Error: $@";
        }
    } elsif (my $alias = $cgi->param('_')) {
        my ($type, $content) = entry_from_alias($alias);
        print $cgi->header($type);
        print $content;
    }
}

1;

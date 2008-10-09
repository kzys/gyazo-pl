#! /usr/bin/perl
use strict;
use warnings;

use CGI;
use Digest::MD5;
use Path::Class;
use URI;

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

sub save_file {
    my ($data) = @_;
    if (! $data) {
        die "Invalid arguments (imagedata).";
    }

    my $digest = Digest::MD5::md5_hex($data);

    my $path = file(file(__FILE__)->dir, "data/$digest.png");
    my $file = $path->openw;
    print $file $data;
    close($file);

    return create_uri("data/$digest.png");
}

if (__FILE__ eq $0) {
    my $cgi = CGI->new;
    my $id = $cgi->param('id'); # TODO: not used now.

    my $uri = eval {
        save_file($cgi->param('imagedata'));
    };

    print $cgi->header('text/plain');
    if (! $@) {
        print "$uri";
    } else {
        print STDERR "Error: $@";
        print "Error: $@";
    }
}

1;

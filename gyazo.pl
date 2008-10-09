#! /usr/bin/perl
use strict;
use warnings;

use CGI;
use Digest::MD5;
use Path::Class;

sub create_uri {
    my ($env_ref) = @_;

    my $port = $env_ref->{SERVER_PORT};
    if ($port != 80) {
        $port = ":$port";
    } else {
        $port = "";
    }

    return join('', 'http://', $env_ref->{SERVER_NAME}, $port, $env_ref->{REQUEST_URI});
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

    return file(file(create_uri())->dir, "data/$digest.png");
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

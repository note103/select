#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

my @list;
my $files;
my $record;
my @result;
my @path;
my @choosed;
my @prev = ();
my $selector = "cho";
my $dot = "";
my $tail = "";
my $command = "echo";

my @arg = @ARGV;

if (scalar(@arg) > 0) {
    for (@arg) {
        if ($_ =~ /(-a|-p)/) {
            if ($_ =~ /p/) {
                $selector = "peco";
            }
            if ($_ =~ /a/) {
                $dot = $_;
            }
        }
        elsif ($_ =~ /-t=(.+)/) {
            $tail = "$1";
        }
        else {
            $command = $_;
        }
    }
}

my $list;
if ($dot eq "") {
    $list = `ls -F`;
    @list = split /\n/, $list;
}
else {
    $list = `ls -aF`;
    @list = split /\n/, $list;
    @list = grep {$_ ne "." && $_ ne ".."} @list;
}

main (\@list, \@result);

sub main {
    my ($list, $result) = @_;
    @list = @$list;
    @result = @$result;

    $files = join " ", @list;

    $record = `(for s in exit "do" $files; do echo \$s; done | $selector | tr -d "\n")`;

    if ( $record eq "exit" ) {
        exit;
    }
    elsif ( $record eq "do" ) {
        ;
    } else {
        push @result, $record;
    }

    for my $x (@prev) {
        if ($x =~ /\+ (.+)\z/) {
            my $foo = $1;
            if ($foo eq $record) {
                @result = grep {$_ ne $foo} @result;
            }
        }
    }

    @prev = @list;
    for my $p (@prev) {
        for my $r (@result) {
            if ($p eq $r) {
                $p = "+ $p";
            }
        }
    }

    for (@prev) {
        unless ($_ =~ /\A\+/) {
            say "  $_";
        }
        else {
            say $_;
        }
    }

    say "\nok? [y/N]";

    my $buffer = join " ", @result;
    my $pwd = `pwd | tr -d "\n"`;
    @path = map {"$pwd/$_"} @result;

    if ($tail ne "") {
        say "$command $buffer $tail";
    }
    else {
        say "$command $buffer";
    }
    my $res = <STDIN>;
    chomp $res;

    if ($res =~ /\A(yes|y)\z/i) {
        say "";
        if ($tail ne "") {
            print `$command @path $tail`;
        }
        else {
            print `$command @path`;
        }
    }
    else {
        main (\@list, \@result);
    }
}

#!/usr/bin/perl

use Test::More tests=> 1;

use_ok('Clicom::List', qw/new execute/);
my @arrlist= qw(/home/anton/tmp 2);
my @arrcopy= qw(/home/anton/tmp 2 /home/anton/a.brekhov/hw/client.pl /home/anton/tmp/cl32);
my $list = List->new(@arrlist);
can_ok($list, qw(execute));

use_ok('Clicom::Copy', qw/new execute/);
my @arrcopy= qw(/home/anton/tmp 2 /home/anton/a.brekhov/hw/client.pl /home/anton/tmp/cl32);
my $copy = Copy->new(@arrcopy);
can_ok($copy, qw(execute));

use_ok('Clicom::Move', qw/new execute/);
my @arrcopy= qw(/home/anton/tmp 2 /home/anton/tmp/cl32 /home/anton/tmp/cl);
my $copy = Move->new(@arrcopy);
can_ok($copy, qw(execute));


use_ok('Clicom::Remove', qw/new execute/);

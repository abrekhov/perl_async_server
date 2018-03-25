#!/usr/bin/perl

use warnings;
no warnings 'uninitialized';
use strict;
use 5.016;


{
package List;

	sub new{
		my $class = shift;
		my $currpath = shift;
		my $verbose = shift;
		my $self = bless{
			currpath=>$currpath,
			verbose=>$verbose,
			files=>[@_]
		}, $class;
		return $self;	
	}
	#Commands functions
	sub execute{
		my $self =shift;
		say $self->{files}->[0];
		say "debug: List of files(ls)" if $self->{verbose}>0;
		say "debug2: qx(ls -lA $self->{currpath}/$self->{files}[0])" if $self->{verbose}>1;
		return qx(ls -lA $self->{currpath}/$self->{files}[0]);
	}
}

1;

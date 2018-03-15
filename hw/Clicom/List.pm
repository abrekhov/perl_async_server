#!/usr/bin/perl

use warnings;
use strict;
use 5.016;


{
package List;

	sub new{
		my $class = shift;
		my ($currpath, $verbose) = @_;
		my $self = bless{
			currpath=>$currpath,
			verbose=>$verbose
		}, $class;
		return $self;	
	}
	#Commands functions
	sub execute{
		my $self =shift;
		say "debug: List of files(ls)" if $self->{verbose}>0;
		say "debug2: qx(ls -lA $self->{currpath})" if $self->{verbose}>1;
		return qx(ls -lA $self->{currpath});
	}
}

1;

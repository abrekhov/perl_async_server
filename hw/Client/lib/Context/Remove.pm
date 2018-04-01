#!/bin/perl

use 5.016;

{
package Remove;
	sub new{
		my $class = shift;
		my ($currpath, $verbose, $file) = @_;
		my $self = bless{
			file=>$file,
			currpath=>$currpath,
			verbose=>$verbose
		}, $class;
		return $self;	
	}

	sub execute{
		my $self=shift;
      		say "debug: Removing $self->{file}(rm)" if $self->{verbose}>0;
      		say "debug2: unlink $self->{currpath}/$self->{file}" if $self->{verbose}>1;
      		unlink $self->{currpath}."/".$self->{file}; 
	}
}
1;

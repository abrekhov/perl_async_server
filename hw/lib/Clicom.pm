#!/usr/bin/perl

use warnings;
use strict;
use 5.016;

{
package List;

	sub new{
		my $class = shift;
		my ($currpath, $path, $verbose) = @_;
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

{
package Remove;
	sub new{
		my $class = shift;
		my ($currpath, $file, $verbose) = @_;
		my $self = bless{
			currpath=>$currpath,
			file=>$file,
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

{
package Move;
	sub new{
		my $class = shift;
		my ($currpath, $file1, $file2, $verbose) = @_;
		my $self = bless{
			currpath=>$currpath,
			file1=>$file1,
			file2=>$file2,
			verbose=>$verbose
		}, $class;
		return $self;	
	}


	sub execute{
		my $self = shift;
		say "debug: Renaming $self->{file1} in $self->{file2} (mv)" if $self->{verbose}>0;
		say "debug2: rename currpath/$self->{file1} , $self->{currpath}/$self->{file2}" if $self->{verbose}>1;
		rename $self->{currpath}."/".$self->{file1} , $self->{currpath}."/".$self->{file2};
	}
}

{
package Copy;
	sub new
	{
		my $class = shift;
		my ($currpath, $file1, $file2, $verbose) = @_;
		my $self = bless{
			currpath=>$currpath,
			file1=>$file1,
			file2=>$file2,
			verbose=>$verbose
		}, $class;
		return $self;	
	}

	sub execute
	{
		my $self=shift;
		say "debug: Copying $self->{file1} in $self->{currpath}/$self->{file2} (cp)" if $self->{verbose}>0;
		say "debug2: qx(cp $self->{file1} $self->{currpath}/$self->{file2})" if $self->{verbose}>1;
		return qx(cp $self->{file1} $self->{currpath}/$self->{file2});
	}	

}
1;

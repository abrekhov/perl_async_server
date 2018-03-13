#!/usr/bin/perl

use warnings;
use strict;
use 5.016;

package Local;

#Commands functions
sub ls{
	say "debug: List of files(ls)" if $verbose>0;
	say "debug2: qx(ls -lA $currpath)" if $verbose>1;
	return qx(ls -lA $currpath);
}
sub rm{
	say "debug: Removing $_[1](rm)" if $verbose>0;
	say "debug2: unlink $currpath/$_[1]" if $verbose>1;
	unlink $currpath."/".$_[1]; 
}
sub mv{
	say "debug: Renaming $_[1] in $_[2] (mv)" if $verbose>0;
	say "debug2: rename currpath/$_[1] , $currpath/$_[2]" if $verbose>1;
	rename $currpath."/".$_[1] , $currpath."/".$_[2];

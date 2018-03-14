#!/usr/bin/perl

use Getopt::Long;
use Pod::Usage;
use Term::ReadLine;
use DDP;
use lib::Clicom;
use warnings;
use strict;
use 5.016;


#Options
my $verbose=0;
my $instructions = <<EOF;
Usage:
	client.pl [-h] [-v] /path/to/somewhere
	-h | --help - say usage and exit
	-v | --verbose - be verbose	
EOF


Getopt::Long::Configure('bundling');
GetOptions(
	'v|verbose+'=>\$verbose,
	'h|help'=>sub{ die($instructions); }
);

say "Verbose level: $verbose" if $verbose ;

#Checking all modules
say "Included modules:" if $verbose>1;
p %INC if $verbose>1;


#Absolute path init
say "Arguments:[".join(',',@ARGV)."]" if $verbose;
my $cpath = $ARGV[0] or die $instructions;
my $currpath = qx(cd $cpath && pwd);
chomp $currpath; 
say "Absolute path:".$currpath."..." if $verbose;

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
}
sub cp{
	say "debug: Copying $_[1] in $currpath/$_[2] (cp)" if $verbose>0;
	say "debug2: qx(cp $_[1] $currpath/$_[2])" if $verbose>1;
	return qx(cp $_[1] $currpath/$_[2]);
}

#Commands init
my %commands = (
	'ls'=>sub{ 
		my $obj=lib::Clicom::List->(@_);
		$obj->execute();       	
	},
	'cp'=>\&cp,
	'mv'=>\&mv,
	'rm'=>\&rm,
);

my $term = Term::ReadLine->new('Perl local client ');
my $prompt = "> ";
$term->read_history();
my $attribs = $term->Attribs;
$attribs->{completion_entry_function} = $attribs->{list_completion_function};
$attribs->{completion_word}=[keys %commands];
my $OUT = $term->OUT || \*STDOUT;
while ( defined ($_ = $term->readline($prompt)) ) {

	my $res="";
	if (/^\!(.*)/){
		$res= qx($1);
	}
	elsif(/^$/){
		$res = $_;
	}
	elsif(/^\s*exit\s*$/){
		say "Exitting client..." if $verbose>0;
		$term->write_history();
		exit;
	}
	else{
		my @args = split /\s+/, $_;
		eval{
			$res = $commands{$args[0]}->(@args); 	
		 } or say "This version support only: ".join(", ",keys %commands)." functions.";
		

	}
	say $OUT $res unless $@;
}




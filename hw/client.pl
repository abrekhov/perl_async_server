#!/usr/bin/perl

use Getopt::Long;
use Pod::Usage;
use Term::ReadLine;
use DDP;
use Clicom::List;
use Clicom::Copy;
use Clicom::Remove;
use Clicom::Move;
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



#Commands init
my %commands = (
	'ls'=>sub{
		my $obj=List->new(@_);
		$obj->execute();       	
	},
	'cp'=>sub{
		my $obj=Copy->new(@_);
		$obj->execute();       	
	},
	'mv'=>sub{
		my $obj=Move->new(@_);
		$obj->execute();       	
	},
	'rm'=>sub{
		my $obj=Remove->new(@_);
		$obj->execute();       	
	}
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
		exit;
	}
	else{
		my @args = split /\s+/, $_;
		my $comkey = shift @args;
		unshift @args, ($currpath, $verbose);
		eval{
			$res = $commands{$comkey}->(@args); 	
		 1} or warn "Error: $@ \nThis version support only: ".join(", ",keys %commands)." functions.";
		
	}
	say $OUT $res unless $@;
}

END{
	if(defined($term)){
		$term->write_history() or say "History written";
	}
}


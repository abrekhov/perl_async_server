#!/usr/bin/perl

use Getopt::Long;
use Term::ReadLine;
use DDP;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Context;
use Storage;

use warnings;
use strict;
use 5.016;

#Options
our $verbose=0;
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
our $currpath = qx(cd $cpath && pwd);
chomp $currpath; 
say "Absolute path:" . $currpath if $verbose;

#Global hash
our %global;
$global{verbose}=$verbose;
$global{currpath}=$currpath;


#Commands list
my @commands =qw( ls cp rm mv);

my $term = Term::ReadLine->new('Perl local client ');
my $prompt = "> ";
$term->read_history();
my $attribs = $term->Attribs;
$attribs->{completion_entry_function} = $attribs->{list_completion_function};
$attribs->{completion_word}=\@commands;
#Storage init (stay for whole session)
my $storobj = Storage->new(%global);

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
		my $context = Context->new( $storobj, string =>$_);
		eval{
			$res = $context->execute();  	
		 1} or warn "Error: $@ \nThis version support only: " . join(", ",@commands) . " functions.";
		
	}
	say $OUT $res unless $@;
}

END{
	if(defined($term)){
		$term->write_history() or say "History written";
	}
}



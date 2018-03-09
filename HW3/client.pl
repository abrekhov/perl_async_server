#!/usr/bin/perl

use Getopt::Long;
use Pod::Usage;
use Term::ReadLine;
use 5.016;


#Options
my $verbose='';
my $help='';
my @args;
Getopt::Long::Configure('bundling');
GetOptions(
	'v|verbose+'=>\$verbose,
	'h|help'=>\$help
);

say "Verbose level: $verbose" if $verbose ;
#Help init
say "Initialization of help..." if $verbose;

my $instructions = <<EOF;
Usage:
	client.pl [-h] [-v] /path/to/somewhere
	-h | --help - say usage and exit
	-v | --verbose - be verbose	
EOF

die $instructions if $help;

#Absolute path init
say "Arguments:[".join(',',@ARGV)."]" if $verbose;
my $cpath = $ARGV[0] or die $instructions;
my $currpath = qx(cd $cpath && pwd);
chomp $currpath; 
say "Absolute path:".$currpath."..." if $verbose;

#Commands functions
sub ls(){
	say "debug: List of files(ls)" if $verbose>0;
	say "debug2: qx(cd $currpath && ls -lA)" if $verbose>1;
	return qx(cd $currpath && ls -lA);
}
sub rm(){
	my @args = @_;
	say "debug: Removing $args[1](rm)" if $verbose>0;
	say "debug2: unlink $currpath/$args[1]" if $verbose>1;
	unlink $currpath."/".$args[1]; 
}
sub mv(){
	my @args = @_;
	say "debug: Renaming $args[1] in $args[2] (mv)" if $verbose>0;
	say "debug2: rename currpath/$args[1] , $currpath/$args[2]" if $verbose>1;
	rename $currpath."/".$args[1] , $currpath."/".$args[2];
}
sub cp(){
	my @args = @_;
	say "debug: Copying $args[1] in $currpath/$args[2] (cp)" if $verbose>0;
	say "debug2: qx(cp $args[1] $currpath/$args[2])" if $verbose>1;
	return qx(cp $args[1] $currpath/$args[2]);
}
sub exit(){
	say "Exitting client..." if $verbose>0;
	return eval("exit");
}

#Commands init
my %commands = (
	'ls'=>\&ls,
	'cp'=>\&cp,
	'mv'=>\&mv,
	'rm'=>\&rm,
	'exit'=>\&exit
);

my $term = Term::ReadLine->new('Perl local client ');
my $prompt = "> ";
$term->Features->{autohistory}=1;
$term->read_history();
my $attribs = $term->Attribs;
$attribs->{completion_entry_function} = $attribs->{list_completion_function};
$attribs->{completion_word}=[qw(ls cp mv rm exit)];
my $OUT = $term->OUT || \*STDOUT;
while ( defined ($_ = $term->readline($prompt)) ) {
	$term->write_history() if /\S/;
	my $res="";
	my @args = split /\s+/, $_;
	#say join ",", @args;
	if ($_ =~/^\!(.*)/){
		$res= qx($1);
		warn $@ if $@;
	}
	elsif($_ =~/^$/){
		$res = $_;
	}
	else{
		eval{
			$res = $commands{$args[0]}->(@args); 	
		 };
		warn "This version support only: ls, cp ,mv, rm functions." if $@;
		

	}
	say $OUT $res unless $@;
	$term->addhistory($_) if /\S/;

}





package Server::HTTPInit;
###################
use 5.016;
use warnings;
use Getopt::Long;
no warnings 'uninitialized';
use utf8;
use DDP;



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


our $storobj = Storage->new(%global);
p $storobj if $verbose > 1;


##################
1;



package StrHandler;{
use 5.016;
use warnings;
no warnings 'uninitialized';
use utf8;
use DDP;
use Data::Dumper; 

	sub new
	{
		my $class = shift;
		my $string=shift;
		my $self = bless{
			string=>$string
		}, $class;
		return $self;	
	}

	sub prepare{
		my $self=shift;
		#my @a = $self->{string} =~ /\s*(.*)(?<!\\)\s+(.*)(?<!\\)\s+(.*)/g;
		#say "Array a:".join (", ", @a);
		#p @a;
		my @a = split(/(?<!\\)\s+/, $self->{string});	
		p @a;
		return @a;
	}

}
1;

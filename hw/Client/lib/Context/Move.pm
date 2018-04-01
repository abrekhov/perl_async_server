use 5.016;
use warnings;

{
package Move;
	sub new{
		my $class = shift;
		my ($currpath,$verbose,$file1,$file2) = @_;
		my $self = bless{
			file1=>$file1,
			file2=>$file2,
			currpath=>$currpath,
			verbose=>$verbose
		}, $class;
		return $self;	
	}

	sub execute{
		my $self = shift;
		say "debug: Renaming $self->{file1} in $self->{file2} (mv)" if $self->{verbose}>0;
		say "debug2: rename $self->{currpath}/$self->{file1} , $self->{currpath}/$self->{file2}" if $self->{verbose}>1;
		rename $self->{currpath}."/".$self->{file1} , $self->{currpath}."/".$self->{file2};
	}
}
1;


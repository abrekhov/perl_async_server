use 5.016;
use warnings;
{
package Copy;
	sub new
	{
		my $class = shift;
		my ($currpath, $verbose,$file1,$file2) = @_;
		my $self = bless{
			file1=>$file1,
			file2=>$file2,
			currpath=>$currpath,
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

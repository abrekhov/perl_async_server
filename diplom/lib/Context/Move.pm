package Context::Move;
########################
use DDP;

use 5.016;
use parent 'Context::Base';

	sub execute{
		my $self = shift;
        die "Need at least two args" if scalar @{ $self->{ files } } < 2;
        my $dist = pop @{ $self->{ files } };
        foreach ( @{ $self->{ files } } ){
            say "debug: Renaming $self->{ currpath }/$_ in $self->{ currpath }/$dist (mv)" if $self->{verbose}>0;
            say "debug2: rename $self->{ currpath }/$_ , $self->{currpath}/$dist" if $self->{verbose}>1;
            rename $self->{ currpath } . "/" . $_ ,
                   $self->{ currpath } . "/" . $dist;
        }
	}
#######################
1;


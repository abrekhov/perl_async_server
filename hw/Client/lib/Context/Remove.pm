package Context::Remove;
########################
use DDP;

use 5.016;
use parent 'Context::Base';

	sub execute{
		my $self=shift;
        if( scalar @{ $self->{ files } } ){
            foreach ( @{ $self->{ files } } ){
                say "debug: Removing $_ (rm)" if $self->{verbose}>0;
                say "debug2: unlink $self->{currpath}/$_" if $self->{verbose}>1;
                unlink $self->{currpath}."/".$_ or warn "Cannot remove $_: $!"; 
            }

        }
	}
#######################
1;

package Context::Copy;
########################
use DDP;

use 5.016;
use parent 'Context::Base';

	sub execute
	{
		my $self=shift;
        
        if ($@{$self->{ files }}>1){
        my $dist = pop @{ $self->{ files } };
            foreach ( @{ $self->{ files } } ){
                say "debug: Copying $_ in $self->{currpath}/$dist (cp)" if $self->{verbose}>0;
                say "debug2: qx(cp $_ $self->{currpath}/$dist)" if $self->{verbose}>1;
                return qx(cp $_ $self->{currpath}/$dist);
            }    
    	}
        else{
                say "debug: Copying $self->{files}[0] in $self->{currpath}/ (cp)" if $self->{verbose}>0;
                say "debug2: qx(cp $self->{files}[0] $self->{currpath}/)" if $self->{verbose}>1;
                return qx(cp $self->{files}[0] $self->{currpath}/$dist);
            
        }

    }
#######################
1;

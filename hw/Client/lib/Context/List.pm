package Context::List;
########################
use DDP;

use 5.016;
use parent 'Context::Base';
    
	sub execute{
		my $self = shift;
        say "debug: List of files(ls)" if $self->{verbose}>0;
        if (@{$self->{ files }}){
            foreach (@{$self->{files}}){
                #$self->{ storage }->showFS();
                say "For file $_ doing ls" if $self->{ verbose };
                $self->{ storage }->ls($_);

                #say "debug2: qx(ls -lA $self->{currpath}/$_)" if $self->{verbose}>1;
                #say qx(ls -lA $self->{currpath}/$_);
            }
        }else{
            $self->{ storage }->showFS();
            $self->{ storage }->ls();
            
            #say "debug2: qx(ls -lA $self->{currpath})" if $self->{verbose}>1;
            #say qx(ls -lA $self->{currpath});
        }
    }
########################
1;

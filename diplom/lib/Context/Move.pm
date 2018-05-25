package Context::Move;
########################
use DDP;
use File::Copy::Recursive;

use 5.016;
use parent 'Context::Base';

	sub execute{
		my $self = shift;\
        my $body;
        if ( scalar @{ $self->{ files } } > 1 ){
            my $dist = pop @{ $self->{ files } };
            foreach ( @{ $self->{ files } } ){
                say "debug: Renaming $self->{ currpath }/$_ in $self->{ currpath }/$dist (mv)" if $self->{verbose}>0;
                say "debug2: rename $self->{ currpath }/$_ , $self->{currpath}/$dist" if $self->{verbose}>1;
                rename $self->{ currpath } . "/" . $_ ,
                       $self->{ currpath } . "/" . $dist;
                $body .= "Renamed $_ in $dist\n";
            }
        }
        else{
            $body .= "Need at least 2 arguments\n";
        }
        return $body . "\n";
	}
#######################
1;


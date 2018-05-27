package Context::Copy;
########################
use utf8;
use DDP;
use File::Copy::Recursive;

use 5.016;
use parent 'Context::Base';

	sub execute
	{
		my $self=shift;
        my $body;
        #$self->verbose();
        if (scalar @{$self->{ files }}>1){
            say $@{ $self->{ files } };
            my $dist = pop @{ $self->{ files } };
            say "Files to copy :" . join ",", @{ $self->{ files } };
            foreach ( @{ $self->{ files } } ){
                say "debug: Copying $_ in $self->{currpath}/$dist (cp)" if $self->{verbose}>0;
                say "debug2: qx(cp $_ $self->{currpath}/$dist)" if $self->{verbose}>1;
                File::Copy::Recursive::rcopy( $self->{ currpath } . "/" . $_ , $self->{ currpath } . "/" . $dist) or die "Copy failed: $!";
                $body .= "Copied $_ to $dist\n";
            }    
    	}
        else{
                $body .= "Need at least 2 arguments\n";
        }
        return $body . "\n";

    }
#######################
1;

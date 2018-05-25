package Context::Touch;
########################
use DDP;
use utf8;
use File::Spec;


use 5.016;
use parent 'Context::Base';
    
	sub execute{
		my $self = shift;
        p $self;
        #NOT HTTP
        my $body;
        if (@{$self->{ files }}[0]){ #SUBS
            foreach my $previousfile ( @{$self->{ files }} ){
                my $fullpath = $self->{ currpath } . "/" . $previousfile;
                open(my $touchfile, '>', $fullpath) or $body .= "Failed to create an empty file: $!\n";
                close($touchfile) or $body .="Failed to create an empty file: $!\n";
                $body .= "New file created: $previousfile\n";
            }
        }
        else{ #ROOT
            $body .= "Need at least 1 argument\n"; 
        }
        return $body . "\n";
    }

########################
1;

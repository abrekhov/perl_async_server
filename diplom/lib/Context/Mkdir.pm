package Context::Mkdir;
########################
use DDP;
use utf8;


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
                if ( mkdir $fullpath ){
                    $body .= "Folder $previousfile created\n";
                }
                else{
                    $body .= "Failed to create a directory $previousfile: $!\n";
                }
            }
        }
        else{ #ROOT
            $body .= "Need at least 1 argument\n"; 
        }
        return $body . "\n";
    }

########################
1;

package Context::List;
########################
use DDP;

use 5.016;
use parent 'Context::Base';
    
	sub execute{
		my $self = shift;
        say "debug: List of files(ls)" if $self->{verbose}>0;
        if (@{$self->{ files }}){
            foreach my $file (@{$self->{files}}){
                #$self->{ storage }->showFS();
                say "For file $_ doing ls" if $self->{ verbose };
                
                foreach my $dirOrFile (@{ $self->{ storage }{ fs } }){
                    if ($file){
                        if ( $dirOrFile =~ m/^\/$file\/([^\/]*?)$/ ){
                            say $1;    
                        }
                    }
                    else{
                        if ( $dirOrFile =~ m/^\/([^\/]*)$/){
                            say $1;
                        }
                    }
                }
            }
        }else{
            $self->{ storage }->showFS();
            say "For file $_ doing ls" if $self->{ verbose };
            
            foreach my $dirOrFile (@{ $self->{ storage }{ fs } }){
                    if ( $dirOrFile =~ m/^\/([^\/]*)$/){
                        say $1;
                    }
            }
        }
    }
########################
1;

package Context::List;
########################
use DDP;
use utf8;

use 5.016;
use parent 'Context::Base';
    
	sub execute{
		my $self = shift;
        my $body;
        say "debug: List of files(ls)" if $self->{verbose}>0;
        if (@{$self->{ files }}){
            foreach my $file (@{$self->{files}}){
                #$self->{ storage }->showFS();
                say "For file $_ doing ls" if $self->{ verbose };
                $body .= "For file $_ doing ls\n" if $self->{ verbose } ;
                
                foreach my $dirOrFile (@{ $self->{ storage }{ fs } }){
                    if ($file){
                        if ( $dirOrFile =~ m/^\/$file\/([^\/]*?)$/ ){
                            say $1;    
                            $body .= $1 . "\n";
                        }
                    }
                    else{
                        if ( $dirOrFile =~ m/^\/([^\/]*)$/){
                            say $1;
                            $body .= $1 . "\n";
                        }
                    }
                }
            }
        }else{
            $self->{ storage }->showFS();
            say "For file $_ doing ls" if $self->{ verbose };
            $body .= "For file $_ doing ls\n" if $self->{ verbose };
            
            foreach my $dirOrFile (@{ $self->{ storage }{ fs } }){
                    if ( $dirOrFile =~ m/^\/([^\/]*)$/){
                        say $1;
                        $body .= $1 ."\n";
                    }
            }
        }
        return $body;
    }
########################
1;

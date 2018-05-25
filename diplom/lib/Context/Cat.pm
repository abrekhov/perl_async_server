package Context::Cat;
########################
use DDP;
use utf8;
use Server::HTTPMaker;
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
                #my $previousfile = ${ $self->{ files } }[0];
                my $fullpath = $self->{ currpath } . "/" . $previousfile;
                (my $relative = $fullpath) =~ s/$self->{ currpath }//g;
                if ( -d $fullpath){
                    $body .= "It is directory; Use ls to look inside\n";
                }
                elsif( -e $fullpath){
                    say "Request for file";
                    say $fullpath;
                    open( my $f, '<:raw', $fullpath ) or die "$!";
                    say $self->{ bufsize };
                    my $bytes = sysread($f, my $buff, $self->{ bufsize });
                    $body .= $buff;
                }
                else{
                    say "Goes wrong!Fullpath: $fullpath";
                    $body .= "Permission denied or not found! Sorry!\n\n";
                }
            }
        }
        else{ #ROOT
            $body .= "need at least 1 argument\n"; 
        }
        return $body . "\n";
    }

########################
1;

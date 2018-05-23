package Context::List;
########################
use DDP;
use utf8;
use Server::HTTPMaker;


use 5.016;
use parent 'Context::Base';
    
	sub execute{
		my $self = shift;
        my $resp = Server::HTTPMaker->new();
        if(1){
            my $body;
            if (@{$self->{ files }}[0]){ #SUBS
                    my $previousfile = ${ $self->{ files } }[0];
                    my $fullpath = $self->{ currpath } . "/" . $previousfile;
                    (my $relative = $fullpath) =~ s/$self->{ currpath }//g;
                    if ( -d $fullpath){
                        say "Directory request";
                        opendir( my $d, $fullpath ) or die "$!";
                        $resp->status("200 OK");
                        $resp->type("text/html");
                        $body .= "<html><body>";
                        while(readdir($d)){
                            if ( $_ =~ /^\.{1,2}/){
                                $body .= "<a href='$_'> $_ </a>" . "</br>";
                            }
                            else{
                                $body .= "<a href='$relative/$_'> $_ </a>" . "</br>";
                            }
                        }
                        $body .= "</body></html>";
                    }
                    elsif( $fullpath){
                        say "Request for file";
                        say $fullpath;
                        open( my $f, '<:raw', $fullpath ) or die "$!";
                        $resp->type("application/octet-stream");
                        p $self;
                        say $self->{ bufsize };
                        my $bytes = sysread($f, my $buff, $self->{ bufsize });
                        $body .= $buff;
                    }
                    else{
                        say "Goes wrong!Fullpath: $fullpath";
                        $body .= "Permission denied or not found! Sorry! Requested path: $fullpath";
                    }
            }
            else{ #ROOT
                $resp->status("200 OK");
                $resp->type("text/html");
                my $fullpath = $self->{ currpath }; 
                opendir( my $d, $self->{ currpath } ) or die "$!";
                $body .= "<html><body>";
                $body .= "Root<br>" if $self->{ verbose };
                while(readdir($d)){
                    
                    $body .= "<a href='$_'> $_ </a>" . "</br>" if $_ !~ /^\.{1,2}/;
                }
                $body .= "</body></html>";
            }
            $resp->body($body);
            p $resp;
            return $resp->response();
        }
    }

	sub executebak{
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

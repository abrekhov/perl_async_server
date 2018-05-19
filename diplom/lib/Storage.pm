package Storage;
############################
use DDP;
use 5.016;

    sub new
    {
        my $class = shift;
        my %global = @_;
        my $self = bless{
            global=>\%global,
            commands=>{
                init=>\&initFS,
                show=>\&showFS,
                isExist  =>\&isExist,
            },
            fs=>(),
#            files=>(),
        },$class;
        $self->initFS();
        return $self;
    }

    sub initFS{
        my $self = shift;
        my $path = shift;
        opendir( my $d, $self->{ global }{ currpath } . "/" . $path ) or die $!;
        while( readdir($d) ){
            #say $_;
            my $tmppath;
            if ( $path ){
                $tmppath = $path . "/" . $_; 
            }
            else{
                $tmppath = "/" . $_;
            }
            push ( @{$self->{ fs }}, $tmppath ) unless /^\.{1,2}/;
            if ( -d( $self->{ global }{ currpath } . "/" . $tmppath ) and not /^\.{1,2}/ ){
                $self->initFS($tmppath) unless /^\.{1,2}/;
            }
        }
        closedir($d) or warn $!;
        return $self;
    }

    sub showFS{
        my $self = shift;
        return $self->{ fs };
        return $self;
    }

    sub global{
        my $self = shift;
        if ( shift ){
            $self->{ global } = $_;
        }
        else{
            return $self->{ global };
        }
        return $self;
    }

    sub isDir{
		my $self = shift;

        if (@{$self->{ files }}){
            foreach my $file (@{$self->{files}}){
                say "For file $_ doing ls" if $self->{ verbose };
                
                foreach my $dirOrFile (@{ $self->{ fs } }){
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
            return 0;
        }
    }

    #sub execute
    #{
    #    my $self = shift;
    #    my $command = $self->{ context }{ files }[0];
    #    $self->{ commands }{ $command }->($self);

    #}


###########################
1;

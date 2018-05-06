package Context::Storage;
############################
use DDP;
use 5.016;

    sub new
    {
        my $class = shift;
        my $context = shift;
        my $self = bless{
            context=>$context,
            commands=>{
                init=>\&initFS,
                show=>\&showFS,
            },
            fs=>()
        },$class;
        return $self;
    }

    sub initFS{
        my $self = shift;
        my $path = shift;
        opendir( my $d, $self->{ context }{ currpath } . "/" . $path ) or die $!;
        while( readdir($d) ){
            say $_;
            my $tmppath;
            if ( $path ){
                $tmppath = $path ."/" . $_; 
            }
            else{
                $tmppath = "/" . $_;
            }
            push ( @{$self->{ fs }}, $tmppath ) unless /^\.{1,2}/;
            if ( -d( $self->{ context }{ currpath } . "/" . $tmppath ) and not /^\.{1,2}/ ){
                $self->initFS($tmppath) unless /^\.{1,2}/;
            }
        }
        closedir($d) or warn $!;
        return $self;
    }

    sub showFS{
        my $self = shift;
        $self->initFS();
        p $self;
        return $self;
    }
    sub stillInStorage
    {
        my $self = shift;
        

    }

    sub execute
    {
        my $self = shift;
        my $command = $self->{ context }{ files }[0];
        $self->{ commands }{ $command }->($self);

    }


###########################
1;

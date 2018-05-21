package Context;
###################
use 5.016;
use warnings;
no warnings 'uninitialized';
use utf8;
use Context::List;
use Context::Copy;
use Context::Move;
use Context::Remove;
use DDP;

	sub new
	{
		my $class = shift;
        my $storage = shift;
        my %string = @_;
        my $global = $storage->global();  
		my $self = bless{
    		context=>$global,
            commands=>{
                ls=>'Context::List',#Context::List->new(),
                cp=>'Context::Copy',#Context::Copy->new(),
                mv=>'Context::Move',#Context::Move->new(),
                rm=>'Context::Remove',#Context::Remove->new(),
            },
            storage => $storage,
            %string,
		}, $class;
        p $self;
        #$self->httpPrepare() if $self->{ http }; # this \ slashes not acceptable by GC so i need new kostyl'
        $self->prepare();
		return $self;	
	}

	sub prepare{
		my $self = shift;
        
        my @a = split(/(?<!\\)\s+/, $self->{ string });#split by normal whitespace
        $self->{ context }{ command } = lc shift @a;
        $self->{ context }{ files } = \@a;
        $self->extendfiles(); 
		return $self;
	}

	sub httpPrepare{
		my $self = shift;
        
        my @a = split(/(?<!\\)\s+/, $self->{ string }, 1);#split by normal whitespace
        $self->{ context }{ command } = lc shift @a;
        $self->{ context }{ files } = \@a;
        $self->extendfiles(); 
		return $self;
	}
    
    sub extendfiles{
        my $self = shift;
        my $index=0;
        foreach ( @{[@{$self->{ context }{ files }}]} ){ # filename separated with ws of other
            if ( /\{.*\}/ ){ #check if ther {  }
                splice (@{$self->{ context }{ files }},$index,1);
                m/(?'prev'.*)\{(?'inside'.*?)\}(?'next'.*)/; #grab all parts from filename
                my @inside = split ",", $+{inside}; # split by comma in SMALLEST brackets
                my $newstring;
                for my $part (@inside){
                    $newstring = $+{prev} . $part . $+{next};
                    push ( @{ $self->{ context }{ files } }, $newstring );
                }
                if ( $newstring =~ m/\{.*?\}/ ){
                    return $self->extendfiles();
                }
            }
            $index++;
        }
        return $self;
    }

    sub execute{
        my $self = shift;
        my $cmd = $self->{ context }{ command };
        my $obj = $self->{ commands }{ $cmd }->new( $self->{ storage }, $self->{ context }, bufsize=>$self->{ bufsize });
        return $obj->execute();
    }
##################
1;

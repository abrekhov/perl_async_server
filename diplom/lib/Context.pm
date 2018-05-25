package Context;
###################
use 5.016;
use warnings;
no warnings 'uninitialized';
use utf8;
use File::Spec;
use Cwd 'abs_path';
use File::Copy;
#Local
use Context::List;
use Context::Copy;
use Context::Move;
use Context::Remove;
use Context::Cat;
use Context::Touch;
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
                ls       =>  'Context::List',#Context::List->new(),
                cp       =>  'Context::Copy',#Context::Copy->new(),
                mv       =>  'Context::Move',#Context::Move->new(),
                rm       =>  'Context::Remove',#Context::Remove->new(),
                cat      =>  'Context::Cat',#Context::Remove->new(),
                touch    =>  'Context::Touch',#Context::Remove->new(),
            },
            storage => $storage,
            %string,
		}, $class;
        say "Context class:";
        p $self;
        if ( $self->{ http }==1 ){
            $self->httpPrepare(); # this \ slashes not acceptable by GC so i need new kostyl'
        }
        else{
            $self->prepare()   ;
            $self->checkIfUnderRoot() ;
            $self->notInRootClean();
        }
        
		return $self;	
	}

	sub prepare{
		my $self = shift;
        say "Preparing files"; 
        my @a = split(/(?<!\\)\s+/, $self->{ string });#split by normal whitespace
        $self->{ context }{ command } = lc shift @a;
        my @newa = map {$_ =~ s/\\//g; $_} @a;
        say "Newarray : ", join ",", @newa;
        $self->{ context }{ files } = \@newa;
        $self->extendfiles(); 
		return $self;
	}

	sub httpPrepare{
		my $self = shift;
        
        my @a = split(/(?<!\\)\s+/, $self->{ string }, 2);#split by normal whitespace
        $self->{ context }{ command } = lc shift @a;
        #$a[0] =~ s/(\s+)/\\$1/g; Dont need to escape whitespace while using open!!!!
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
    
    sub checkIfUnderRoot{
        my $self = shift;
        my $relpath = shift;
        say $self->{ context }{ currpath };
        say abs_path($self->{ context }{ currpath } . "/" . $_ );
        return 1 if abs_path( $self->{ context }{ currpath } . "/" . $_ )=~ m/^$self->{ context }{ currpath }/;
        return 0;
    }

    sub notInRootClean{
        my $self = shift;
        say "Context class:";
        p $self;
        say scalar @{[ @{$self->{ context }{ files }} ]};
        if (scalar @{[ @{$self->{ context }{ files }} ]} ){
            say "Checking files under rooting";
            my @newfiles = grep { $self->checkIfUnderRoot($_) } @{[@{$self->{ context }{ files }}]};
            say join ",", @newfiles;
            $self->{ context }{ files } = \@newfiles;
        }
    }

    sub execute{
        my $self = shift;
        my $cmd = $self->{ context }{ command };
        my $obj = $self->{ commands }{ $cmd }->new( $self->{ storage }, $self->{ context }, bufsize=>$self->{ bufsize }, http=>$self->{ http });
        return $obj->execute();
    }
##################
1;

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
        my %global = @_;  
        p %global;
		my $self = bless{
    		context=>\%global,
            commands=>{
                ls=>'Context::List',#Context::List->new(),
                cp=>'Context::Copy',#Context::Copy->new(),
                mv=>'Context::Move',#Context::Move->new(),
                rm=>'Context::Remove',#Context::Remove->new(),
            }
		}, $class;
        $self->prepare();
		return $self;	
	}

	sub prepare{
		my $self = shift;
        
        my @a = split(/(?<!\\)\s+/, $self->{context}{string});#split by normal whitespace
        $self->{ context }{ command }= lc shift @a;
        #here will be the part of regexp
        
        $self->{ context }{ files } = \@a;
        #$self->extendstr(@a); 
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
                    p $self;
                }
                if ( $newstring =~ m/\{.*?\}/ ){
                    return $self->extendfiles();
                }
            }
            $index++;
        }
        say "LAST self:";
        p $self;
        return $self;
    }
    
    sub extendstr{
        my $self = shift;

        my @a = shift @_;
        $self->{ context }{ files } = []; 
        foreach ( @a ){ # filename separated with ws of other
            if ( /\{.*\}/ ){ #check if ther {  }
                m/(?'prev'.*)\{(?'inside'.*?)\}(?'next'.*)/; #grab all parts from filename
                my @inside = split ",", $+{inside}; # split by comma in SMALLEST brackets
                for my $part (@inside){
                    my $newstring = $+{prev} . $part . $+{next};
                    if ( $newstring =~ m/\{.*?\}/ ){
                        say $newstring;
                        return $self->extendstr( $newstring );
                    }
                    push ($self->{ context }{ files }, $newstring);
                    p $self;
                }
            }
        }
        return $self;
    }

    sub extendsubs{
        my $self = shift;

        my @a = shift @_;
        my $out;
        foreach my $word ( @a ){
            #( my $newstring = $word ) =~ m/(?'prev'.*)\{(?'inside'.*)\}(.*)/;
            while ( $word =~ s/(?'prev'.*)\{(?'inside'.*?)\}(?'next'.*)/$+{prev}$+{first}$+{next}/g ){
                #$out .= " " . $+{prev} . $+{first} . $+{next};
                p %+;
            }
            say $word;
        }
        
    }

    sub extendadd{
        my $self = shift;

        my @a = shift @_;
        my $out;
        foreach my $word ( @a ){
            #( my $newstring = $word ) =~ m/(?'prev'.*)\{(?'inside'.*)\}(.*)/;
            while ( $word =~ m/(?'prev'.*)\{.*?,|,.*?,|,.*?\}(?'next'.*)/ ){
                $out .= " " . $+{prev} . $+{first} . $+{next};
                p %+;
            }
            say $word;
        }
        
    }

    sub execute{
        my $self = shift;
        my $cmd = $self->{ context }{ command };
        my $obj = $self->{ commands }{ $cmd }->new( $self->{ context } );
        return $obj->execute();
    }
##################
1;

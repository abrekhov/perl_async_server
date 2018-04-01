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
        p $self;
        my @a = split(/(?<!\\)\s+/, $self->{context}{string});
        $self->{ context }{ command }= lc shift @a;
        #here will be the part of regexp
        
        $self->{ context }{ files } = \@a;
		return $self;
	}

    sub execute{
        my $self = shift;
        p $self;
        my $cmd = $self->{ context }{ command };
        my $obj = $self->{ commands }{ $cmd }->new( $self->{ context } );
        return $obj->execute();
    }
##################
1;

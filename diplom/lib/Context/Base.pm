package Context::Base;
########################
use 5.016;
use warnings;
no warnings 'uninitialized';
    
    sub new{
        my $class = shift;
        my $storage = shift;
        my $context = shift;
        my $self = bless { 
            %{$context},
            storage=>$storage,
            @_,
        }, $class;
        return $self;
    }

    sub verbose{
        my $self = shift;
        say "Debug0: $self->{ command } @{ $self->{ files }  }" if $self->{ verbose } > 0;
        say "Debug1: qx($self->{ command } @{ $self->{ files } }) " if $self->{ verbose } > 1;
    }
############
1;

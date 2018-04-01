package Context::Base;
########################
use 5.016;
    
    sub new{
        my $class = shift;
        my $context = shift;
        my $self = bless { 
            %{$context}
        }, $class;
        return $self;
    }
############
1;

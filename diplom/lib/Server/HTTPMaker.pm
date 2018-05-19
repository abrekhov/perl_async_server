package Server::HTTPMaker;
############################
use DDP;
use 5.016;


    sub new
    {
        my $class = shift;
        my $self = bless{
            @_
        },$class;
        
        $self->setStatus($self->{ status });
        $self->setType($self->{ type });
        $self->setBody($self->{ body });
        
        return $self;
    }

    sub setStatus{
        my $self = shift;
        my $status = shift or $self->{ status };
        $self->{ header } .= "HTTP/1.1 $status\n";
        return $self;
    }


    sub setType{
        my $self = shift;
        my $type = shift or "text/html";
        my $charset = $self->{ charset } or "utf-8";
        $self->{ header } .= "Content-Type: $type; charset=$charset\n";
        return $self;
    }

    sub setLength{
        my $self = shift;
        my $length = shift or "0";
        $self->{ header } .= "Content-Length: $length\n";
        return $self;
    }

    sub setBody{
        my $self = shift;
        my $body = shift or "none";
        my $length = length($body);
        $self->setLength($length);
        $self->{ body } = $body;
        return $self;
    }

    sub response{
        my $self = shift;
        my $response;
        $response = $self->{ header } . "\n" . $self->{ body };
        return $response;
    }


###########################
1;


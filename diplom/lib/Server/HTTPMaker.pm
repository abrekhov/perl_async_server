package Server::HTTPMaker;
############################
use DDP;
use 5.016;
use utf8;

    sub new
    {
        my $class = shift;
        my $self = bless{
            @_,
            status=>"200 OK",
            type  =>"text/html",
            charset => "utf-8",
            body => "Permission denied or not found! Sorry!",
            length => length("Permission denied or not found! Sorry!"),
        },$class;
        
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
        my $type = $self->{ type } or "text/html";
        my $charset = $self->{ charset } or "utf-8";
        $self->{ header } .= "Content-Type: $type; charset=$charset\n";
        return $self;
    }

    sub setLength{
        my $self = shift;
        my $length = length($self->{ body }) or "0";
        $self->{ header } .= "Content-Length: $length\n";
        return $self;
    }

    sub setBody{
        my $self = shift;
        my $body = $self->{ body } or "none";
        $self->{ body } = $body;
        return $self;
    }

    sub status {
        my $self = shift;
        if(@_) {
            $self->{status} = $_[0];
            return $self;
        }
        return $self->{status};
    }
    sub type {
        my $self = shift;
        if(@_) {
            $self->{type} = $_[0];
            return $self;
        }
        return $self->{type};
    }
    sub body {
        my $self = shift;
        if(@_) {
            $self->{body} = $_[0];
            return $self;
        }
        return $self->{body};
    }

    sub response{
        my $self = shift;
        my $response;
        $self->setStatus();
        $self->setType();
        $self->setLength();
        $self->setBody();
        
        $response = $self->{ header } . "\n" . $self->{ body };
        say $response;
        return $response;
    }


###########################
1;


package Context::Remove;
########################
use utf8;
use DDP;
use File::Path;

use 5.016;
use parent 'Context::Base';

	sub execute{
		my $self=shift;
        my $body;
        if( scalar @{ $self->{ files } } ){
            foreach my $relpath ( @{ $self->{ files } } ){
                say "debug: Removing $relpath (rm)" if $self->{verbose}>0;
                say "debug2: unlink $self->{currpath}/$relpath" if $self->{verbose}>1;
                #unlink $self->{currpath}."/".$relpath or warn "Cannot remove $relpath: $!"; 
                File::Path::remove_tree($self->{currpath}."/".$relpath, {verbose=> 1}) or warn "Cannot remove $relpath: $!"; 
                $body .= "$relpath removed...\n";
            }
        }
        else{
            $body .= "Need at least 1 argument\n";
        }
        return $body ."\n";
	}
#######################
1;

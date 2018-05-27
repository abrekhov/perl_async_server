#!/usr/bin/env perl

# use subs 'say';
use strict;
use feature 'switch';
no warnings 'experimental';
use Socket ':all';
use utf8;
use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle;
use AnyEvent::ReadLine::Gnu;
use DDP;

my @commands =qw( ls cp rm mv mkdir rmdir put get touch cat );
my $comds_regex = join "|", @commands;

sub say {
	# warn "my say";
	my $line = "@_";
	$line =~ s{\n*$}{\n};
	AnyEvent::ReadLine::Gnu->print($line);
}

say $comds_regex;
my $cv = AE::cv;

# if (@ARGV != 1) { die "Usage:\n\t$0 file\n"; }
# my ($file) = @ARGV;
# my $size = -s $file;
# defined $size or die "File '$file': $!\n";
# say "Uploading file '$file' of size $size";

my $BUFSIZE = 2**19;

my $rl;
END {
	if ($rl) { $rl->hide; }
}

tcp_connect 0, 1025, sub {
	my $fh = shift
		or return warn "Connect failed: $!";

	
	my $h; $h = AnyEvent::Handle->new(
		fh => $fh,
		on_error => sub {
			warn "handle closed: @_";
			$h->destroy;
			$cv->send;
		},
		timeout => 1200,
	);

	my $command = sub {
		my $cmd = shift;
		AnyEvent::ReadLine::Gnu->hide;

		$h->push_write("$cmd\n");
		$h->push_read(line => qr/\n\n/, sub {
			if ($_[1] =~ /^OK\s+(\d+)/) {
				$h->unshift_read(chunk => $1, sub {
					say $_[1];
					AnyEvent::ReadLine::Gnu->show;
				});
			}
			else {
				say $_[1];
				AnyEvent::ReadLine::Gnu->show;
			}
		});

	};
    

    ############PUT
	my $put = sub {
		my $file = shift;
		my $size = -s $file;
		defined $size or return say("File '$file': $!");
		AnyEvent::ReadLine::Gnu->hide;
		say "Uploading file '$file' of size $size";

		my $left = $size;
		my ($name) = $file =~ m{(?:^|/)([^/]+)$};
		$h->push_write("put $size $name\n");
		$h->push_read(line => sub {
			if ($_[1] =~ /^OK\s+(\d+)/) {
				$h->unshift_read(chunk => $1, sub {
					say $_[1];
				});
			}
			else {
                say "Response from server:";
				say $_[1];
			}
		});
		open my $f, '<:raw', $file or $cv->croak("Failed to open file '$file': $!");
		my $rh;$rh = AnyEvent::Handle->new(
			fh => $f,
			on_error => sub {
				shift;
				warn "file error: @_";
				$rh->destroy;
			},
			max_read_size => $BUFSIZE,
			read_size     => $BUFSIZE,
		);

		my $do;$do = sub {
			if ($left > 0) {
				$rh->push_read(chunk => $left > $BUFSIZE ? $BUFSIZE : $left, sub {
					my $wr = $_[1];
					$left -= length $wr;
					$h->push_write($wr);
					if ($h->{wbuf}) {
						#say "write buffer ".length $h->{wbuf};
						$h->on_drain(sub {
							$h->on_drain(undef);
							$do->();
						});
					}
					else {
						# say "send successfully ".length $wr;
						$do->();
					}
				});
			}
			else {
				warn "finish";
				$rh->destroy;
				AnyEvent::ReadLine::Gnu->show;
			}
		};$do->();

	};
    
    ############GET
	my $get = sub {
        #my $size = shift;
        my $file = shift;
        say "Request for $file";
        my $size;
		$h->push_write("get $file\n");
		$h->push_read(line =>  sub {
			if ($_[1] =~ /^get\s+(\d+)\s+(\w+)$/) {
                $size = $1;
                say "Size came from server: $size bytes";
                my $left = $size;
                open my $fh, '>:raw', "$file" or die "Cannot open filehandler on write: $!";
                my $body;$body = sub {
                    $h->unshift_read( chunk => $left > $BUFSIZE ? $BUFSIZE : $left, sub {
                        my $rd = $_[1];
                        say "Rd: $rd";
                        $left -= length $rd;
                        $h->{ on_error } = sub { close($fh) or die "Cannot close filehandler"; };
                        warn sprintf "read %d, left %s\n",length($rd),$left;
                        syswrite($fh,$rd);
                        if ($left == 0) {
                            undef $body;
                            close $fh;
                            say "File saved";
                        }
                        else {
                            $body->();
                        }
                    } );
                };$body->();
			}
			else {
				say $_[1];
				AnyEvent::ReadLine::Gnu->show;
			}
		});

	};

	$rl = AnyEvent::ReadLine::Gnu->new(
		prompt => "> ",
		on_line => sub {
			given (shift) {
				when (undef) { # Ctrl + D
					$cv->send;
				}
                when (m/^\!(.*)/){
                    say qx($1);
                }
				when(/put\s+(.+?)\s*$/x) {
					$put->($1);
				}
                when(/get\s+(.*)$/){
                    $get->($1);
                }
				when(m/^\s*($comds_regex)/) {
					$command->($_);
				}
                when(m/^\s*exit/){
                    say "Exitting client...";
                    exit;
                }
                when(m/^$/){
                    #skip
                }
				default {
					say "wrong command: $_";
				}
			}
		},
	);
    my $attribs = $rl->Attribs;
    $attribs->{completion_entry_function} = $attribs->{list_completion_function};
    $attribs->{completion_word}=\@commands;
    $rl->read_history();

	# my $length = length $data;
	
	# $h->push_write("put $length\n$data");
	# p $h->{wbuf};

	# $h->push_write("ls\n");
	# p $h->{wbuf};

	# $h->on_drain(sub {
	# 	warn "drain";
	# 	p $h;
	# 	# $h->destroy;
	# });



}, sub {
	my $fh = shift;
	1;
};

$SIG{'INT'} = sub {
    if(defined($rl)){
	    $rl->print("> \n");
    }
};


$cv->recv;

END{
	if(defined($rl)){
		$rl->write_history() or say "History written";
	}
}

#!/usr/bin/env perl

use 5.016;

#Modules
use Getopt::Long;
use AnyEvent;
use Socket ':all';
use AnyEvent::Socket;
use AnyEvent::Handle;
use DDP;
use EV;
use utf8;

#Local lib
use FindBin;
use lib "$FindBin::Bin/../lib";
use Context;
use Storage;
use Server::HTTPMaker;
use Encode;
use URI::Escape;

my $BUFSIZE = 2**19;


our $verbose=0;
my $instructions = <<EOF;
Usage:
	client.pl [-h] [-v] /path/to/somewhere
	-h | --help - say usage and exit
	-v | --verbose - be verbose	
EOF


Getopt::Long::Configure('bundling');
GetOptions(
	'v|verbose+'=>\$verbose,
	'h|help'=>sub{ die($instructions); }
);


say "Verbose level: $verbose" if $verbose ;

#Checking all modules
say "Included modules:" if $verbose>1;
p %INC if $verbose>1;


#Absolute path init
say "Arguments:[".join(',',@ARGV)."]" if $verbose;
my $cpath = $ARGV[0] or die $instructions;
our $currpath = qx(cd $cpath && pwd);
chomp $currpath; 
say "Absolute path:" . $currpath if $verbose;

#Global hash
our %global;
$global{verbose}=$verbose;
$global{currpath}=$currpath;


#Commands list
my @commands =qw( ls cp rm mv);


our $storobj = Storage->new(%global);
p $storobj if $verbose > 1;



tcp_server 0,8080, sub {
	my $fh = shift;
	# setsockopt($fh, SOL_SOCKET, SO_RCVBUF, 1024) or warn "setsockopt failed: $!";
	warn "Client connected: @_";
	# my $rw; $rw = AE::io $fh, 0, sub {
	# 	$rw;
	# 	my $r = sysread($fh, my $buf, 4096);
	# 	if ($r) {
	# 		warn "read: $r, $buf";
	# 	}
	# 	elsif($!{EAGAIN}) { return }
	# 	else {
	# 		warn "Client disconnected";
	# 		close $fh;
	# 		undef $rw;
	# 	}
	# };
	my $t;$t = AE::timer 0.1, 0, sub {
		undef $t;

		my $h; $h = AnyEvent::Handle->new(
			fh => $fh,
			on_error => sub {
				warn "handle closed: @_";
				#p $h;
				$h->destroy;
			},

			max_read_size => $BUFSIZE,
			read_size => $BUFSIZE,

			timeout => 600,
			# on_read => sub {
			# 	my $h = shift;
			# 	warn "on read + '$h->{rbuf}' [@{ $h->{_queue} }]";
			# 	# my $read = delete $h->{rbuf};

			# 	# if (length $h->{rbuf} > 12) {
			# 	# 	my $read = substr($h->{rbuf},0,12,'');
			# 	# 	say "read: '$read'";
			# 	# }
			# 	warn "push read";
			# 	$h->push_read(chunk => 20, sub {
			# 		my (undef,$read) = @_;
			# 		say "read '$read'";
			# 	});
			# 	warn "have queue: [@{ $h->{_queue} }]";
			# },
		);

		my $reply = sub {
			if (defined $_[0]) {
				$h->push_write($_[0]);
			}
			else {
				my $err = $_[1];
				$err =~ s{\n}{ }sg;
				$h->push_write("ERR $err\n");
			}
		};


		my $reader;$reader = sub {
			$h->push_read( line => sub {
				$reader->();

				# warn "on read + '$h->{rbuf}' [@{ $h->{_queue} }]";
				shift;
				my $line = shift;

                if ($line =~ /GET \/(.*?) HTTP\/1\.1/){
                    my $reqpath = uri_unescape( $1 );

                    my $context = Context->new( $storobj, string =>"ls " . $reqpath, http => 1, bufsize => $BUFSIZE);
                    my $body = $context->execute();  	
                    p $context;
                    $reply->($body);
                }
                
				elsif ($line =~ /^put\s+(\d+)\s+(.+)$/) {
					my ($size,$file) = ($1,$2);
					say "command put on $size bytes for $file";
					my $left = $size;
					open my $fh, '>:raw', "store/$file";
						# or do {  };

					my $body;$body = sub {
						$h->unshift_read( chunk => $left > $BUFSIZE ? $BUFSIZE : $left, sub {
							my $rd = $_[1];
							$left -= length $rd;
							warn sprintf "read %d, left %s\n",length($rd),$left;
							syswrite($fh,$rd);
							if ($left == 0) {
								undef $body;
								close $fh;
								$reply->("File saved");
							}
							else {
								$body->();
							}
						} );
					};$body->();

				}
				elsif ($line eq '') {
					# skip
				}
				else {
					#say "command $line";
					given($line) {
						when ('ls') {
							my $out = `ls -lA store`;
							#$reply->($out);
							# $h->push_write("OK ".(length($out)+1)."\n".$out."\n");
						}
						default {
                            #my $resp = Server::HTTPMaker->new(
                            #    status => "404 Not Found",
                            #    type => 'text/plain',
                            #    charset => "utf-8",
                            #        );
                            #my $forsend = $resp->response();
                            #$reply->($forsend);
							#$reply->("Unknown command");
							# $h->push_write("ERR Unknown command\n");
						}
					}
				}

			} );
		};$reader->();
	};
},
sub {
	my ($fh,$host,$port) = @_;
	say "Listening on $host:$port";
	1024;
};


EV::loop();

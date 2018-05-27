#!/usr/bin/env perl

use 5.016;

#Modules
use Getopt::Long;
use AnyEvent;
use Socket ':all';
use AnyEvent::Socket;
use AnyEvent::Handle;
use Cwd 'abs_path';
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
our $directory='';
my $instructions = <<EOF;
Usage:
	client.pl [-h] [-v] /path/to/somewhere
	-h | --help - say usage and exit
	-v | --verbose - be verbose	
	-d | --directory - server root	
EOF


Getopt::Long::Configure('bundling');
GetOptions(
	'v|verbose+'=>\$verbose,
	'd|dir'=>\$directory,
	'h|help'=>sub{ die($instructions); }
);


say "Verbose level: $verbose" if $verbose ;
say "Server root: $directory" if $verbose ;

#Checking all modules
say "Included modules:" if $verbose>1;
p %INC if $verbose>1;


#Absolute path init
say "Arguments:[".join(',',@ARGV)."]" if $verbose;
my $cpath = $ARGV[0] or die $instructions;
our $currpath = abs_path("./") if chdir( $cpath ) or die "Server root not mounted: $!";
#our $currpath = qx(cd $cpath && pwd) or die "$!";
chomp $currpath; 
say "Absolute path:" . $currpath if $verbose;

#Global hash
our %global;
$global{verbose}=$verbose;
$global{currpath}=$currpath;


#Commands list
my @commands =qw( ls cp rm mv mkdir rmdir touch cat );
my $regex_comds = join "|", @commands;


our $storobj = Storage->new(%global);
p $storobj if $verbose > 1;



tcp_server 0,1025, sub {
	my $fh = shift;
	warn "Client connected: @_";
	my $t;$t = AE::timer 0.1, 0, sub {
		undef $t;

		my $h; $h = AnyEvent::Handle->new(
			fh => $fh,
			on_error => sub {
				warn "handle closed: @_";
				$h->destroy;
			},

			max_read_size => $BUFSIZE,
			read_size => $BUFSIZE,

			timeout => 1200,
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

				shift;
				my $line = shift;

                if ($line =~ m/^\s*($regex_comds)/){
                    my $context = Context->new( $storobj, string=> $line, http=>0, bufsize=>$BUFSIZE );
                    my $body = $context->execute();
                    p $context;
                    $reply->($body);
                }

                if ($line =~ /^GET \/(.*?) HTTP\/1\.1/){
                    return 0 if $1 eq "favicon.ico";
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
					open my $fh, '>:raw', "$file";
						# or do {  };

					my $body;$body = sub {
						$h->unshift_read( chunk => $left > $BUFSIZE ? $BUFSIZE : $left, sub {
                            my $rd = $_[1];
							$left -= length $rd;
                            $h->{ on_error } = sub { close($fh) or die "Cannot close filehandler"; };
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
				elsif ($line =~ /^get\s+(.+)$/) {
                    say "Requested file is: $1";
                    my $file = $1;
                    my $size = -s $file;
                    defined $size or return say("File '$file': $!");
                    say "Downloading file '$file' of size $size";

                    my $left = $size;
                    my ($name) = $file =~ m{(?:^|/)([^/]+)$};
                    $h->push_write("get $size $name\n");
                    $h->push_read(line => sub {
                        if ($_[1] =~ /^OK\s+(\d+)/) {
                            say "Recieved OK with $1";
                            $h->unshift_read(chunk => $1, sub {
                                say $_[1];
                            });
                        }
                        else {
                            say "Not OK recieved";
                            say $_[1];
                        }
                    });
                    open my $f, '<:raw', $file or die("Failed to open file '$file': $!");
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
                                    say "write buffer ".length $h->{wbuf};
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
                        }
                    };$do->();

				}
				elsif ($line eq '') {
					# skip
				}
				else {
					given($line) {
						when ('ls') {
							#my $out = `ls -lA store`;
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
#        Scalar::Util::weaken $reader;
	};
},
sub {
	my ($fh,$host,$port) = @_;
	say "Listening on $host:$port";
	1024;
};


EV::loop();
#comment for check

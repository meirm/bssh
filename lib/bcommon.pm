#!/usr/bin/perl -w
# this script wrote on perl. it get file called NODES with IP of servers
# and execude SSH command. the command running in with fork.
#
# Created by Meir Michanie, meirm @ riunx.com
# date      : 03/04/2006
#
use strict;
use warnings;
=head1 Nodes file format

localhost:all
192.168.4.100:wawa,all
192.168.4.101:wawa,all

=cut


sub binit{
	my $path=glob("~/.bssh/");
	mkdir $path || die ($!);
	open(F,">$path/nodes") || die($!);
	print F "localhost:all";
	close(F);
	print STDERR "BSSH initialized\n";
	exit 0;
}
sub readsimplecfgfile{
	my (@files)=glob join(' ',@_);
	while ($_=shift @files){
	next unless -f $_;
	open(F,$_)||die $!;
	my @lines= grep (!/^#|^\s*$/, <F>);
	chomp @lines;
	close(F);
	return @lines;
	}
	return ();	
}
sub readsshparamsfile{
	#return &readsimplecfgfile('~/.bssh/sshparams /usr/local/bsshtools/etc/sshparams');
	return &readsimplecfgfile(qw(~/.bssh/sshparams /usr/local/bsshtools/etc/sshparams));
}
sub readnodesfile{
	my ($file) = @_;
	if ($file){
		return &readsimplecfgfile($file);
	}
	return &readsimplecfgfile(qw(~/.bssh/nodes /usr/local/bsshtools/etc/nodes));
}
sub list {
	&listnodes(@_);
}	

sub listhosts {
	map { print "$1\n" if m/^(\S+):/ } @_;
	}
sub listnodes {
	my @nodes=@_;
	chomp @nodes;
        my $count=0;
        foreach (@nodes){
        print "$count:$_\n";
        $count++;
        }
        exit ;
}
sub tolower {
	my @array=@_;
	foreach (@array){
		s/(.*)/\L$1\E/g;
	}
	return @array;
}
sub fetchnodes {
	my ($file) = @_;
	my @nodes= ();
	if ($file){
		@nodes = &readnodesfile($file);
	} else {
		@nodes = &readnodesfile();
	}
	@nodes= &tolower(@nodes);
	my @runnodes=();
	my @noruns=();
	my $targetdefined=0;
	unshift(@ARGV,'@all') unless @ARGV and ($ARGV[0]=~ m/^-?(\S+):/ or $ARGV[0]=~ m/^-?:([0-9]+)-([0-9]+)/ or $ARGV[0]=~ m/^-?@(\S+)/);
	while ( @ARGV and ($ARGV[0]=~ m/^-?(\S+):/ or $ARGV[0]=~ m/^-?:([0-9]+)-([0-9]+)/ or $ARGV[0]=~ m/^-?@(\S+)/)){ 
		if($ARGV[0]=~ m/^:([0-9]+)-([0-9]+)/){
			my ($start,$end)=($1,$2);
			for (my $count=$start; $count < $end +1; $count++){
				push @runnodes, $nodes[$count];
				$targetdefined++;
			}
			shift @ARGV;
		}elsif ($ARGV[0]=~ m/^@(\S+)/){
			$targetdefined++;
			my $group=$1;
			my @collection=grep (/:$group|:.*,$group/, @nodes);
			exit 1 unless @collection;
			push @runnodes, @collection ;
			shift @ARGV;
		}elsif ($ARGV[0]=~ m/^-(\S+):/){
			$targetdefined++;
			push @noruns, $1;
			shift @ARGV;
		}elsif($ARGV[0]=~ m/-:([0-9]+)-([0-9]+)/){
			$targetdefined++;
			my ($start,$end)=($1,$2);
			for (my $count=$start; $count < $end +1; $count++){
				push @noruns, $nodes[$count];
			}
			shift @ARGV;
		}elsif ($ARGV[0]=~ m/^-@(\S+)/){
			$targetdefined++;
			my $group=$1;
			my @collection=grep (/:$group|:.*,$group/, @nodes);
			exit 1 unless @collection;
			push @noruns, @collection ;
			shift @ARGV;
		}elsif ($ARGV[0]=~ m/^(\S+):/){
			$targetdefined++;
			push @runnodes, $1;
			shift @ARGV;
		}
	}
	exit 1 unless $targetdefined;
	my %RUNNODES;
	if (@runnodes>0){
		@runnodes= &tolower(@runnodes);
		foreach (@runnodes){
			s/:.*//g;
			$RUNNODES{$_}=1;
		}
	}else{ 
		foreach (@nodes){
			s/:.*//g;
		}
		%RUNNODES   = map { $_, 1 } @nodes;
	}
	foreach (@noruns){
		@noruns= &tolower(@noruns);
		s/:.*//g;
		$RUNNODES{$_}=0;
	}
	@nodes=();
	foreach (keys %RUNNODES){
		next unless $RUNNODES{$_};
		s/:.*//g;
		push  @nodes ,$_;
	}
	return sort(@nodes);
}

use POSIX ":sys_wait_h";

sub waitbchild{
  my @P=@_;
  my $kid;
   while(@P){
	   for(my $i=0; $i < @P; $i++){
		   $kid = waitpid($P[$i], WNOHANG);
	   	   splice(@P,$i,1) if $kid; 
		}
	}
}

1


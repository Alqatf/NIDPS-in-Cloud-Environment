#!/usr/bin/perl

##################################################################################
########## Script to generate an attack graph from Snort alert file ##############
##################################################################################

my $alertfile = '/var/log/snort/alert';
my $sagfile = '/var/log/snort/attackgraph';

open(my $fh, '<:encoding(UTF-8)', $alertfile)
	or die "Could not open file '$alertfile' $!";

my %mac;
my %attackCode;

my $timestamp;
my $attackType;
my $proto;
my $srcip, $srcmac, $srcport;
my $dstip, $dstmac, $dstport;

$mac{'10.0.0.5'}      = '00:00:00:00:00:05';
$mac{'10.0.0.6'}      = '00:00:00:00:00:06';
$mac{'syn_attack'}    = '00:00:00:00:00:01';
$mac{'icmp_attack'}   = '00:00:00:00:00:02';
$mac{'nmap_scan'}     = '00:00:00:00:00:03';
$mac{'legit_traffic'} = '00:00:00:00:00:04';

$attackCode{'syn'}  =  0;
$attackCode{'icmp'} = 1;
$attackCode{'scan'} = 2;

my $reICMP = '(\d\d\/\d\d.\d\d.\d\d.\d\d.\d+)\s+.*?\*\*\*(.*)?\*\*\*.*?{(\w+)}\s+(\d+.\d+.\d+.\d+)\s+\W\W\s+(\d+.\d+.\d+.\d+)';
my $reSYN  = '(\d\d\/\d\d.\d\d.\d\d.\d\d.\d+)\s+.*?\*\*\*(.*)?\*\*\*.*?{(\w+)}\s+(\d+.\d+.\d+.\d+):(\d+)\s+\W\W\s+(\d+.\d+.\d+.\d+):(\d+)';
my $reNMAP = '(\d\d\/\d\d.\d\d.\d\d.\d\d.\d+)\s+.*?(SCAN.*?)Priority:\s+\d.\s+{(\w+)}\s+(\d+.\d+.\d+.\d+):(\d+)\s+\W\W\s+(\d+.\d+.\d+.\d+):(\d+)';

my $syn_attack_detected = 0;
my $icmp_attack_detected = 0;
my $nmap_scan_detected = 0;


open (my $fh2, '>>', $sagfile);

while(my $row = <$fh>) {
	chomp $row;
	print "Row : $row\n\n";
	if($row =~ /$reSYN/) {
		if($syn_attack_detected == 0) {
			print "$1 :: $2 :: $3 :: $4 :: $5 :: $6 :: $7\n\n";
			$timestamp = $1;
			$attackType = $attackCode{'syn'};
			$proto = $3;
			$srcip = $4;
			$srcport = $5;
			$srcmac = $mac{'syn_attack'};
			$dstip = $6;
			$dstport = $7;
			$dstmac = $mac{$dstip};
			print "$timestamp :: $attackType :: $proto :: $srcip :: $srcport :: $srcmac :: $dstip :: $dstport :: $dstmac\n\n";
			#open (my $fh2, '>>', $sagfile);
			print $fh2 "$timestamp::$attackType::$proto::$srcip::$srcport::$srcmac::$dstip::$dstport::$dstmac\n";
			#close($fh2);
			$syn_attack_detected = 1;
		}
	}

	elsif($row =~ /$reICMP/) {
		if($icmp_attack_detected == 0) {
			print "$1 :: $2 :: $3 :: $4 :: $5\n\n";
			$timestamp = $1;
			$attackType = $attackCode{'icmp'};
			$proto = $3;
			$srcip = $4;
			$srcmac = $mac{'icmp_attack'};
			$dstip = $5;
			$dstmac = $mac{$dstip};
			print "ICMP Attack $timestamp :: $attackType :: $proto :: $srcip :: $srcmac :: $dstip :: $dstmac\n\n";
			#open (my $fh2, '>>', $sagfile);
			print $fh2, "$timestamp::$attackType::$proto::$srcip::$srcmac::$dstip::$dstmac\n";
			#close($fh2);
			$icmp_attack_detected = 1;
		}
	}

	elsif($row =~ /$reNMAP/) {
		if($nmap_scan_detected == 0) {
			print "$1 :: $2 :: $3 :: $4 :: $5 :: $6 :: $7\n\n";
			$timestamp = $1;
			$attackType = $attackCode{'scan'};
			$proto = $3;
			$srcip = $4;
			$srcport = $5;
			$srcmac = $mac{'nmap_scan'};
			$dstip = $6;
			$dstport = $7;
			$dstmac = $mac{$dstip};
			print "$timestamp :: $attackType :: $proto :: $srcip :: $srcport :: $srcmac :: $dstip :: $dstport :: $dstmac\n\n";
			#open (my $fh2, '>>', $sagfile);
			print $fh2 "$timestamp::$attackType::$proto::$srcip::$srcport::$srcmac::$dstip::$dstport::$dstmac\n";
			#close($fh2);
			$nmap_scan_detected = 1;
		}
	}
}

close($fh2);
close($fh);

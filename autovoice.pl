# /AUTOVOICE <*|#channel> [<nickmasks>]
use Irssi; use strict; use vars qw($VERSION %IRSSI);

$VERSION = "1.00"; %IRSSI = (
    authors => 'Jim Nelin',
    name => 'autovoice',
    description => 'Simple auto-voice script',
    license => 'Public Domain',
    changed	=> 'Fri Apr 19 03:38 EET 2013' );

my (%voicenicks, %temp_voiced); sub cmd_autovoice {
	my ($data) = @_;
	my ($channel, $masks) = split(" ", $data, 2);
	if ($channel eq "") {
		if (!%voicenicks) {
			Irssi::print("Usage: /AUTOVOICE <*|#channel> [<nickmasks>]");
			Irssi::print("No-one's being auto-voiced currently.");
			return;
		}
		Irssi::print("Currently auto-voiceing in channels:");
		foreach $channel (keys %voicenicks) {
			$masks = $voicenicks{$channel};
			if ($channel eq "*") {
				Irssi::print("All channels: $masks");
			} else {
				Irssi::print("$channel: $masks");
			}
		}
		return;
	}
	if ($masks eq "") {
		$masks = "<no-one>";
		delete $voicenicks{$channel};
	} else {
		$voicenicks{$channel} = $masks;
	}
	if ($channel eq "*") {
		Irssi::print("Now auto-voiceing in all channels: $masks");
	} else {
		Irssi::print("$channel: Now auto-voiceing: $masks");
	}
}
sub autovoice {
	my ($channel, $masks, @nicks) = @_;
	my ($server, $nickrec, $channame);
	$server = $channel->{server};
	$channame = $channel->{'name'};
	foreach $nickrec (@nicks) {
		my $nick = $nickrec->{nick};
		my $host = $nickrec->{host};
                if (!$temp_voiced{$nick} &&
		    $server->masks_match($masks, $nick, $host)) {
			$channel->command("/msg chanserv voice $channame $nick");
			$temp_voiced{$nick} = 1;
		}
	}
}
sub event_massjoin {
	my ($channel, $nicks_list) = @_;
	my @nicks = @{$nicks_list};
	#return if (!$channel->{chanop});
	undef %temp_voiced;
	# channel specific
	my $masks = $voicenicks{$channel->{name}};
	autovoice($channel, $masks, @nicks) if ($masks);
	# for all channels
	$masks = $voicenicks{"*"};
	autovoice($channel, $masks, @nicks) if ($masks);
}
Irssi::command_bind('autovoice', 'cmd_autovoice'); 
Irssi::signal_add_last('massjoin', 'event_massjoin');

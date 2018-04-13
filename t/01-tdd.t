use Test;

use-ok "Test::Time";

my $*SCHEDULER;
use Test::Time;
isa-ok &mock-time, Sub;
isa-ok &unmock-time, Sub;
throws-like { unmock-time }, X::AdHoc, :message => "Time isn't mocked yet";
lives-ok { mock-time };
lives-ok { unmock-time };

my $tai = now - time;
$*SCHEDULER = mock-time $tai;
is now, $tai;
is time, 0;
unmock-time;
isnt now, $tai;
isnt time, 0;

$*SCHEDULER = mock-time :auto-advance;

my $before-now  = now;
my $before-time = time;
sleep 10;
cmp-ok now - $before-now, ">=", 10;
is time - $before-time, 10 | 11;
sleep 20;
cmp-ok now - $before-now, ">=", 30;
is time - $before-time, 30 | 31;

unmock-time;

cmp-ok now - $before-now, "<", 1;
is time - $before-time, 0 | 1;


use Test;

use-ok "Test::Time";

use Test::Time;
isa-ok &mock-time, Sub;
isa-ok &unmock-time, Sub;
throws-like { unmock-time }, X::AdHoc, :message => "Time isn't mocked yet";
lives-ok { mock-time };
lives-ok { unmock-time };

my $tai = now - time;
mock-time $tai;
is now, $tai;
is time, 0;
unmock-time;
isnt now, $tai;
isnt time, 0;

my $before-now  = now;
my $before-time = time;
mock-time;
sleep 10;
cmp-ok now - $before-now, ">=", 10;
is time - $before-time, 10;
unmock-time;
cmp-ok now - $before-now, "<", 1;
is time - $before-time, 0;

$before-now     = now;
$before-time    = time;
mock-time realy-sleep => 1;
sleep 10;
cmp-ok now - $before-now,   ">=", 10;
is time - $before-time, 10;
unmock-time;
cmp-ok now - $before-now, ">=", 1;
cmp-ok now - $before-now, "<", 2;
is time - $before-time, 1;

$before-now     = now;
$before-time    = time;
mock-time :exact, realy-sleep => * / 10;
sleep 10;
cmp-ok now - $before-now, ">=", 10;
is time - $before-time, 9;
unmock-time;
cmp-ok now - $before-now, ">=", 1;
cmp-ok now - $before-now, "<", 2;
is time - $before-time, 1;

mock-time :exact;
my $b = now;
sleep 1;
is now, $b + 1;
unmock-time;

subtest {
    plan 1;
    use Test::Scheduler;
    my $*SCHEDULER = Test::Scheduler.new;
    my $before = now;
    my $p = Promise.in: 100;
    mock-time;
    sleep 100;
    react whenever $p {
        unmock-time;
        cmp-ok Int(now - $before), "<", 1;
    }
    await $p;
}

done-testing

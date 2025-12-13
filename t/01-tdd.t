use Test;

use Test::Time;
use-ok "Test::Time";

my $scheduler = $*SCHEDULER;

subtest {
    isa-ok &mock-time, Sub;
    isa-ok &unmock-time, Sub;
    throws-like { unmock-time }, X::AdHoc, :message => "Time isn't mocked yet";
    lives-ok { mock-time };
    lives-ok { unmock-time };
}

subtest {
    my $tai = now - time;
    my $*SCHEDULER = mock-time $tai;
    is now, $tai;
    is time, 0;
    unmock-time;
    isnt now, $tai;
    isnt time, 0;
}

subtest {
    plan 6;
    my $init = Promise.new;
    my $SCHEDULER = mock-time;
    my $p = start {
        my $*SCHEDULER = $SCHEDULER;
        my $before-now  = now;
        my $before-time = time;
        $init.keep;
        sleep 10;
        cmp-ok now - $before-now, ">=", 10;
        is time - $before-time, 10;
        sleep 20;
        cmp-ok now - $before-now, ">=", 30;
        is time - $before-time, 30;

        unmock-time;

        cmp-ok now - $before-now, "<", 1, "{now} - $before-now";
        is time - $before-time, 1, "{time} - $before-time";
    }
    await $init;
    $SCHEDULER.advance-by: 10;
    $SCHEDULER.advance-by: 20;
    $SCHEDULER.advance-by: 20;
    await $p
}

subtest {
    my $*SCHEDULER = mock-time :auto-advance;

    my $before-now  = now;
    my $before-time = time;
    sleep 10;
    cmp-ok now - $before-now, ">=", 10;
    cmp-ok time - $before-time, ">=", 10;
    sleep 20;
    cmp-ok now - $before-now, ">=", 30;
    cmp-ok time - $before-time, ">=", 30;

    unmock-time;

    cmp-ok now - $before-now, "<", 1, "{now} - $before-now";
    cmp-ok time - $before-time, "<", 5, "{time} - $before-time";
}

subtest {
    #use v6.d.PREVIEW;
    plan 3;
    my $SCHEDULER = mock-time;
    my $p2 = Promise.new;
    my $p = start {
        my $*SCHEDULER = $SCHEDULER;
        my $start = now;
        pass "before";
        $p2.keep;
        sleep 50;
        pass "after";
        cmp-ok now - $start, ">=", 50;
    }

    await $p2;
    $SCHEDULER.advance-by: 50;
    await $p;
}

done-testing

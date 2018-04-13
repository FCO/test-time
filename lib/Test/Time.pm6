use Test::Scheduler;
my %wraps;

sub unmock-time is export {
    die "Time isn't mocked yet";
}

sub mock-time(Instant $now is copy = now, Bool :$auto-advance = False, Rat() :$interval = .1 --> Scheduler) is export {
    my $*SCHEDULER = Test::Scheduler.new: :virtual-time($now);

    my $tai = now - time;
    %wraps<sleep> = &sleep.wrap: -> \seconds {
        await Promise.in: seconds;
        Nil
    }

    %wraps<now>     = &term:<now>.wrap:  { $*SCHEDULER.virtual-time }
    %wraps<time>    = &term:<time>.wrap: { (now - $tai).Int }
    %wraps<unmock>  = &unmock-time.wrap: {
        &sleep.unwrap:          %wraps<sleep>;
        &term:<now>.unwrap:     %wraps<now>;
        &term:<time>.unwrap:    %wraps<time>;
        &unmock-time.unwrap:    %wraps<unmock>;

        %wraps = ()
    }

    start {
        while %wraps.elems {
            $*SCHEDULER.advance-by: $interval
        }
    } if $auto-advance;

    $*SCHEDULER
}

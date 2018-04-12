my %wraps;

sub unmock-time is export {
    die "Time isn't mocked yet";
}

sub mock-time(Instant $now is copy = now, Bool :$exact = False, :$realy-sleep = 0) is export {
    my &rs;
    if $realy-sleep ~~ Callable {
        &rs = $realy-sleep
    } else {
        &rs = -> $ { $realy-sleep }
    }

    my $tai = now - time;
    %wraps<sleep> = &sleep.wrap: -> \seconds {
        $now += seconds + ($exact ?? 0 !! .01.rand);
        callwith(rs seconds);
        $*SCHEDULER.advance-by(seconds) if $*SCHEDULER.^can("advance-by");
        Nil
    }

    %wraps<now>     = &term:<now>.wrap:  { $now }
    %wraps<time>    = &term:<time>.wrap: { ($now - $tai).Int }
    %wraps<unmock>  = &unmock-time.wrap: {
        &sleep.unwrap:          %wraps<sleep>;
        &term:<now>.unwrap:     %wraps<now>;
        &term:<time>.unwrap:    %wraps<time>;
        &unmock-time.unwrap:    %wraps<unmock>;

        %wraps = ()
    }
}

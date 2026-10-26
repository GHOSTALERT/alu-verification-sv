#!/usr/bin/env perl
# Summarise the regression transcripts in a directory as Markdown.
#
#   perl scripts/parse_logs.pl results/runs > results/summary.md
use strict;
use warnings;

my $dir = shift // 'results/runs';
my @names = qw(ADD SUB AND OR XOR SHL SHR PASS);

opendir(my $dh, $dir) or die "cannot open $dir: $!";
my @files = sort { by_run($a, $b) } grep { /\.transcript$/ } readdir($dh);
closedir($dh);

print "# Regression summary\n\n";
print "| Run | Seed | Txns | Pass | Fail | Assert fails | Opcode coverage | "
    . join(' | ', @names) . " |\n";
print "|" . ("---|" x (7 + @names)) . "\n";

my (%total, %opcode_total, @failures);
for my $file (@files) {
    (my $run = $file) =~ s/\.transcript$//;
    open(my $fh, '<', "$dir/$file") or die "cannot read $file: $!";
    my ($seed, %s, @ops) = ('-');
    my ($last_txn, $last_mon);
    while (my $line = <$fh>) {
        $seed = $1 if $line =~ /-sv_seed (\d+)/;
        $ops[$1] = $2 if $line =~ /Opcode (\d) executed (\d+) times/;
        %s = (txns => $1, pass => $2, fail => $3, assert => $4, cov => $5)
            if $line =~ /SUMMARY: txns=(\d+) pass=(\d+) fail=(\d+) assert_fail=(\d+) opcode_cov=(\d+)/;
        $last_mon = $1 if $line =~ /MONITOR: (.*)/;
        push @failures, "$run: $last_mon -> $1"
            if $line =~ /FAIL: (Expected=\d+ Got=\d+)/ && @failures < 5;
    }
    close($fh);
    die "no SUMMARY line in $file\n" unless %s;

    print "| $run | $seed | $s{txns} | $s{pass} | $s{fail} | $s{assert} | $s{cov}/8 | "
        . join(' | ', map { $_ // 0 } @ops[0..7]) . " |\n";

    next if $run =~ /bug/;
    $total{$_} += $s{$_} for qw(txns pass fail assert);
    $total{full_cov}++ if $s{cov} == 8;
    $total{runs}++;
    $opcode_total{$_} += ($ops[$_] // 0) for 0..7;
}

print "\nClean-ALU runs: $total{runs}, transactions: $total{txns}, "
    . "pass: $total{pass}, fail: $total{fail}, assertion failures: $total{assert}. "
    . "Runs with all 8 opcodes covered: $total{full_cov}/$total{runs}.\n";
print "Opcode totals over clean runs: "
    . join(', ', map { "$names[$_]=$opcode_total{$_}" } 0..7) . ".\n";

if (@failures) {
    print "\nFirst failures caught in the bug-injection run:\n\n";
    print "- `$_`\n" for @failures;
}

# seed_2 before seed_10, then the named runs
sub by_run {
    my ($x, $y) = @_;
    my ($nx) = $x =~ /^seed_(\d+)/;
    my ($ny) = $y =~ /^seed_(\d+)/;
    return $nx <=> $ny if defined $nx && defined $ny;
    return -1 if defined $nx;
    return 1  if defined $ny;
    return $x cmp $y;
}

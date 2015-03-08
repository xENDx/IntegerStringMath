# tests IntegerStringMath.pm
# by Michael Appleby


use lib './lib';
use lib '../lib';
use IntegerStringMath;

sub println (@) { print join ' ', @_; print "\n"; }

# prints only if not equal
sub test ($$$) {
	my ($pre, $a, $b) = @_;
	$pre //= '';
	if (ref $a eq 'ARRAY') {
		my $same = 1;
		for my $i (0 .. $#_) {
			if ($a -> [$i] ne $b -> [$i]) {
				$same = 0;
			}
		}
		if (not $same) {
			println $pre, @{$a}, @{$b};
		}
	} else {
		println $pre, $a, $b if $a ne $b; 
	}
}

my @t1 = qw/-1 0 1 1234 -23456 345678 -456789 9999989 -391842904882/;
my @t2 = qw/-1 1 2 3 5 8 13 -21 34 55 89 144 233 377 610 -987 -1597 2584 4181/;

println "test greaterthan";
for my $a (@t1) { for my $b (@t2) {
	test "$a>$b: ", ($a>$b?'1':'0'), greaterthan "$a", "$b";
}}

println "test add";
for my $a (@t1) { for my $b (@t2) {
	test "$a+$b: ", ($a+$b), add "$a", "$b";
}}

println "test subtract";
for my $a (@t1) { for my $b (@t2) {
	test "$a-$b: ", ($a-$b), subtract "$a", "$b";
}}

println "test multiply";
for my $a (@t1) { for my $b (@t2) {
	test "$a*$b: ", ($a*$b), multiply "$a", "$b";
}}

println "test divide_integer";
for my $a (@t1) { for my $b (@t2) {
	test "$a/$b", [int($a/$b), $a%$b], divide_integer $a, $b;
}}

println "complete";

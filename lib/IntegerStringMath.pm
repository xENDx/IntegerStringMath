# does integer math on strings without using arithmetic
# by Michael Appleby

use strict;
use warnings;

sub set_digits;

sub greaterthan;
sub greaterthanequal;
sub lessthan;
sub lessthanequal;
sub equal;
sub notequal;

sub negative;
sub increment;
sub decrement;
sub add;
sub subtract;
sub multiply;
sub divide_integer; # returns [ a/b , a%b ]

my $digits = '0123456789';
my @digits = split '', $digits;
my $zero  = '0';
my $one   = '1';
my $nine  = '9';
my $original_digits = 'true'; # some calculations can cheat with 0..9 to be faster ## ex: increment

sub set_digits ($) {
	my $test = shift;
	my $test2 = "$test";
	while ($test !~ /^$/) {
		$test =~ s/^(.)//;
		my $d = $1;
		die "duplicate '$d' found in digits" if $test =~ /$d/;
	}
	$test =~ /^(.)(.)/ or die "number of digits must be greater than 1";
	$zero = $1;
	$one = $2;
	$test =~ /(.)$/;
	$nine = $2;
	$digits = $test2;
	@digits = split '', $digits;
	$original_digits = '';
	return $digits;
}

sub get_digits () { return $digits; }

sub confirmnumber($) { my $x = shift; $x =~ /^-?[$digits]+$/ or die "NaN: '$x'"; $one }

sub negative ($) {
	my $x = shift;
	confirmnumber $x;
	if ($x =~ s/^-//) { return $x; }
	else { return '-' . $x; }
}

sub greaterthan ($$) {
	my ($a, $b) = @_;
	confirmnumber $a;
	confirmnumber $b;
	return $zero if $a eq $b;
	if ($a =~ s/^-//) { if ($b =~ s/^-//) { # -a, -b
		return greaterthan( $b, $a );
	} else { # -a, b
		return $zero;
	}} elsif ($b =~ /^-/) { # a, -b
		return $one;
	} elsif ($a =~ /^.$/) { if ($b =~ /^.$/) { # a == 1, b == 1
		while ($a ne $zero and $b ne $zero) {
			$a = decrement $a;
			$b = decrement $b;
		}
		return $b eq $zero ? $one : $zero;
	} else { # a == 1, b > 1
		return $zero;
	}} elsif ($b =~ /^.$/) { # a > 1, b == 1
		return $one;
	} else { # a > 1, b > 1
		$a =~ /^(.*)(.)$/; my ($a_, $_a) = ($1, $2);
		$b =~ /^(.*)(.)$/; my ($b_, $_b) = ($1, $2);
		if ($a_ eq $b_) { return greaterthan ($_a, $_b); }
		else            { return greaterthan ($a_, $b_); }
	}
}
sub lessthan         ($$) { my ($a, $b) = @_; return                   greaterthan ($b, $a); }
sub greaterthanequal ($$) { my ($a, $b) = @_; return $a eq $b ? $one : greaterthan ($a, $b); }
sub lessthanequal    ($$) { my ($a, $b) = @_; return $a eq $b ? $one : lessthan    ($a, $b); }
sub equal            ($$) { my ($a, $b) = @_; return $a eq $b ? $one : $zero; }
sub notequal         ($$) { my ($a, $b) = @_; return $a ne $b ? $one : $zero; }


sub increment($) {
	my $x = shift;
	confirmnumber $x;
	if ($x =~ s/^-//) {
		if ($x eq $one) { return $zero; }
		return '-' . decrement $x;
	} elsif ($x =~ /^(.*)$nine$/) {
		if ($1) {
			return increment ($1) . $zero;
		} else {
			return $one . $zero; # 10
		}
	} else {
		if ($original_digits) { # because it's faster
			$x =~ s/8$/9/;
			$x =~ s/7$/8/;
			$x =~ s/6$/7/;
			$x =~ s/5$/6/;
			$x =~ s/4$/5/;
			$x =~ s/3$/4/;
			$x =~ s/2$/3/;
			$x =~ s/1$/2/;
			$x =~ s/0$/1/;
		} else {
			my $previousdigit = '';
			for my $digit (reverse @digits) {
				if ($previousdigit =~ /./) {
					$x =~ s/$digit$/$previousdigit/;
				}
				$previousdigit = $digit;
			}
		}
		return $x;
	}
}

sub decrement($) {
	my $x = shift;
	confirmnumber $x;
	if ($x =~ s/^-//) {
		return '-' . increment $x;
	} elsif ($x eq $zero) {
		return '-' . $one;
	} elsif ($x eq $one . $zero) {
		return $nine;
	} elsif ($x =~ /^(.+)$zero$/) {
		return ((decrement $1) . $nine);
	} else {
		if ($original_digits) { # because it's faster
			$x =~ s/1$/0/;
			$x =~ s/2$/1/;
			$x =~ s/3$/2/;
			$x =~ s/4$/3/;
			$x =~ s/5$/4/;
			$x =~ s/6$/5/;
			$x =~ s/7$/6/;
			$x =~ s/8$/7/;
			$x =~ s/9$/8/;
		} else {
			my $previousdigit = '';
			for my $digit (@digits) {
				if ($previousdigit =~ /./) {
					$x =~ s/$digit$/$previousdigit/;
				}
				$previousdigit = $digit;
			}
		}
		return $x;
	}
}

sub add($$;@) {
	my ($a, $b) = (shift(), shift());
	confirmnumber $a;
	confirmnumber $b;
	my ($x_, $_x, $x); # will return x or x_._x
	if ($a =~ s/^-//) { if ($b =~ s/^-//) { # -a, -b
		$x = '-' . add( $a, $b );
	} else { # -a, b
		$x = subtract( $b, $a );
	}} elsif ($b =~ s/^-//) { # a, -b
		$x = subtract( $a, $b );
	} elsif ($b =~ /^.$/) {
		while ($b ne $zero) {
			$a = increment $a;
			$b = decrement $b;
		}
		$x = $a;
	} elsif ($a =~ /^.$/) {
		while ($a ne $zero) {
			$a = decrement $a;
			$b = increment $b;
		}
		$x = $b;
	} else { # a > 1 and b > 1
		$a =~ /^(.*)(.)$/; my ($a_, $_a) = ($1, $2);
		$b =~ /^(.*)(.)$/; my ($b_, $_b) = ($1, $2);
		$x_ = add( $a_, $b_ );
		$_x = add( $_a, $_b );
		if ($_x =~ /^..$/) {
			$x_ = increment $x_;
			$_x =~ s/^.//;
		}
	}
	if (not defined $x or $x =~ /^$/) {
		$x = $x_ . $_x;
	}
	$x =~ s/^--//;
	if (@_) {
		return add($x, @_);
	} else {
		return $x;
	}
}

sub subtract($$) {
	my ($a, $b) = (shift(), shift());
	confirmnumber $a;
	confirmnumber $b;
	return $zero if $a eq $b;
	my $x;
	if ($a =~ s/^-//) { if ($b =~ s/^-//) { # -a, -b
		$x = '-' . subtract( $a, $b );
	} else { # -a, b
		$x = '-' . add( $a, $b );
	}} elsif ($b =~ s/^-//) { # a, -b
		$x = add( $a, $b );
	} elsif ($a =~ /^.$/) {
		while ($a ne $zero) {
			$a = decrement $a;
			$b = decrement $b;
		}
		$x = '-' . $b;
	} elsif ($b =~ /^.$/) {
		while ($b ne $zero) {
			$a = decrement $a;
			$b = decrement $b;
		}
		$x = $a;
	} else { # a > 1 and b > 1
		$a =~ /^(.*)(.)$/; my ($a_, $_a) = ($1, $2);
		$b =~ /^(.*)(.)$/; my ($b_, $_b) = ($1, $2);
		my ($x_, $_x);
		$x_ = subtract( $a_, $b_ );
		$_x = subtract( $_a, $_b );
		$x = $x_ . $zero;
		$x =~ s/^$zero++//;
		$x = $zero if $x =~ /^$/;
		if ($_x =~ /^-/) {
			while ($_x ne $zero) {
				$_x = increment $_x;
				$x = decrement $x;
			}
		} else {
			while ($_x ne $zero) {
				$_x = decrement $_x;
				$x = increment $x;
			}
		}
	}
	$x =~ s/^--//;
	return $x;
}

sub multiply ($$;@) {
	my ($a, $b) = (shift(), shift());
	confirmnumber $a;
	confirmnumber $b;
	if ($a eq $zero or $b eq $zero) { return $zero; }
	my $sign;
	if ($a =~ s/^-//) { if ($b =~ s/^-//) { $sign =  ''; }
	else                                  { $sign = '-'; }}
	elsif ($b =~ s/^-//)                  { $sign = '-'; }
	else                                  { $sign =  ''; }
	my $x;
	if ($a =~ /^.$/) {
		$x = $b;
		while ($a ne $one) {
			$x = add $b, $x;
			$a = decrement $a;
		}
	} elsif ($b =~ /^.$/) {
		$x = $a;
		while ($b ne $one) {
			$x = add $a, $x;
			$b = decrement $b;
		}
	} else { # a > 1 and b > 1
		$b =~ /^(.*)(.)$/; my ($b_, $_b) = ($1, $2);
		$x = add( multiply( $a, $b_ ) . $zero, multiply( $a, $_b ) ); # a*b_*10 + a*_b
	}
	if (@_) {
		return multiply ($sign . $x, @_);
	} else {
		return $sign . $x;
	}
}

# note:
#   a  b  /  %
#  17  5  3  2 
#  17 -5 -3 -3 
# -17  5 -3  3 
# -17 -5  3 -2 

# returns ([0] / [1], remainder)
sub divide_integer ($$) {
	my ($a, $b) = @_;
	confirmnumber $a;
	confirmnumber $b;
	my $sign = '';
	if ($a =~ s/^-//) { if ($b =~ s/^-//) { $sign = '-a-b'; }  # -a -b
	else                                  { $sign = '-a+b'; }} # -a  b
	elsif ($b =~ s/^-//)                  { $sign = '+a-b'; }  #  a -b
	else                                  { $sign = '+a+b'; }  #  a  b
	my $x = '';
	if (lessthan $a, $b) {
		$x = $zero;
	} else {
		my $b_ = $b;
		my $_b = '';
		while (greaterthanequal $a, $b_.$_b.$zero) {
			$_b .= $zero;
		}
		my $digit;
		while ('true') {
			$digit = $zero;
			while (greaterthanequal $a, $b_.$_b) {
				$a = subtract $a, $b_.$_b;
				$digit = increment $digit;
			}
			$x = $x . $digit;
			if ($_b !~ /$zero/) { last; }
			$_b =~ s/$zero//;
		}
	}
	if    ($sign eq '+a-b') { $x = '-' . $x; $a =          subtract $a, $b if $a ne $zero; }
	elsif ($sign eq '-a+b') { $x = '-' . $x; $a = negative subtract $a, $b if $a ne $zero; }
	elsif ($sign eq '-a-b') {                $a = negative          $a     if $a ne $zero; }
	$x = $zero if $x eq '-' . $zero;
	$a = $zero if $a eq '-' . $zero;
	return [$x, $a];
}

$one;

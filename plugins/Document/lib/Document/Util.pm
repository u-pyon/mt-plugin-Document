package Document::Util;

use strict;

require Exporter;
@Document::Util::ISA = qw(Exporter);
@Document::Util::EXPORT_OK = qw(array_search trim);

sub array_search {
	my ($needle, @array) = @_;
	my $c = @array;
	return 0 if ! $needle or @array <= 0;
	my $ref = ref $needle ? ref $needle : ref \$needle;
	foreach (@array) {
		if ( $ref eq 'SCALAR' ) {
			return 1 if $needle eq $_;
		} else {
			return 1 if $needle == $_;
		}
	}
	0;
}

sub trim {
	my $value = shift;
	return unless defined $value;
	if ( ref $value eq 'ARRAY') {
		trim($_) foreach @$value;
	} else {
		$_ = $value;
		s/^\s+//m;
		s/\s+$//m;
	}
}
1;

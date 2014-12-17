package DDG::Publisher::Site::Donttrackus;
$DDG::Publisher::Site::Donttrackus::VERSION = '1043';
use MooX;
use DDGC::Locale::DuckduckgoDonttrackus;

with qw(
	DDG::Publisher::SiteRole
);

sub default_hostname { 'donttrack.us' }

sub dirs_classes {qw(
	Root
)}

sub locale_package { 'DDGC::Locale::DuckduckgoDonttrackus' }
sub locale_dist { 'DDGC-Locale-DuckduckgoDonttrackus' }
sub locale_domain { 'duckduckgo-donttrackus' }

1;

__END__

=pod

=head1 NAME

DDG::Publisher::Site::Donttrackus

=head1 VERSION

version 1043

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by DuckDuckGo, Inc. L<http://duckduckgo.com/>.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

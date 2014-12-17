package DDG::Publisher::Site::Fixtracking;
$DDG::Publisher::Site::Fixtracking::VERSION = '1042';
use MooX;
use DDGC::Locale::DuckduckgoFixtracking;

with qw(
	DDG::Publisher::SiteRole
);

sub default_hostname { 'fixtracking.com' }

sub dirs_classes {qw(
	Root
)}

sub locale_package { 'DDGC::Locale::DuckduckgoFixtracking' }
sub locale_dist { 'DDGC-Locale-DuckduckgoFixtracking' }
sub locale_domain { 'duckduckgo-fixtracking' }

1;

__END__

=pod

=head1 NAME

DDG::Publisher::Site::Fixtracking

=head1 VERSION

version 1042

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by DuckDuckGo, Inc. L<http://duckduckgo.com/>.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

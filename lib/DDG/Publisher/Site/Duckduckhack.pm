package DDG::Publisher::Site::Duckduckhack;
$DDG::Publisher::Site::Duckduckhack::VERSION = '1044';
use MooX;

with qw(
	DDG::Publisher::SiteRole
);

sub default_hostname { 'duckduckhack.com' }

sub dirs_classes {qw(
	Root
)}

sub locale_package { 'DDGC::Locale::DuckduckgoDuckduckgo' }
sub locale_dist { 'DDGC-Locale-DuckduckgoDuckduckgo' }
sub locale_domain { 'duckduckgo-duckduckgo' }

1;

__END__

=pod

=head1 NAME

DDG::Publisher::Site::Duckduckhack

=head1 VERSION

version 1044

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by DuckDuckGo, Inc. L<http://duckduckgo.com/>.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

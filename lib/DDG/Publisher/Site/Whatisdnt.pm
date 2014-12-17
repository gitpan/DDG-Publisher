package DDG::Publisher::Site::Whatisdnt;
$DDG::Publisher::Site::Whatisdnt::VERSION = '1044';
use MooX;
use DDGC::Locale::DuckduckgoWhatisdnt;

with qw(
	DDG::Publisher::SiteRole
);

sub default_hostname { 'whatisdnt.com' }

sub dirs_classes {qw(
	Root
)}

sub locale_package { 'DDGC::Locale::DuckduckgoWhatisdnt' }
sub locale_dist { 'DDGC-Locale-DuckduckgoWhatisdnt' }
sub locale_domain { 'duckduckgo-whatisdnt' }

1;

__END__

=pod

=head1 NAME

DDG::Publisher::Site::Whatisdnt

=head1 VERSION

version 1044

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by DuckDuckGo, Inc. L<http://duckduckgo.com/>.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

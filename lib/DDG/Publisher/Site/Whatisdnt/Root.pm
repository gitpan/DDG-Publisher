package DDG::Publisher::Site::Whatisdnt::Root;
$DDG::Publisher::Site::Whatisdnt::Root::VERSION = '1042';
use MooX;

with qw(
	DDG::Publisher::DirRole
);

sub path { '/' }

sub pages {{
	index => sub {},
}}

1;

__END__

=pod

=head1 NAME

DDG::Publisher::Site::Whatisdnt::Root

=head1 VERSION

version 1042

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by DuckDuckGo, Inc. L<http://duckduckgo.com/>.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

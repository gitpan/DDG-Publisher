package DDG::Publisher::DirRole;
# ABSTRACT: The role for a directory in the publisher system
$DDG::Publisher::DirRole::VERSION = '1044';
use MooX::Role;
use DDG::Publisher::File;

requires qw(
	path
	pages
);


has key => (
	is => 'ro',
	required => 1,
);


has site => (
	is => 'ro',
	required => 1,
);


has files => (
	is => 'ro',
	lazy => 1,
	builder => 1,
);

sub _build_files {
	my ( $self ) = @_;
	my %pages = %{$self->pages_coderefs};
	my @locales = $self->site->locales;
	my %files;
	for my $page (keys %pages) {
		my $code = $pages{$page};
		for my $locale (@locales) {
			my $file = DDG::Publisher::File->new(
				code => $code,
				filebase => $page,
				locale => $locale,
				dir => $self,
			);
			$files{$page}->{$locale} = $file;
		}
	}
	my $default_locale = $self->site->default_locale;
	my %statics = %{$self->statics_coderefs};
	for my $static (keys %statics) {
		my $code = $statics{$static};
		my $file = DDG::Publisher::File->new(
			code => $code,
			filebase => $static,
			locale => $default_locale,
			dir => $self,
			static => 1,
		);
		$files{$static} = $file;
	}
	return \%files;
}


has fullpath_files => (
	is => 'ro',
	lazy => 1,
	builder => 1,
);

sub _build_fullpath_files {
	my ( $self ) = @_;
	my %fullpath_files;
	for (values %{$self->files}) {
		if (ref $_ eq 'HASH') {
			for (values %{$_}) {
				die "The file ".$_->fullpath." already exist!!!" if defined $fullpath_files{$_->fullpath};
				$fullpath_files{$_->fullpath} = $_;
			}
		} else {
			die "The file ".$_->fullpath." already exist!!!" if defined $fullpath_files{$_->fullpath};
			$fullpath_files{$_->fullpath} = $_;			
		}
	}
	return \%fullpath_files;
}


has pages_coderefs => (
	is => 'ro',
	lazy => 1,
	builder => 'pages',
);

sub pages {{}}


has statics_coderefs => (
	is => 'ro',
	lazy => 1,
	builder => 'statics',
);

sub statics {{}}


has web_path => (
	is => 'ro',
	lazy => 1,
	builder => 1,
);

sub _build_web_path { my @path = shift->path; defined $path[1] ? $path[1] : $path[0] }


has template_path => (
	is => 'ro',
	lazy => 1,
	builder => 1,
);

sub _build_template_path { my @path = shift->path; $path[0] }

1;

__END__

=pod

=head1 NAME

DDG::Publisher::DirRole - The role for a directory in the publisher system

=head1 VERSION

version 1044

=head1 ATTRIBUTES

=head2 key

The key inside the site for this directory. Required for instantiation.

=head2 site

Site object for this directory. Required for instantiation.

=head2 files

Contains a hash of the files for this directory.

=head2 fullpath

This hash also contains all files, but with the full path on the filesystem
as key, so that collides can be detected.

=head2 pages_coderefs

This attribute contains all the coderefs for the pages that have to be
generated for this specific directory. It uses L<pages> as builder. Normally
you override L<pages> in your site class.

=head2 statics_coderefs

This attribute contains all the coderefs for the static pages that have to be
generated for this specific directory. It uses L<statics> as builder. Normally
you override L<statics> in your site class. A static file is not generated for
every language

=head2 web_path

The path on the web for this directory.

=head2 template_path

This is the path inside the templates, used for the pages and statics of this
directory.

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by DuckDuckGo, Inc. L<http://duckduckgo.com/>.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

package DDG::Publisher::File;
# ABSTRACT: A file inside the publisher
$DDG::Publisher::File::VERSION = '1043';
use MooX;
use Locale::Simple;
use File::ShareDir ':ALL';

sub fullpath {
	my ( $self ) = @_;
	my $fullpath = join('/',$self->dir->web_path,$self->file);
	$fullpath =~ s!/+!/!g;
	return $fullpath;
}


has dir => (
	is => 'ro',
	required => 1,
);


has static => (
	is => 'ro',
	lazy => 1,
	default => sub { 0 },
);


has file => (
	is => 'ro',
	required => 1,
	lazy => 1,
	builder => 1,
);

sub _build_file {
	my ( $self ) = @_;
	return $self->static
		? $self->filebase.'.html'
		: $self->filebase.'/'.$self->locale.'.html'
}


has filebase => (
	is => 'ro',
	required => 1,
);


has locale => (
	is => 'ro',
	required => 1,
);


has code => (
	is => 'ro',
	required => 1,
);

sub url {
	my ( $self ) = @_;
	return $self->dir->path.$self->file if $self->static;
	return $self->dir->path if $self->filebase eq 'index';
	return $self->dir->path.$self->filebase;
}


has template => (
	is => 'ro',
	lazy => 1,
	builder => 1,
);

sub _build_template {
	my ( $self ) = @_;
	my $template = $self->dir->template_path.'/'.$self->filebase;
	$template =~ s!/+!/!g;
	$template .= '.tx';
	return $template;
}


has content => (
	is => 'ro',
	lazy => 1,
	builder => 1,
);
sub uncached_content { shift->_build_content }

sub _build_content {
	my ( $self ) = @_;

	#
	# setting locale for the localilzation (see L<Locale::Simple>)
	#
	l_dir(dist_dir($self->dir->site->locale_dist));
	ltd($self->dir->site->locale_domain);
	l_lang($self->locale);

	#
	# Activating the dryrun if requested.
	#
	l_dry($self->dir->site->publisher->dryrun) if $self->dir->site->publisher->has_dryrun;

	#
	# Variables for the template
	#
	# f = reference to the file itself
	# d = reference to the directory of the file
	# s = reference to the site of directory of the file
	#
	# locale_package_version = Version number of the locale package
	# locales = the hash of the locales for this token domain
	# maintemplate = name of the template (so that base.tx can use it)
	# url = the final URL for this specific page
	#

	my %vars = (
		f => $self,
		d => $self->dir,
		s => $self->dir->site,
		locale_package_version => $self->dir->site->locale_package->version,
		locales => $self->dir->site->locale_package->locales,
		maintemplate => $self->template,
		url => $self->url,
	);

	my $site_code = $self->dir->site->can('code');

	my $dir_code = $self->dir->can('code');

	#
	# Attach ENV variables, doing at here, so that they can be overriden
	#
	%vars = ( %vars, 'ENV', \%ENV );
	#
	# Execute code from L<DDG::Publisher::SiteRole/code> to get more variables
	#
	%vars = ( %vars, $site_code->($self,\%vars) ) if $site_code;
	#
	# Execute code from L<DDG::Publisher::DirRole/code> to get more variables
	#
	%vars = ( %vars, $dir_code->($self,\%vars) ) if $dir_code;
	#
	# Execute code from L<code> to get more variables
	#
	%vars = ( %vars, $self->code->($self,\%vars) );

	# explicit getting out no_base for template decision later
	my $no_base = defined $vars{no_base} && $vars{no_base};

#	use Data::Dumper;
#	warn Dumper($vars{'ENV'});

	#
	# Gathering the save data for the data files generation
	#
	$self->dir->site->save_data->{locales} = $self->dir->site->locale_package->locales
		unless defined $self->dir->site->save_data->{locales};
	$self->dir->site->save_data->{$self->dir->path} = {}
		unless defined $self->dir->site->save_data->{$self->dir->path};
	$self->dir->site->save_data->{$self->dir->path}->{$self->filebase} = { static => $self->static }
		unless defined $self->dir->site->save_data->{$self->dir->path}->{$self->filebase};
	$self->dir->site->save_data->{$self->dir->path}->{$self->filebase}->{$self->file} = {
		locale => $self->locale,
		url => $self->url,
		file => $self->file,
		dir => $self->dir->path,
		template => $self->template,
		no_base => $no_base,
	};

	# execute template, return rendered content.
	return $self->dir->site->template_engine->render($no_base ? $self->template : 'base.tx',\%vars);
}

1;

__END__

=pod

=head1 NAME

DDG::Publisher::File - A file inside the publisher

=head1 VERSION

version 1043

=head1 ATTRIBUTES

=head2 dir

L<DDG::Publisher::DirRole> object of this file

=head2 static

This is a static file, so its not generated for every language, only one file.

=head2 file

Filename inside the directory of the site.

=head2 file

Base path inside the site directory, must be given on construction.

=head2 locale

Locale used for this specific file.

=head2 code

Additional code that needs to be executed for getting the variables for the
template of this file.

=head2 file

Template name used, normally by default this is not used, instead B<base.tx>
template is loaded by default, and this one is using the template variable. If
there is a variable B<no_base> set inside the resulting variables for this
file, then this template name is used instead of B<base.tx>

=head2 content

The resulting (uncompressed) content of the file. Fetching this will
automatically fire up the template engine to generate the content.

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by DuckDuckGo, Inc. L<http://duckduckgo.com/>.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

package DDG::Publisher::SiteRole;
# ABSTRACT: The role for a site in the publisher
$DDG::Publisher::SiteRole::VERSION = '1043';
use MooX::Role;
use Class::Load ':all';
use Text::Xslate qw( mark_raw );
use File::ShareDir::ProjectDistDir;
use Locale::Simple;
use Config::INI::Reader;
use Path::Class;
use JavaScript::Value::Escape;

requires qw(
	default_hostname
	dirs_classes
	locale_package
	locale_domain
);


has publisher => (
	is => 'ro',
	required => 1,
);


has key => (
	is => 'ro',
	required => 1,
);


has hostname => (
	is => 'ro',
	builder => 'default_hostname',
	lazy => 1,
);


has dirs => (
	is => 'ro',
	builder => 1,
	lazy => 1,
);

sub _build_dirs {
	my ( $self ) = @_;
	return {map {
		my $class = (ref $self || $self).'::'.$_;
		load_class($class);
		s/([a-z])([A-Z])/$1_$2/g;
		$_ = lc($_);
		$_ => $class->new(
			key => $_,
			site => $self,
		);
	} $self->dirs_classes};
}


has default_locale => (
	is => 'ro',
	builder => 1,
	lazy => 1,
);

sub _build_default_locale { 'en_US' } # DON'T CHANGE


has fullpath_files => (
	is => 'ro',
	lazy => 1,
	builder => 1,
);

sub _build_fullpath_files {
	my ( $self ) = @_;
	my %fullpath_files;
	for my $dir (values %{$self->dirs}) {
		for my $key (keys %{$dir->fullpath_files}) {
			$fullpath_files{$key} = $dir->fullpath_files->{$key};
		}
	}
	return \%fullpath_files;
}


has save_data => (
	is => 'rw',
	lazy => 1,
	default => sub {{}},
);

sub load_locale_package {
	my ( $self ) = @_;
	load_class($self->locale_package) unless (is_class_loaded($self->locale_package));
}

sub locales {
	my ( $self ) = @_;
	$self->load_locale_package;
	return (keys %{$self->locale_package->locales});
}


has template_engine => (
	is => 'ro',
	lazy => 1,
	builder => 1,
);

sub _build_template_engine {
	my ( $self ) = @_;
	my $site_template_root = dir(dist_dir('DDG-Publisher'),'site',$self->key)->stringify;
	my $core_template_root = dir(dist_dir('DDG-Publisher'),'core')->stringify;
	#
	# This hash contains the translation functions, wrapped with the
	# functionality required to make it work proper with utf8 in the context
	# of Text::Xslate.
	#
	my %xslate_locale_functions;
	for my $key (keys %{ Locale::Simple->coderef_hash }) {
		$xslate_locale_functions{$key} = sub {
			my $translation = Locale::Simple->coderef_hash->{$key}->(@_);
			return mark_raw($translation);
		};
	}
	return Text::Xslate->new(
		#
		# Include share/site/$key and share/core as template directories
		#
		path => [@{$self->publisher->extra_template_dirs},$site_template_root,$core_template_root],
		function => {
			#
			# js() function to escape js
			#
			js => sub { return mark_raw(javascript_value_escape(join("",@_))) },
			#
			# r() function to mark some output as "clean", which means that
			# it doesnt get HTML encoded by the Xslate generation system.
			#
			r => sub { return mark_raw(join("",@_)) },
			%xslate_locale_functions,
			find_template => sub {
				my ($filename) = @_;
				return $filename if eval { $self->template_engine->find_file($filename); 1 };
				$filename .= $self->template_engine->{suffix};
				return $filename if eval { $self->template_engine->find_file($filename); 1 };
				return 0;
			},
			substr => sub {
				my($str, $offset, $length) = @_;
				return undef unless defined $str;
				$offset = 0 unless defined $offset;
				$length = length($str) unless defined $length;
				return CORE::substr($str, $offset, $length);
			},
			lowercase => sub {
				return defined($_[0]) ? CORE::lc($_[0]) : undef;
			},
		},
	);
}

1;

__END__

=pod

=head1 NAME

DDG::Publisher::SiteRole - The role for a site in the publisher

=head1 VERSION

version 1043

=head1 ATTRIBUTES

=head2 publisher

L<DDG::Publisher> object, must be given on construction.

=head2 key

This is the key used for the directory and general identification of the site
inside the publisher system.

=head2 hostname

This is the hostname, which should get used for the final files, so far this
option isn't used and has no effect. B<TODO>

=head2 dirs

This attribute contains the objects of the L<DDG::Publisher::DirRole> objects
of this site.

=head2 default_locale

Default locale to use on this site. Defaults to en_US and should never be
changed on a site of DuckDuckGo, as many other parts of the system are also
thinking that en_US is the default.

=head2 fullpath

Migrated fullpath file references for all dirs of the site

=head2 save_data

This data is used in the end of the publishing process to generate the data
file. It will be filled up on the process of executing all files of the site.

=head2 template_engine

This function holds the L<Text::Xslate> engine for the specific site.

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by DuckDuckGo, Inc. L<http://duckduckgo.com/>.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

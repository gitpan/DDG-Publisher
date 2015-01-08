package DDG::Publisher;
# ABSTRACT: Generation of the static files of DuckDuckGo and its microsites.
$DDG::Publisher::VERSION = '1043';
use MooX;
use Path::Class;
use Class::Load ':all';
use IO::All -utf8;
use HTML::Packer;
use String::ProgressBar;
use JSON;
use File::Path qw(make_path);


has site_classes => (
	is => 'ro',
	lazy => 1,
	builder => 1,
);

sub _build_site_classes {[qw(
	Duckduckgo
	Donttrackus
	Dontbubbleus
	Whatisdnt
	Fixtracking
	Duckduckhack
)]}


has extra_template_dirs => (
	is => 'ro',
	lazy => 1,
	builder => 1,
);

sub _build_extra_template_dirs {[qw(
	templates
)]}


has cache_dir => (
    is => 'ro',
    lazy => 1,
    builder => 1,
);


sub _build_cache_dir {
    my $dir = $ENV{DDG_PUBLISHER_CACHE_DIR} ? $ENV{DDG_PUBLISHER_CACHE_DIR} : $ENV{HOME}."/publisher";
    make_path($dir) unless -d $dir;
    return $dir;
}



has sites => (
	is => 'ro',
	lazy => 1,
	builder => 1,
);

sub _build_sites { 
	my ( $self ) = @_;
	return {map {
		my $class = 'DDG::Publisher::Site::'.$_;
		load_class($class);
		s/([a-z])([A-Z])/$1_$2/g;
		$_ = lc($_);
		lc($_) => $class->new( key => lc($_), publisher => $self );
	} @{$self->site_classes}};
}


has compression => (
	is => 'ro',
	default => sub { 0 },
);


has dryrun => (
	is => 'ro',
	predicate => 1,
);

sub BUILD {
	my ( $self ) = @_;
	$self->sites;
}


sub publish_to {
	my ( $self, $target ) = @_;
	my $target_dir = dir($target)->absolute;
	$target_dir->mkpath unless -d "$target_dir";
	my $count = 0;
	my $packer;
	$packer = HTML::Packer->init() if ($self->compression);

	#
	# For every site...
	#

	for my $site (values %{$self->sites}) {

		#
		# For every dir in the site...
		#

		for my $dir (values %{$site->dirs}) {
			print "\n".(ref $site).$dir->web_path."\n\n";
			my @files = values %{$dir->fullpath_files};
			my $progress = String::ProgressBar->new(
				max => scalar @files,
				length => 50,
			);
			my $i = 0;
			for (sort { $a->fullpath cmp $b->fullpath } @files) {
				$i++;
				$progress->update($i);
				$progress->write;
				my $real_file = file($target_dir,$site->key,$_->fullpath)->absolute;
				$real_file->dir->mkpath unless -f $real_file->dir->absolute->stringify;
				my $content = $_->content;
				utf8::encode($content);

				#
				# If compression is requested, then the content of the files
				# get compressed via HTML::Packer here.
				#

				if ($packer) {
					$packer->minify(\$content,{
						remove_comments => 0,
						remove_newlines => 1,
						do_javascript => 1,
						do_stylesheet => 1,
						no_compress_comments => 1,
					})
				}
				utf8::decode($content);
				io($real_file->stringify)->print($content);
				$count++;
			}
			print "\n";
		}

		#
		# Generate a datafile for the site, which can be used for deeper
		# processing of the static files. (It's used by the internal code
		# of DDG to generate, for example, the nginx config)
		#

		my $data_file = file($target_dir,$site->key.'.json')->absolute;
		io($data_file)->print(encode_json($site->save_data));
	};
	return $count;
}

1;

__END__

=pod

=head1 NAME

DDG::Publisher - Generation of the static files of DuckDuckGo and its microsites.

=head1 VERSION

version 1043

=head1 ATTRIBUTES

=head2 site_classes

List of classes that should get executed on publishing.

=head2 extra_template_dirs

List of extra directions that should be used for templates.

=head2 sites

This attribute holds the objects of the site classes that should get build.

=head2 compression

See L<DDG::App::Publisher/compression>.

=head2 dryrun

See L<DDG::App::Publisher/dryrun>.

=head1 METHODS

=head2 publish_to

This method it called to publish the files to the given specific directory.

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by DuckDuckGo, Inc. L<http://duckduckgo.com/>.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

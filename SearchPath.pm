package File::SearchPath;

=head1 NAME

File::SearchPath - Search for a file in an environment variable path

=head1 SYNOPSIS

  use File::SearchPath qw/ searchpath /;

  $file = searchpath( 'libperl.a', env => 'LD_LIBRARY_PATH' );

  $exe = searchpath( 'ls' );

=head1 DESCRIPTION

This module provides the ability to search a path-like environment
variable for a file (that does not necessarily have to be an 
executable).

=cut

use 5.006;
use Carp;
use warnings;
use strict;

use base qw/ Exporter /;
use vars qw/ $VERSION @EXPORT_OK /;

use File::Spec;

$VERSION = sprintf("%d.%03d", q$Revision$ =~ /(\d+)\.(\d+)/);

@EXPORT_OK = qw( searchpath );

=head1 FUNCTIONS

The following functions can be exported by this module.

=over 4

=item B<searchpath>

This is the core function. The only mandatory argument is the name of
a file to be located. The filename should not be absolute although it
can include directory specifications.

  $path = searchpath( $file );
  @matches = searchpath( $file );

By default, this will search in $PATH for executable files and is
equivalent to:

  $path = searchpath( $file, env => 'PATH', exe => 1 );

Hash-like options can be used to alter the behaviour of the
search:

=over 8

=item env

Name of the environment variable to use as a starting point for the
search. Should be a path-like environment variable such as $PATH,
$LD_LIBRARY_PATH etc. Defaults to $PATH. An error occurs if the
environment variable is not set or not defined. If it is defined but
contains a blank string, the current directory will be assumed.

=item exe

If true, only executable files will be located in the search path.
If $PATH is being searched, the default is for this to be true. For all
other environment variables the default is false.

=item subdir

If you know that your file is in a subdirectory of the path described
by the environment variable, this direcotry can be specified here.
Alterntaively, the path can be included in the file name itself.

=back

In scalar context the first match is returned. In list context all
matches are returned in the order corresponding to the directories
listed in the environment variable.

=cut

sub searchpath {
  my $file = shift;

  croak "Supplied filename to searchpath uses an absolute path!"
    if File::Spec->file_name_is_absolute( $file );

  # options handling
  # The exe() defaulting is env dependent
  my %defaults = ( env => 'PATH', subdir => File::Spec->curdir );
  my %options = ( %defaults, @_ );

  if (!exists $options{exe}) {
    # exe was not specified
    $options{exe} = ( $options{env} eq 'PATH' ? 1 : 0 );
  }

  # if exe is true we can simply use Env::Path directly. It doesn't
  # really simplify any code though since we still have to write 
  # the other search

  # first get the search directories from the path variable
  my @searchdirs = _env_to_dirs( $options{env} );

  # Now do the looping
  my @matches;

  for my $d (@searchdirs) {
    # blank means current directory
    $d = File::Spec->curdir unless $d;

    # Create the filename
    my $testfile = File::Spec->catfile( $d, $options{subdir}, $file);

    # does the file exist?
    next unless -e $testfile;

    # is it meant to be executable?
    if ($options{exe}) {
      next unless -x $testfile;
    }

    # File looks to be found store it
    push(@matches, $testfile);

    # if we are in a scalar context we do not need to keep on looking
    last unless wantarray();

  }

  # return the result
  if (wantarray) {
    return @matches;
  } else {
    return $matches[0];
  }
}

=back

=begin __PRIVATE__FUNCTIONS__

=head2 Private Functions

=over 4

=item B<_env_to_dirs>

Given an environment variable, splits it into chunks and returns
the list of directories to be searched.

If Env::Path is installed, it is used since it understands a more
varied set of path delimiters, otherwise the variable is split on
colons.

  @dirs = _env_to_dirs( 'PATH' );

=cut

sub _env_to_dirs {
  my $var = shift;

  croak "Environment variable $var is not defined. Unable to search it\n"
    if !exists $ENV{$var};

  croak "Environment variable does exist but it is not defined. Unable to search it\n"
    unless defined $ENV{$var};

  eval { require Env::Path };
  if ($@) {
    # no Env::Path so we just split on :
    my $path = $ENV{$var};
    return split(/:/, $path);

  } else {
    my $path = Env::Path->$var;
    return $path->List;
  }
}


=back


=end __PRIVATE__FUNCTIONS__

=head1 WHY?

There are many modules that search for an executable in the path
but I couldn't find any that would also search for a non-executable
file in a path-like environment variable. Yes, C<File::Find> would work
but I'm doing this a lot so I wanted to replace the unneeded complexity
of C<File::Find> with something more targetted.

=head1 SEE ALSO

L<Env::Path>, L<File::Which>, L<File::Find>, L<File::Find::Run>,
L<File::Where>.

=head1 AUTHOR

Tim Jenness E<lt>t.jenness@jach.hawaii.eduE<gt>

Copyright 2005 Particle Physics and Astronomy Research Council.
All Rights Reserved.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful,but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 59 Temple
Place,Suite 330, Boston, MA  02111-1307, USA

=cut

1;

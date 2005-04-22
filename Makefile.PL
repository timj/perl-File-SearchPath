
# Run this with perl to create the Makefile

# Author: Tim Jenness E<lt>t.jenness@jach.hawaii.eduE<gt>

# Copyright 2005 Particle Physics and Astronomy Research Council.
# All Rights Reserved.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place,Suite 330, Boston, MA 02111-1307,
# USA

use ExtUtils::MakeMaker;

# Write the makefile
WriteMakefile(
    'NAME'      => 'File::SearchPath',
    'VERSION_FROM' => 'SearchPath.pm', # finds $VERSION

    'PREREQ_PM' => {
         File::Spec => 0.8,
	 Test::More => 0,
       },
    'dist'      => { COMPRESS => "gzip -9f" },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
        (ABSTRACT_FROM => 'SearchPath.pm',
         AUTHOR     => 'Tim Jenness <tjenness@cpan.org>') : ()),
);

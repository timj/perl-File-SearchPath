# -*-perl-*-

use Test::More tests => 8;
use File::Spec;

require_ok( "File::SearchPath" );

# Look for the test file

my $test = 'search.t';

setpath( "MYPATH", qw/ blib t / );

my $fullpath = File::SearchPath::searchpath( $test, env => 'MYPATH' );

is( $fullpath, File::Spec->catfile( "t", $test), "Find $test");


$fullpath = File::SearchPath::searchpath( $test, env => 'MYPATH', exe => 1 );
ok( !$fullpath, "$test not executable");

# Now look for perl itself
my ($vol,$dir,$f) = File::Spec->splitpath( $^X );

setpath( "MYPATH", $dir, "t" );

$fullpath = File::SearchPath::searchpath( $f, exe => 1, env => "MYPATH" );

is( $fullpath, $^X, "Found perl");

# Now look in the test directories
setpath( "MYPATH" ,map { File::Spec->catdir( "t", $_) } qw/ a b c /);

$fullpath = File::SearchPath::searchpath( "file2", env => 'MYPATH' );
is($fullpath, File::Spec->catfile("t","a","file2"),"found file2");

@full = File::SearchPath::searchpath( "file2", env => 'MYPATH' );
is(@full,2, "Number of files found");

is($full[0], File::Spec->catfile("t","a","file2"),"found file2");
is($full[1], File::Spec->catfile("t","b","file2"),"found file2");


exit;

# Given an environment variable name and an array of variables
# set the path.
# Will use Env::Path if available
sub setpath {
  my ($env, @dirs) = @_;
  eval { require Env::Path };
  if ($@) {
    # use colons
    $ENV{$env} = join(":", @dirs);
  } else {
    my $path = Env::Path->$env;
    $path->Assign( @dirs );
  }
}

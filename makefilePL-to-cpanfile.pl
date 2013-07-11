#!/usr/bin/env perl
use common::sense;
use Scalar::Util qw(looks_like_number);

my $MAKEFILE = $ARGV[0]          or die "Usage: $0 /full/path/to/Makefile.PL";
open( my $fh, '<', "$MAKEFILE" ) or die "Cant open $MAKEFILE";

my %requirements;
my $q  = qr{['"]};
my $nq = qr{[^'"]};
while ( <$fh> ) {
    chomp;
    m{^                         # Start of line
    ( (?:test_)?requires )      # Capture (test_)?requires
    \s+                         # Some spaces
    $q($nq+)$q                  # Capture Module name
    (?:\s+[,=>]+\s+$q($nq+)$q)? # Capture an optional module version
    ;$                          # Semicolon and EOL
    }x
    or next;

    my ( $type, $module, $version ) = ( $1, $2, $3 );

    defined( $version ) or do {
#        say "Look up installed version for $module...";
        eval "require $module;";
        $@ and die $@;
        $version = ${ "${module}::VERSION" };
        ref($version) and $version = $version->{original};
        looks_like_number($version) or $version = "0.00";
    };

    $requirements{ $type }->{ $module } = $version;
}
close $fh;

foreach my $type ( keys %requirements ) {
    my $subtype;
    my $indent = 0;

    # eg, Wrap all "test_requires..." in an "on 'test' => sub" block
    $type =~ /^(.*)_requires/ and do {
        $subtype = $1;
        $indent  = 4;
        say "\non '$subtype' => sub {";
    };

    # Dump the `requires` lines
    foreach my $module ( sort { lc($a) cmp lc($b) } keys %{ $requirements{$type} } ) {
        my $module_field_len = 60 - $indent;
        printf "%srequires %-${module_field_len}s => '>= %s';\n"
            , (' ' x $indent)
            , "'$module'"
            , $requirements{$type}->{$module}
            ;
    }

    # Finish the sub, if necessary
    $subtype and do {
        say "};\n";
        $indent = 0;
    };
}

#!/usr/bin/env raku

use v6;

my @directories = <
    t xt lib resources docs bin sbin
>;

my @files = <
    Changes dist.ini META6.json
>;

sub MAIN(Str $module-dir) {
    my $module = $module-dir.IO.absolute;

    die "Not a directory: $module" unless $module.d;
    die "Missing META6.json in $module"
        unless $module.add('META6.json').f;

    my $name    = $module.basename;
    my $parent  = $module.parent;
    my $archive = $parent.add("$name.zip");

    my @entries;

    for @directories -> $directory {
        my $path = $module.add($directory);
        @entries.push($directory) if $path.d;
    }

    for @files -> $file {
        my $path = $module.add($file);
        @entries.push($file) if $path.f;
    }

    die "No files to archive" unless @entries.elems;

    my @args = (
        'zip', '-r', '-q', '-X',
        $archive.Str,
        |@entries,
        '-x', '*/.git/*', '*/.git', '.git/*'
    );

    say "Module:    $name";
    say "Archive:   $archive";
    say "Including: {@entries.join(', ')}";

    my $original-dir = $*CWD;
    LEAVE chdir($original-dir);

    chdir($module) or die "Cannot enter $module";

    if $archive.e {
        $archive.unlink or die "Cannot remove $archive";
    }

    my $proc = run |@args;

    die "zip failed (exit {$proc.exitcode})"
        unless $proc.exitcode == 0;

    say "Created archive: $archive";
}

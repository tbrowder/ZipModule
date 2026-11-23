use v6;
use Test;

my $script = $*PROGRAM.parent.parent.add('zip-module.raku').absolute;
my $temp = $*TMPDIR.add("zipmodule-archive-{$*PID}-{(1000000.rand).Int}");
$temp.mkdir;
LEAVE { run 'rm', '-rf', $temp.Str if $temp.d; }

my $module = $temp.add('Example');
$module.mkdir;

for <t xt lib resources docs bin sbin> -> $dir {
    my $path = $module.add($dir);
    $path.mkdir;
    $path.add('sample.txt').spurt("contents of $dir\n");
    my $git = $path.add('.git');
    $git.mkdir;
    $git.add('secret.txt').spurt('do not archive');
}

for <Changes dist.ini META6.json> -> $file {
    $module.add($file).spurt("sample $file\n");
}
$module.add('private.txt').spurt('not included');
$module.add('.git').mkdir;
$module.add('.git').add('config').spurt('not included');

sub invoke(Str $working-dir, *@args --> Proc) {
    my $previous = $*CWD;
    LEAVE chdir($previous);
    chdir($working-dir) or die "Cannot chdir to $working-dir";
    run $*EXECUTABLE.Str, $script.Str, |@args, :out, :err;
}

sub archive-entries(IO::Path $archive --> Array) {
    my $proc = run 'unzip', '-Z', '-1', $archive.Str, :out, :err;
    is $proc.exitcode, 0, 'archive can be listed by unzip';
    $proc.out.slurp-rest.lines.Array;
}

my $first = invoke($temp.Str, 'Example');
is $first.exitcode, 0, 'works from parent directory';
my $archive = $temp.add('Example.zip');
ok $archive.f, 'archive exists';

my @entries = archive-entries($archive);
for <t xt lib resources docs bin sbin> -> $dir {
    ok "{$dir}/sample.txt" (elem) @entries, "$dir contents included";
}
for <Changes dist.ini META6.json> -> $file {
    ok $file (elem) @entries, "$file included";
}
nok 'private.txt' (elem) @entries, 'unlisted root file excluded';
ok @entries.grep(*.contains('.git')).elems == 0, 'nested .git directories excluded';

$module.add('bin').add('sample.txt').unlink;
my $second = invoke($module.Str, '.');
is $second.exitcode, 0, 'works from inside module with explicit dot';
@entries = archive-entries($archive);
nok 'bin/sample.txt' (elem) @entries, 'old archive replaced, no stale file';

# An omitted optional directory must not prevent successful packaging.
run 'rm', '-rf', $module.add('sbin').Str;
my $third = invoke($temp.Str, 'Example');
is $third.exitcode, 0, 'missing optional directory is allowed';

done-testing;

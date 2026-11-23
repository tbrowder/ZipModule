use v6;
use Test;

my $script = $*PROGRAM.parent.parent.add('zip-module.raku').absolute;
my $temp = $*TMPDIR.add("zipmodule-cli-{$*PID}-{(1000000.rand).Int}");
$temp.mkdir;
LEAVE { run 'rm', '-rf', $temp.Str if $temp.d; }

sub invoke(*@args --> Proc) {
    run $*EXECUTABLE.Str, $script.Str, |@args, :out, :err;
}

ok $script.f, 'CLI script exists';

my $missing-argument = invoke();
nok $missing-argument.exitcode == 0, 'module directory argument is required';

my $nonexistent = invoke($temp.add('missing').Str);
nok $nonexistent.exitcode == 0, 'nonexistent module directory fails';

my $module = $temp.add('Example');
$module.mkdir;
my $missing-meta = invoke($module.Str);
nok $missing-meta.exitcode == 0, 'missing META6.json fails';

$module.add('META6.json').spurt('{"name":"Example","version":"0.0.1"}');
my $successful = invoke($module.Str);
is $successful.exitcode, 0, 'valid minimal module succeeds';
ok $temp.add('Example.zip').f, 'ZIP created alongside module';

done-testing;

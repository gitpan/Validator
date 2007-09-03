# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Validator.t'

#########################

use Test::More qw(no_plan);
use FindBin qw($Bin);
use lib $Bin.'/../lib';
use Validator;

BEGIN { use_ok('Validator') };

#########################

my $inputValidatorOK = [
	{
		name		=>	'Integer',
		required	=>	1,
		value		=>	2,
		rules	=>	[
			{ rule => 'integer' },
			{ rule => 'maxlength', param => 2 },
		]
	},
	{
		name		=>	'Integer',
		required	=>	1,
		error		=>	'Integer not in min max',
		value		=>	2,
		rules	=>	[
			{ rule => 'integer' },
			{ rule => 'minlength', param => 1 },
			{ rule => 'maxlength', param => 2 },
		]
	},
	{
		name		=>	'Pattern',
		required	=>	1,
		value		=>	'Test string',
		rules	=>	[
			{ rule => 'pattern', param => qr/^(Test string)$/ },
		]
	},
	{
		name		=>	'IP',
		required	=>	1,
		value		=>	'127.0.0.11',
		rules	=>	[
			{ rule => 'ip' },
		]
	},
];

my $inputValidatorBAD = [
	{
		name		=>	'Integer',
		error		=>	'Bad format for Integer',
		value		=>	43,
		rules	=>	[
			{ rule => 'integer' },
			{ rule => 'maxlength', param => 1 },
		]
	},
	{
		name		=>	'Integer',
		required	=>	1,
		error		=>	'Integer not in min max',
		value		=>	234,
		rules	=>	[
			{ rule => 'integer' },
			{ rule => 'minlength', param => 1 },
			{ rule => 'maxlength', param => 2 },
		]
	},
	{
		name		=>	'Pattern',
		required	=>	1,
		error		=>	'Bad format for Pattern',
		value		=>	'Test stringa',
		rules	=>	[
			{ rule => 'pattern', param => qr/^(Test string)$/ },
		]
	},
	{
		name		=>	'IP',
		required	=>	1,
		error		=>	'Bad format for IP',
		value		=>	'1127.0.0.1',
		rules	=>	[
			{ rule => 'ip' },
		]
	},
	{
		name		=>	'IP',
		required	=>	1,
		error		=>	'Bad format for IP',
		value		=>	'127.0.10.1000',
		rules	=>	[
			{ rule => 'ip' },
		]
	},
	{
		name		=>	'IP',
		required	=>	1,
		error		=>	'Bad format for IP',
		value		=>	'127.10.1.1111',
		rules	=>	[
			{ rule => 'ip' },
		]
	},
];

my $validator = Validator->new();
ok(ref $validator eq 'Validator',"Validator->new()");

$validator->fields($inputValidatorOK);
my $res = $validator->isValid();
ok( $res == 1, "OK test $validator->isValid().Result: $res");

$validator->fields($inputValidatorBAD);
$res = $validator->isValid();
ok( ref $res eq 'Validator::ErrorCode', "BAD test $validator->isValid().Result: $res");

1;
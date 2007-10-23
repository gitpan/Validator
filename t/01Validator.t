# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Validator.t'

#########################

use Test::More qw(no_plan);
use FindBin qw($Bin);
use lib $Bin. '/../lib';
use Validator;
use Data::Dumper;

BEGIN { use_ok('Validator') }

#########################

my $validator = Validator->new();
ok( ref $validator eq 'Validator', "Validator->new()" );

$validator->fields( getOK() );
my $res = $validator->isValid();
ok( $res == 1, "OK test $validator->isValid().Result: $res" );

$validator->fields(getBAD());
$res = $validator->isValid();
ok( ref $res eq 'Validator::ErrorCode',
	"BAD test $validator->isValid().Result:$res " );

$validator->clear();
$validator->fields($validator->xmlCached( %{getXMLCachedOpts()} ));
$res = $validator->isValid();
ok( $res == 1, "From xml+xsd - OK test $validator->isValid().Result: $res" );

$validator->clear();
$validator->fields($validator->xmlCached( %{getXMLCachedOpts(1)} ));
$res = $validator->isValid();
ok( ref $res eq 'Validator::ErrorCode',
	"From xsd+xml - BAD test $validator->isValid().Result:$res " );

#print Dumper $validator->xmlCached( %{getXMLCachedOpts()} );

print Dumper $validator->funcIsValidAsJS();

sub getXMLCachedOpts {
	my $bad = shift;
	
	my $xsd = $Bin.'/xmlData/form_validator.xsd';
	my $hashref = { xsdFile => $xsd };
	
	if ( $bad ) {
		$hashref->{xmlFile} = $Bin.'/xmlData/simpleBAD.xml';	
	}
	else {
		$hashref->{xmlFile} = $Bin.'/xmlData/simpleOK.xml';
	}
	return $hashref;
}

sub getOK {
	my $inputValidatorOK = [
		{
			name     => 'Integer',
			required => 1,
			value    => 2,
			rules    =>
			  [ { rule => 'integer' }, { rule => 'maxlength', param => 2 }, ]
		},
		{
			name     => 'Integer',
			required => 1,
			error    => 'Integer not in min max',
			value    => 2,
			rules    => [
				{ rule => 'integer' },
				{ rule => 'minlength', param => 1 },
				{ rule => 'maxlength', param => 2 },
			]
		},
		{
			name     => 'Pattern',
			required => 1,
			value    => 'Test string',
			rules    => [ { rule => 'pattern', param => '^(Test string)$' }, ]
		},
		{
			name     => 'IP',
			required => 1,
			value    => '127.0.0.11',
			rules    => [ { rule => 'ip' }, ]
		},
		{
			name  => 'Element',
			value => [qw/1 2 qwe/],
			rules => [ { rule => 'array' }, ]
		},
		{
			name  => 'Hash',
			value => ( a => 'b' ),
			rules => [ { rule => 'hash' }, ]
		}
	];
	return $inputValidatorOK;
}

sub getBAD {
	my $inputValidatorBAD = [
		{
			name  => 'Integer',
			error => 'Bad format for Integer',
			value => 43,
			rules =>
			  [ { rule => 'integer' }, { rule => 'maxlength', param => 1 }, ]
		},
		{
			name     => 'Integer',
			required => 1,
			error    => 'Integer not in min max',
			value    => 234,
			rules    => [
				{ rule => 'integer' },
				{ rule => 'minlength', param => 1 },
				{ rule => 'maxlength', param => 2 },
			]
		},
		{
			name     => 'Pattern',
			required => 1,
			error    => 'Bad format for Pattern',
			value    => 'Test stringa',
			rules    => [ { rule => 'pattern', param => '^(Test string)$' }, ]
		},
		{
			name     => 'IP',
			required => 1,
			error    => 'Bad format for IP',
			value    => '1127.0.0.1',
			rules    => [ { rule => 'ip' }, ]
		},
		{
			name     => 'IP',
			required => 1,
			error    => 'Bad format for IP',
			value    => '127.0.10.1000',
			rules    => [ { rule => 'ip' }, ]
		},
		{
			name     => 'IP',
			required => 1,
			error    => 'Bad format for IP',
			value    => '127.10.1.1111',
			rules    => [ { rule => 'ip' }, ]
		},
		{
			name  => 'ElementAsArray',
			value => 'a s ddd',
			rules => [ { rule => 'array' }, ]
		},
		{
			name  => 'Hash',
			value => 'a s ddd',
			rules => [ { rule => 'hash' }, ]
		}
	];
	return $inputValidatorBAD;    
}

1;

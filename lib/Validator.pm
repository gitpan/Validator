package Validator;

use 5.008007;
use strict;
use warnings;

our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';


# Example of array for validator settings
#	fields = 
#	[
#		{
#			name: 'child_frm_1_txt1',
#			required: 1,
#			error: ErrorMessage,
#			value: value				
#			rules: [
#				{ rule: 'integer' },
#				{ rule: 'maxlength', param: 3 }
#			]
#		},
#		{
#			name: 'child_frm_1_txt2',
#			required: 0,
#			rules: [
#				{ rule: 'email' },
#			]
#		},
#		{
#			name: 'child_frm_2_txt1',
#			required: 1,
#			rules: [
#				{ rule: 'datetime', param:  'YYYY-MM-DD hh:mm'  }
#			]
#		},
#		{		
#			name: 'child_frm_2_txt2',
#			required: 1,
#			rules: [
#				{ rule: 'minlength', param: 2 },
#				{ rule: 'maxlength', param: 5 }			
#			]		
#		}	
#	]
#*/

use Validator::ErrorCode;
use Validator::Rules::Base;

use base 'Class::Accessor';
__PACKAGE__->mk_accessors(qw/fields errorCount errorCode jsValidator/);

sub isValid {
	my $this = shift;
	
	my $rulesObj = Validator::Rules::Base->new();
		
	foreach my $f ( @{$this->fields} ) {
		my $fieldName	= $f->{name};
		my $required	= $f->{required};
		my $fieldValue 	= $f->{value};
		my $rules 		= $f->{rules};
		my $count 		= 0;
		# checking on required
		if ( $required && $required == 1 && length($fieldValue)<1 ) {
			$f->{error} = "Param $fieldName required" unless $f->{error}; 
			$this->appendErrField($f);
			next;
		} # END if ( $required eq '1' && !length($fieldValue) )	
		foreach my $r ( @$rules ) {
			my $func = $r->{rule};
			my $res = $rulesObj->$func ( $fieldValue, $r->{param} );
			if ( !$res ) {
				$f->{error} = "Wrong format for $fieldName" unless $f->{error};
				$this->appendErrField($f);
			} 
		} # END foreach my $r ( keys %$rules )
	} # END foreach my $f ( @{$this->fields} )
	my $errors = ++$#{$this->{errFields}};	
	if( $errors > 0 ) {
		my $err = Validator::ErrorCode->new();
		
		$err->errorCount($errors);
		$err->errorFields($this->{errFields});
		$err->errorMsg();
		
		return $err;
	} # END if( $this->errCount() > 0 ) 
		
	return 1;
}

sub appendField {
	my $this = shift;
	my $field = shift;
	
	push @{$this->{fields}},$field;
}

sub appendErrField {
	my $this = shift;
	my $field = shift;
	
	push @{$this->{errFields}},$field;
}

1;

1;
__END__

=head1 NAME

Validator - Input params validator

=head1 SYNOPSIS

  	use Validator;
  
  	my $fields = [
		{
			name		=>	'Integer',
			error		=>	'Bad format for Integer',
			value		=>	43,
			rules	=>	[
				{ rule => 'integer' },
				{ rule => 'maxlength', param => 1 },
			]
		},
		{ ... }
	];
	
	my $validator = Validator->new();
	$validator->fields($fields);
	my $valid = $validator->isValid();
	
	if ( ref $valid eq 'Validator::ErrorCode' ) {
		# error handling
		$valid->errorCode();
		# or 
		$valid->errorMsg();
	}		

=head1 DESCRIPTION

Class for input method validation by rules from Validator::Rules::Base 

=head2 EXPORT

TODO

=head1 SEE ALSO

TODO

=head1 AUTHOR

Alex Nosoff E<lt>plcgi1@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2000 by Alex Nosoff

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
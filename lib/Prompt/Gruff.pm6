use v6;

class Prompt::Gruff
{
    has Bool $.required   is rw = True;
    has Bool $.multi-line is rw = False;
    has UInt $.verify     is rw = 1;
    has Str  $.default    is rw = '';
    has Str  $.regex      is rw;
    has Bool $.yn         is rw;
    has Bool $.no-escape  is rw = True;

    has $!_previous_response;
    has $!_prompt;
    
    method prompt-for($prompt,
		      Bool :$!required   = True,
		      Bool :$!multi-line = False,
		      Str  :$!default    = '',
		      Str  :$!regex,
                      Bool :$!yn,
		      Bool :$!no-escape  = True,
		      UInt :$!verify     = 1) {
	my $response;
	my $RX       = self!_mk_regex;
	my $prompter = self!_mk_prompter;
	self!_mk_prompt($prompt);
	
	if $!required { while !($response = $prompter($!_prompt) || $!default) {} }
	         else {         $response = $prompter($!_prompt) || $!default     }

        if $!regex and !($response ~~ $RX) {
	    note 'Input does not match valid pattern';
	    return self!_call-prompt-for($prompt) if $!no-escape;
	    return False;
	}
	
	if $!_previous_response and $!_previous_response ne $response {
	    note 'Verification failed';
	    $!_previous_response = '';
	    $!verify++;
	    return self!_call-prompt-for($prompt) if $!no-escape;
	    return False;
	}
	$!_previous_response = $response;
	$!verify--;
	
	unless $!verify {
	    $!_previous_response = '';
	    $response            = $!default unless $response;
	    $!default            = '';
	    return ($response ~~ /:i y/ ?? True !! False) if $!yn.defined;
	    return $response.chomp;
	}
	self!_call-prompt-for($prompt);
    }

    method !_mk_regex() {
	return unless $!regex;
	if $!yn.defined { $!regex = ':i y || n' }
	my $regex = $!regex;
	return rx/<$regex>/;
    }	
    
    method !_mk_prompt($prompt) {
	$!_prompt = $prompt;
	self!_ch_prompt(:p('(verify) '))    if $!_previous_response;
	self!_ch_prompt(:a("[$!default] ")) if $!default;	
    }
    
    method !_ch_prompt(:$a, :$p) {
	$!_prompt ~= $a if $a;
	$!_prompt = $p ~ $!_prompt if $p;
    }	
    
    method !_mk_prompter() {
	return $!multi-line ?? -> $text { say $text; slurp $*IN }
	                    !! -> $text { prompt $text };
    }	

    method !_call-prompt-for($prompt) {
	self.prompt-for($prompt,
			:required($!required),
			:multi-line($!multi-line),
			:default($!default),
			:verify($!verify),
			:regex($!regex),
			:yn($!yn),
			:no-escape($!no-escape),
		       );
    }
}

#|{
=begin pod

=head1 NAME Prompt::Gruff

=head1 SYNOPSIS

    =begin code :skip-test
    use Prompt::Gruff::Functional;

    # Input is required by default
    my $name = prompt-for('Enter name (required): ');

    # You can make it not so
    my $mail = prompt-for('Email: ', required => False);

    # Multi-line is terminated with a hideous but effective ctrl_d
    my $desc = prompt-for('Description (end with ^D)', multi-line => True);

    # Make your user verify their input as many times as you like
    my $haha = prompt-for('Complicated thing: ', :verify(4));

    # For purely object-oriented inteface, just omit the
    # "::Functional" bit in your use statement.

    use Prompt::Gruff;

    my $gruff = Prompt::Gruff.new;
    my $name  = $gruff.prompt-for('Name');
    =end code

=head1 DESCRIPTION

Quick and dirty (and simple (for us)) user prompting.

If you don't want to learn anything new, this module's for you.

Supports crude multi-line input and re-type verification.

=head1 ATTRIBUTES

=head2 required (default: True)

The "required" attribute, True by default, will forever hound the user
until they respond with something or destroy the machine.

=head2 multi-line (default: False)

The "multi-line" argument, False by default, opens up STDIN from the
user so that they may continuously type all they want until they enter
a ^D character to terminate their input, or they manage to exhaust the
computer's memory.

Multi-line input places the prompt on a line of its own, then starts
the input below.

=head2 verify (UInt) (default: 1)

Takes a number, and forces the user to type in their input that many
times!

If it's set to more than 1, then each time they re-enter it, their
input will be verified against the last thing they entered -- and if
they didn't enter it in exactly the same, they get asked again.

If you like, set :no-escape(False) and the program will terminate and
they'll have to start all over again if they make a mistake! I know!
:)

I strongly recommend a verify setting of at least 5. For
everything. All the time.

=head2 regex (Str)

You can pass a string (without the enclosing '/'s) representing a
regex and your user will be constrained to your exacting
specifications.

=head2 default (Str)

Setting or passing in a 'default' string will allow your user to just
hit enter without having to look at anything or even think in the
slightest.

They can just pound the enter key, and your pre-made default string
will be used.

=head2 yn (Bool)

If your user can handle choosing between yes or no questions and
typing a 'y' or an 'n' on the keyboard, setting :yn True might be nice.

You can choose a :default value too.

The return value is True or False.

=head2 no-escape (Bool) (default: True)

Trap your user in an endless loop until they satisfactorily bend to
your will. This is the default.

:no-escape(False) will cause errors to fail out instead of re-prompting.

=head1 METHODS

=head2 prompt-for ($prompt_text,
                   [Bool :required (True)],
                   [Bool :multi-line (False)]),
                   [Str  :regex],
                   [Str  :default],
                   [Bool :yn],
                   [Bool :no-escape],
                   [UInt :verify (1)],

Takes the required positional $text string as the user prompt and
returns what the user decided to input.

Arguments passed to prompt-for() will override their corresponding
attributes.

=head1 AUTHOR

Mark Rushing <mark@orbislumen.net>

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
}

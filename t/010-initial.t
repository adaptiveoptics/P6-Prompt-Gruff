use v6;
use Test;
use lib <lib>;
#use lib </home/mark/tmp>;

# class StubIO is IO::Handle {
#     has @.input handles (:push<push>, :get<shift>, :queue-input<push>);
#     has @.output handles (:print<push>);
#     multi method t() { Bool::True; }
# }

use-ok 'Prompt::Gruff', 'Can use Prompt::Gruff';
use Prompt::Gruff;

ok my $gruff = Prompt::Gruff.new, 'Prompt::Gruff instantiate';
# can-ok $gruff, 'required';
# can-ok $gruff, 'multiple';
# can-ok $gruff, 'prompt-for';

# my $stub = StubIO.new(:input("Cindy", ""));
# let $*IN = $stub;
# ok my $result = $gruff.prompt-for('Name: '), 'Call prompt-for';
# is $result, 'Cindy', 'Cindy passes';

#say $gruff.prompt-for("Like it?: ", :yn, :default('n'));
#say $gruff.prompt-for("Name: ", multi-line => True, verify => 2, :default('Cindy'));
#say $gruff.prompt-for("Name: ", :verify(2), :default('Cindy'), :no-escape(False));
say $gruff.prompt-for("Name starting with M: ", :regex('^M.*'), :no-escape(False));

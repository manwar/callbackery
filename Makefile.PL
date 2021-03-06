use 5.010001;

use strict;
use warnings;
use ExtUtils::MakeMaker;
use FindBin;

WriteMakefile(
  NAME         => 'CallBackery',
  VERSION_FROM => 'lib/CallBackery.pm',
  ABSTRACT     => 'CallBackery is a Mojolicious+Qoodoo Framework for building Web Applications',
  AUTHOR       => 'Tobias Oetiker <tobi@oetiker.ch>',
  LICENSE      => 'gpl_3',
  PREREQ_PM    => {
    'Mojolicious' => '7.05',
    'Mojolicious::Plugin::Qooxdoo' => '0.904',
    'Locale::PO' => '0.27',
    'Config::Grammar' => '1.12',
    'Mojo::SQLite' => '1.000',
    'Pod::Markdown::Github' =>'0',
    'PPI' => '0',
    'CPAN::Uploader' => 0
  },
  META_MERGE   => {
    requires  => {perl => '5.010001'},
    resources => {
      license     => 'http://opensource.org/licenses/GPL-3.0',
      repository  => 'https://github.com/oetiker/callbackery',
      bugtracker  => 'https://github.com/oetiker/callbackery/issues'
    },
    no_index => {directory => ['t','example','setup','lib/Mojolicious/Command/generate/callbackery_app']}
  },
  dist => {
        PREOP => q{$(PERL) -i -p -e 's/CallBackery\@\d+(\.\d+){2}/CallBackery\@$(VERSION)/g' lib/Mojolicious/Command/generate/callbackery_app/PERL_MODULES}
  },
  test => {TESTS => 't/*.t'}
);

sub MY::postamble {
   my $self = shift;
   my %r = (%{ $self->{PREREQ_PM} || {} }, %{ $self->{BUILD_REQUIRES} || {} }, %{ $self->{TEST_REQUIRES} || {} } );
   my $modules = join " ", grep !/^perl\@/, map { $r{$_} ? $_ .'@'. $r{$_} : $_ } keys %r;
   my $tpd = "$FindBin::RealBin/thirdparty";
   warn "** call 'make thirdparty' to build missing dependencies ...\n";
   return <<"EOF";

#all:: README.md README

#README.md: $self->{VERSION_FROM}
#	\$(PERL) -I$tpd/lib/perl5 -MPod::Markdown::Github -e 'binmode(STDOUT, ":utf8");Pod::Markdown::Github->new->filter(q{$self->{VERSION_FROM}})' > README.md

#README: README.md
#	cp README.md README

thirdparty: $tpd/touch
	mkdir -p $tpd

$tpd/touch: Makefile
	\$(NOECHO) \$(ECHO) "*** INSTALLING MISSING BITS FOR TESTING ***"
	curl -L https://raw.githubusercontent.com/miyagawa/cpanminus/devel/cpanm | PERL_CPANM_HOME=$tpd \$(PERL) - -q --notest --local-lib-contained $tpd $modules && touch $tpd/touch
EOF
}

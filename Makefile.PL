use 5.018002;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'RPi::DHT11::EnvControl',
    VERSION_FROM      => 'lib/RPi/DHT11/EnvControl.pm',
    PREREQ_PM         => {},
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/RPi/DHT11/EnvControl.pm',
       AUTHOR         => 'Steve Bertrand <steveb@cpan.org>') : ()),
    EXE_FILES         => [qw(bin/envgui)],
    LIBS              => ['-lwiringPi'],
    DEFINE            => '',
    INC               => '-I.',
);

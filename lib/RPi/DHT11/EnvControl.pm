

package RPi::DHT11::EnvControl;

use 5.018002;
use strict;
use warnings;

our $VERSION = '0.02';

require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ('all' => [qw(temp humidity cleanup control)]);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

require XSLoader;
XSLoader::load('RPi::DHT11::EnvControl', $VERSION);

1;
__END__

=head1 NAME

RPi::DHT11::EnvControl - Monitor environment temperature/humidity, and act
when limits are reached

=head1 SYNOPSIS

  use RPi::DHT11::EnvControl;

=head1 DESCRIPTION

This module is an interface to the DHT11 temperature/humidity sensor when
connected to a Raspberry Pi's GPIO pins.

Due to the near-realtime access requirements of reading the input pin of the
sensor, the core of this module is written in C, converted to XS.

It allows you to set temperature and humidity limits, then act when the limits
are reached. For example, if the temperature gets too high, we can enable a
120/240v relay to turn on an exhaust fan for a time.

This module requires the L<http://wiringpi.com/|wiringPi> library to be
installed.

=head2 EXPORT_OK

The C<:all> tag can be used to include all of the following, or they can be
imported individually: C<temp>, C<humidity>, C<control> and C<cleanup>.

=head1 SEE ALSO

- L<http://wiringpi.com/|wiringPi>

=head1 AUTHOR

steve02, E<lt>steveb@cpan.org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by Steve Bertrand

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.


=cut

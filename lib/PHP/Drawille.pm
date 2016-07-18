package PHP::Drawille;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";



1;
__END__

=encoding utf-8

=head1 NAME

PHP::Drawille - Terminal drawing with braille

=head1 SYNOPSIS

    use PHP::Drawille::Canvas;
    
    my $canvas = PHP::Drawille::Canvas->new;
    
    for ( my $x = 0; $x <= 1800; $x += 10 ) {
        $canvas->set( $x / 10, 10 + sin( $x * 3.14 / 180 ) * 10 );
    }
    
    print $canvas->frame . "\n";


=head1 DESCRIPTION

PHP::Drawille is a port of php-drawille.

=head1 SEE ALSO

php-drawille (L<https://github.com/whatthejeff/php-drawille>)

=head1 AUTHOR

Masahiro Iuchi E<lt>masahiro.iuchi@gmail.comE<gt>

=cut


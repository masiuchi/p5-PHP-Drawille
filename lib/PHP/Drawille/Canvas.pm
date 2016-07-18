package PHP::Drawille::Canvas;
use strict;
use warnings;
use utf8;

use parent 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors(qw/ chars /);    # Canvas representation

use Encode qw/ encode_utf8 /;
use List::Util qw/ max min /;
use HTML::Entities;
use Math::Round;
use POSIX qw/ floor /;

#
# Dots:
#
#   ,___,
#   |1 4|
#   |2 5|
#   |3 6|
#   |7 8|
#   `````
#
# @var array
# @see http://www.alanwood.net/unicode/braille_patterns.html
#
our $pixel_map
    = [ [ 0x01, 0x08 ], [ 0x02, 0x10 ], [ 0x04, 0x20 ], [ 0x40, 0x80 ] ];

#
# Braille characters starts at 0x2800
#
# @var integer
#
our $braille_char_offset = 0x2800;

sub new {
    my $class = shift;
    my $this  = $class->SUPER::new();
    $this->chars( +{} );
    return $this;
}

sub clear {
    my $this = shift;
    $this->chars( +{} );
}

sub set {
    my ( $this, $x, $y ) = @_;
    my ( $px, $py );
    ( $x, $y, $px, $py ) = @{ $this->prime( $x, $y ) };
    $this->chars->{$py}{$px} |= $this->getDotFromMap( $x, $y );
}

sub reset {
    my ( $this, $x, $y ) = @_;
    my ( $px, $py );
    ( $x, $y, $px, $py ) = @{ $this->prime( $x, $y ) };
    $this->chars->{$py}{$px} &= ~$this->getDotFromMap( $x, $y );
}

sub get {
    my ( $this, $x, $y ) = @_;
    my ( $char, $dummy );
    ( $x, $y, $dummy, $dummy, $char ) = @{ $this->prime( $x, $y ) };
    return $char & $this->getDotFromMap( $x, $y );
}

sub toggle {
    my ( $this, $x, $y ) = @_;
    $this->get( $x, $y ) ? $this->reset( $x, $y ) : $this->set( $x, $y );
}

sub row {
    my ( $this, $y, $options ) = @_;
    $options ||= +{};
    my $row = defined( $this->chars->{$y} ) ? $this->chars->{$y} : +{};
    my @keys;
    if ( !defined( $options->{'min_x'} ) || !defined( $options->{'max_x'} ) )
    {
        if ( !( @keys = keys %$row ) ) {
            return '';
        }
    }
    my $min
        = defined( $options->{'min_x'} ) ? $options->{'min_x'} : min(@keys);
    my $max
        = defined( $options->{'max_x'} ) ? $options->{'max_x'} : max(@keys);

    my $carry = '';
    for my $item ( $min .. $max ) {
        $carry .= $this->toBraille(
            defined( $row->{$item} ) ? $row->{$item} : 0 );
    }

    return $carry;
}

sub rows {
    my ( $this, $options ) = @_;
    $options ||= +{};
    my @keys;
    if ( !defined( $options->{'min_y'} ) || !defined( $options->{'max_y'} ) )
    {
        if ( !( @keys = keys %{ $this->chars } ) ) {
            return [];
        }
    }
    my $min
        = defined( $options->{'min_y'} ) ? $options->{'min_y'} : min(@keys);
    my $max
        = defined( $options->{'max_y'} ) ? $options->{'max_y'} : max(@keys);
    my @flattened;
    if ( !defined( $options->{'min_x'} ) || !defined( $options->{'max_x'} ) )
    {
        my %flattened;
        foreach my $char ( values %{ $this->chars } ) {
            $flattened{$_} = 1 for keys %$char;
        }
        @flattened = keys %flattened;
    }
    $options->{'min_x'}
        = defined( $options->{'min_x'} )
        ? $options->{'min_x'}
        : min(@flattened);
    $options->{'max_x'}
        = defined( $options->{'max_x'} )
        ? $options->{'max_x'}
        : max(@flattened);
    return [ map { $this->row( $_, $options ) } ( $min .. $max ) ];
}

sub frame {
    my ( $this, $options ) = @_;
    $options ||= +{};
    return encode_utf8( join( "\n", @{ $this->rows($options) } ) );
}

sub getChars {
    my ($this) = @_;
    return $this->chars;
}

sub toBraille {
    my ( $this, $code ) = @_;
    return decode_entities( '&#' . ( $braille_char_offset + $code ) . ';' );
}

sub getDotFromMap {
    my ( $this, $x, $y ) = @_;
    $y = $y % 4;
    $x = $x % 2;
    return $pixel_map->[ $y < 0 ? 4 + $y : $y ][ $x < 0 ? 2 + $x : $x ];
}

sub prime {
    my ( $this, $x, $y ) = @_;
    $x = round($x);
    $y = round($y);
    my $px = floor( $x / 2 );
    my $py = floor( $y / 4 );
    if ( !defined( $this->chars->{$py}{$px} ) ) {
        $this->chars->{$py}{$px} = 0;
    }
    return [ $x, $y, $px, $py, $this->chars->{$py}{$px} ];
}

1;
__END__

=encoding utf-8

=head1 NAME

PHP::Drawille::Canvas - Pixel surface

=head1 SYNOPSIS

    use PHP::Drawille::Canvas;
    
    my $canvas = PHP::Drawille::Canvas->new;
    
    for ( my $x = 0; $x <= 1800; $x += 10 ) {
        $canvas->set( $x / 10, 10 + sin( $x * 3.14 / 180 ) * 10 );
    }
    
    print $canvas->frame . "\n";

=head1 METHODS

=head2 PHP::Drawille::Canvas->new()

Creates new canvas instance.

=head2 $canvas->clear()

Clears the canvas.

=head2 $canvas->set($x, $y)

Sets a pixel at the given position.

=head2 $canvas->reset($x, $y)

Unsets a pixel at the given position.

=head2 $canvas->get($x, $y)

Gets the pixel state at a given position.

=head2 $canvas->toggle($x, $y)

Toggles the pixel state on/off at a given position.

=head2 $canvas->row($y, $options)

Gets a line.

=head2 $canvas->rows($options)

Gets all lines.

=head2 $canvas->frame($options)

Gets a string representation of the canvas.

=head2 $canvas->getChars()

Gets the canvas representation.

=head2 $canvas->toBraille($code)

Gets a braille unicode character.

=head2 $canvas->getDotFromMap($x, $y)

Gets a dot from the pixel map.

=head2 $canvas->prime($x, $y)

Autovivification for a canvas position.

=head1 SEE ALSO

L<PHP::Drawille>

=cut


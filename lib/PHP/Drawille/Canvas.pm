package PHP::Drawille::Canvas;
use strict;
use warnings;

use parent 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors(qw/ chars /);    # Canvas representation

use List::Util qw/ max min /;
use HTML::Entities;
use Math::Round;

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
    my $this  = $class->SUPER::new(@_);
    $this->chars( +{} );
    return $this;
}

#
# Clears the canvas
#
sub clear {
    my $this = shift;
    $this->chars = +{};
}

#
# Sets a pixel at the given position
#
# @param integer $x x position
# @param integer $y y position
#
sub set {
    my ( $this, $x, $y ) = @_;
    my ( $px, $py );
    ( $x, $y, $px, $py ) = @{ $this->prime( $x, $y ) };
    $this->chars->{$py}{$px} |= $this->getDotFromMap( $x, $y );
}

#
# Unsets a pixel at the given position
#
# @param integer $x x position
# @param integer $y y position
#
sub reset {
    my ( $this, $x, $y ) = @_;
    my ( $px, $py );
    ( $x, $y, $px, $py ) = @{ $this->prime( $x, $y ) };
    $this->chars->{$py}{$px} &= ~$this->getDotFromMap( $x, $y );
}

#
# Gets the pixel state at a given position
#
# @param integer $x x position
# @param integer $y y position
#
# @return bool the pixel state
#
sub get {
    my ( $this, $x, $y ) = @_;
    my ( $char, $dummy );
    ( $x, $y, $dummy, $dummy, $char ) = @{ $this->prime( $x, $y ) };
    return $char & $this->getDotFromMap( $x, $y );
}

#
# Toggles the pixel state on/off at a given position
#
# @param integer $x x position
# @param integer $y y position
#
sub toggle {
    my ( $this, $x, $y ) = @_;
    $this->get( $x, $y ) ? $this->reset( $x, $y ) : $this->set( $x, $y );
}

#
# Gets a line
#
# @param integer $y     y position
# @param array $options options
#
# @return string line
#
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

#
# Gets all lines
#
# @param array $options options
#
# @return array line
#
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

#
# Gets a string representation of the canvas
#
# @param array $options options
#
# @return string representation
#
sub frame {
    my ( $this, $options ) = @_;
    $options ||= +{};
    return join( "\n", @{ $this->rows($options) } );
}

#
# Gets the canvas representation.
#
# @return array characters
#
sub getChars {
    my ($this) = @_;
    return $this->chars;
}

#
# Gets a braille unicode character
#
# @param integer $code character code
#
# @return string braille
#
sub toBraille {
    my ( $this, $code ) = @_;
    return decode_entities( '&#' . ( $braille_char_offset + $code ) . ';' );
}

#
# Gets a dot from the pixel map.
#
# @param integer $x x position
# @param integer $y y position
#
# @return integer dot
#
sub getDotFromMap {
    my ( $this, $x, $y ) = @_;
    $y = $y % 4;
    $x = $x % 2;
    return $pixel_map->{ $y < 0 ? 4 + $y : $y }{ $x < 0 ? 2 + $x : $x };
}

#
# Autovivification for a canvas position.
#
# @param integer $x x position
# @param integer $y y position
#
# @return array
#
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


package PHP::Drawille::Turtle;
use strict;
use warnings;
use utf8;

use parent 'PHP::Drawille::Canvas';
__PACKAGE__->mk_accessors(qw/ x y rotation _up /);

use List::Util qw/ max min /;
use Math::Round;
use Math::Trig;

sub new {
    my ( $class, $x, $y ) = @_;
    my $this = $class->SUPER::new();

    $x ||= 0;
    $y ||= 0;

    $this->x($x);
    $this->y($y);
    $this->rotation(0);

    return $this;
}

#
# Gets the current x position.
#
# @return integer x position
#
sub getX {
    my $this = shift;
    return $this->x;
}

#
# Gets the current y position.
#
# @return integer y position
#
sub getY {
    my $this = shift;
    return $this->y;
}

#
# Gets the current canvas rotation
#
# @return integer current canvas rotation
#
sub getRotation {
    my $this = shift;
    return $this->rotation;
}

#
# Push the pen down
#
sub down {
    my $this = shift;
    $this->_up(0);
}

#
# Pull the pen up
#
sub up {
    my $this = shift;
    $this->_up(1);
}

#
# Move the pen forward
#
# @param integer $length distance to move forward
#
sub forward {
    my ( $this, $length ) = @_;
    my $theta = $this->rotation / 180.0 * pi;
    my $x     = $this->x + $length * cos($theta);
    my $y     = $this->y + $length * sin($theta);
    $this->move( $x, $y );
}

#
# Move the pen backwards
#
# @param integer $length distance to move backwards
#
sub back {
    my ( $this, $length ) = @_;
    $this->forward( -$length );
}

#
# Angle the canvas to the right.
#
# @param integer $angle degree to angle
#
sub right {
    my ( $this, $angle ) = @_;
    $this->rotation( $this->rotation + $angle );
}

#
# Angle the canvas to the left.
#
# @param integer $angle degree to angle
#
sub left {
    my ( $this, $angle ) = @_;
    $this->rotation( $this->rotation - $angle );
}

#
# Move the pen, drawing if the pen is down.
#
# @param int $y new x position
# @param int $y new y position
#
sub move {
    my ( $this, $x, $y ) = @_;
    if ( !$this->_up ) {
        my $x1    = round( $this->x );
        my $y1    = round( $this->y );
        my $x2    = $x;
        my $y2    = $y;
        my $xdiff = max( $x1, $x2 ) - min( $x1, $x2 );
        my $ydiff = max( $y1, $y2 ) - min( $y1, $y2 );
        my $xdir  = $x1 <= $x2 ? 1 : -1;
        my $ydir  = $y1 <= $y2 ? 1 : -1;
        my $r     = max( $xdiff, $ydiff );

        for ( my $i = 0; $i <= $r; $i++ ) {
            $x = $x1;
            $y = $y1;
            if ( $ydiff > 0 ) {
                $y += ( $i * $ydiff ) / $r * $ydir;
            }
            if ( $xdiff > 0 ) {
                $x += ( $i * $xdiff ) / $r * $xdir;
            }
            $this->set( $x, $y );
        }
    }
    $this->x($x);
    $this->y($y);
}

#
# Pull the pen up
#
sub pu {
    my $this = shift;
    $this->up();
}

#
# Push the pen up
#
sub pd {
    my $this = shift;
    $this->down();
}

#
# Move the pen forward
#
# @param integer $length distance to move forward
#
sub fd {
    my ( $this, $length ) = @_;
    $this->forward($length);
}

#
# Move the pen, drawing if the pen is down.
#
# @param int $y new x position
# @param int $y new y position
#
sub mv {
    my ( $this, $x, $y ) = @_;
    $this->move( $x, $y );
}

#
# Angle the canvas to the right.
#
# @param integer $angle degree to angle
#
sub rt {
    my ( $this, $angle ) = @_;
    $this->right($angle);
}

#
# Angle the canvas to the left.
#
# @param integer $angle degree to angle
#
sub lt {
    my ( $this, $angle ) = @_;
    $this->left($angle);
}

#
# Move the pen backwards
#
# @param integer $length distance to move backwards
#
sub bk {
    my ( $this, $length ) = @_;
    $this->back($length);
}

1;


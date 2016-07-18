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

sub getX {
    my $this = shift;
    return $this->x;
}

sub getY {
    my $this = shift;
    return $this->y;
}

sub getRotation {
    my $this = shift;
    return $this->rotation;
}

sub down {
    my $this = shift;
    $this->_up(0);
}

sub up {
    my $this = shift;
    $this->_up(1);
}

sub forward {
    my ( $this, $length ) = @_;
    my $theta = $this->rotation / 180.0 * pi;
    my $x     = $this->x + $length * cos($theta);
    my $y     = $this->y + $length * sin($theta);
    $this->move( $x, $y );
}

sub back {
    my ( $this, $length ) = @_;
    $this->forward( -$length );
}

sub right {
    my ( $this, $angle ) = @_;
    $this->rotation( $this->rotation + $angle );
}

sub left {
    my ( $this, $angle ) = @_;
    $this->rotation( $this->rotation - $angle );
}

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

sub pu {
    my $this = shift;
    $this->up();
}

sub pd {
    my $this = shift;
    $this->down();
}

sub fd {
    my ( $this, $length ) = @_;
    $this->forward($length);
}

sub mv {
    my ( $this, $x, $y ) = @_;
    $this->move( $x, $y );
}

sub rt {
    my ( $this, $angle ) = @_;
    $this->right($angle);
}

sub lt {
    my ( $this, $angle ) = @_;
    $this->left($angle);
}

sub bk {
    my ( $this, $length ) = @_;
    $this->back($length);
}

1;
__END__

=encoding utf-8

=head1 NAME

PHP::Drawille::Turtle - Basic turtle graphics interface

=head1 SYNOPSIS

    use PHP::Drawille::Turtle;
    
    my $turtle = PHP::Drawille::Turtle->new;
    
    for ( my $x = 0; $x < 36; $x++ ) {
        $turtle->right(10);
    
        for ( my $y = 0; $y < 36; $y++ ) {
            $turtle->right(10);
            $turtle->forward(8);
        }
    }
    
    print $turtle->frame . "\n";

=head1 METHODS

=head2 PHP::Drawille::Turtle->new([$x [, $y]])

Creates new turtle intance.

=head2 $turtle->getX()

Gets the current x position.

=head2 $turtle->getY()

Gets the current y position.

=head2 $turtle->getRotation()

Gets the current canvas rotation.

=head2 $turtle->down()

=head2 $turtle->pd()

Push the pen down.

=head2 $turtle->up()

=head2 $turtle->pu()

Pull the pen up.

=head2 $turtle->forward($length)

=head2 $turtle->fd($length)

Move the pen forward.

=head2 $turtle->back($length)

=head2 $turtle->bk($length)

Move the pen backwards.

=head2 $turtle->right($angle)

=head2 $turtle->rt($angle)

Angle the canvas to the right.

=head2 $turtle->left($angle)

=head2 $turtle->lt($angle)

Angle the canvas to the left.

=head2 $turtle->move($x, $y)

=head2 $turtle->mv($x, $y)

Move the pen forward.

=head1 SEE ALSO

L<PHP::Drawille>

=cut

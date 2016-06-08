use strict;
use warnings;
use utf8;

use Test::More;

use PHP::Drawille::Turtle;

subtest 'position' => sub {
    my $turtle = PHP::Drawille::Turtle->new;
    is( $turtle->getX, 0 );
    is( $turtle->getY, 0 );

    $turtle->move( 1, 2 );
    is( $turtle->getX, 1 );
    is( $turtle->getY, 2 );
};

subtest 'rotation' => sub {
    my $turtle = PHP::Drawille::Turtle->new;
    is( $turtle->getRotation, 0 );

    $turtle->right(30);
    is( $turtle->getRotation, 30 );

    $turtle->left(30);
    is( $turtle->getRotation, 0 );
};

subtest 'brush' => sub {
    my $turtle = PHP::Drawille::Turtle->new;
    ok( !$turtle->get( $turtle->getX(), $turtle->getY() ) );

    $turtle->forward(1);
    ok( $turtle->get( 0,               0 ) );
    ok( $turtle->get( $turtle->getX(), $turtle->getY() ) );

    $turtle->up();
    $turtle->move( 2, 0 );
    ok( !$turtle->get( $turtle->getX(), $turtle->getY() ) );

    $turtle->down();
    $turtle->move( 3, 0 );
    ok( $turtle->get( $turtle->getX(), $turtle->getY() ) );
};

done_testing;


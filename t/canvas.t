use strict;
use warnings;
use utf8;

use Test::More;

use PHP::Drawille::Canvas;

subtest 'set' => sub {
    my $canvas = PHP::Drawille::Canvas->new;
    $canvas->set( 0, 0 );
    is_deeply( $canvas->getChars, { 0 => { 0 => 1 } } );
};

subtest 'reset' => sub {
    my $canvas = PHP::Drawille::Canvas->new;
    $canvas->set( 0, 0 );
    $canvas->reset( 0, 0 );
    is_deeply( $canvas->getChars, { 0 => { 0 => 0 } } );
};

subtest 'clear' => sub {
    my $canvas = PHP::Drawille::Canvas->new;
    $canvas->set( 0, 0 );
    $canvas->clear();
    is_deeply( $canvas->getChars, +{} );
};

subtest 'toggle' => sub {
    my $canvas = PHP::Drawille::Canvas->new;
    $canvas->toggle( 0, 0 );
    is_deeply( $canvas->getChars, { 0 => { 0 => 1 } } );
    $canvas->toggle( 0, 0 );
    is_deeply( $canvas->getChars, { 0 => { 0 => 0 } } );
};

subtest 'frame' => sub {
    my $canvas = PHP::Drawille::Canvas->new;
    is( $canvas->frame, '' );
    $canvas->set( 0, 0 );
    is( $canvas->frame, '⠁' );
};

subtest 'get' => sub {
    my $canvas = PHP::Drawille::Canvas->new;
    ok( !$canvas->get( 0, 0 ) );
    $canvas->set( 0, 0 );
    ok( $canvas->get( 0, 0 ) );
    ok( !$canvas->get( 1, 0 ) );
    ok( !$canvas->get( 0, 1 ) );
    ok( !$canvas->get( 1, 1 ) );
};

done_testing;


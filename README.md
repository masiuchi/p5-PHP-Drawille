# NAME

PHP::Drawille - Terminal drawing with braille

# SYNOPSIS

    use PHP::Drawille::Canvas;
    
    my $canvas = PHP::Drawille::Canvas->new;
    
    for ( my $x = 0; $x <= 1800; $x += 10 ) {
        $canvas->set( $x / 10, 10 + sin( $x * 3.14 / 180 ) * 10 );
    }
    
    print $canvas->frame . "\n";

# DESCRIPTION

PHP::Drawille is a port of php-drawille.

# SEE ALSO

* php-drawille (https://github.com/whatthejeff/php-drawille)
* drawille (https://github.com/asciimoo/drawille)

# AUTHOR

Masahiro Iuchi <masahiro.iuchi@gmail.com>

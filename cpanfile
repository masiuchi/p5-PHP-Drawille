## -*- mode: perl; coding: utf-8 -*-

requires 'perl', '5.008001';

requires 'parent';
requires 'Encode';

requires 'Class::Accessor::Fast';
requires 'HTML::Entities';
requires 'Math::Round';

on 'test' => sub {
    requires 'Test::More', '0.98';
};


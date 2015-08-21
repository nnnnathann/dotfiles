'use strict';
var gulp = require('gulp');
var jspm = require('jspm');

jspm.setPackagePath('.');

gulp.task('bundle-head', function () {
    var headBundle = ['modernizr'];
    var builder = new jspm.Builder();
    return builder.buildSFX(headBundle.join(' + '), './_tmp/head.js', {
        inject: true
    });
});
gulp.task('bundle-body', function () {
    var devBundle = [
        'jsx', 'babel', 'css',
        'react', 'react.backbone', 'react-router',
        'underscore', 'backbone',
        'add-to-homescreen', 'favico.js'
    ];
    var builder = new jspm.Builder();
    return builder.build(devBundle.join(' + '), './_tmp/build.js', {
        inject: true
    });
});

gulp.task('bundle-dev', ['bundle-body', 'bundle-head']);

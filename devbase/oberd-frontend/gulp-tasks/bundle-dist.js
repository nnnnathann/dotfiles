'use strict';
var gulp = require('gulp');
var jspm = require('jspm');
var clean = require('gulp-clean');

jspm.setPackagePath('.');

gulp.task('bundle-app-head', function () {
    var headBundle = ['modernizr'];
    var builder = new jspm.Builder();
    return builder.buildSFX(headBundle.join(' + '), './dist/head.js', {
        inject: true
    });
});

gulp.task('copy-source', function () {
    return gulp.src([
        'src/*.{js,jsx,html}',
        'src/styles/**/*.css',
        'src/jspm_packages/*.{js,map}',
        'src/components/**/*.{js,jsx}',
        'src/data/**/*.{js,jsx}',
        'src/pages/**/*.{js,jsx}',
        'src/support/**/*.{js,jsx}'
    ], { base: 'src' })
    .pipe(gulp.dest('dist'));
});

gulp.task('copy-css', ['myth-dist'], function () {
    return gulp.src(['dist/**/*.css'], { base: 'dist' })
        .pipe(gulp.dest('src'));
});

gulp.task('clean-css', ['myth'], function () {
    return gulp.src([
        'src/components/**/*.css',
        'src/pages/**/*.css',
        'src/styles/main.css',
        'src/support/**/*.css'
    ])
    .pipe(clean());
});

gulp.task('bundle-app', ['copy-source', 'assets-dist', 'copy-css'], function () {
    var devBundle = [
        'main.jsx!'
    ];
    var builder = new jspm.Builder();
    return builder.buildSFX(devBundle.join(' + '), './dist/build.js', {
        inject: true,
        separateCSS: true,
        minify: true,
        sourceMaps: true
    });
});

gulp.task('create-bundle', ['bundle-app', 'bundle-app-head']);
gulp.task('bundle-dist', ['create-bundle'], function () {
    return gulp.start('clean-css');
});

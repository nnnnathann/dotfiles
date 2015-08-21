'use strict';
var gulp = require('gulp');
var myth = require('gulp-myth');
var rename = require('gulp-rename');

gulp.task('myth', function () {
    return gulp.src([
            'src/styles/**/*.myth',
            'src/components/**/*.myth',
            'src/pages/**/*.myth',
            'src/support/**/*.myth'
        ], { base: 'src' })
        .pipe(myth())
        .pipe(rename({ extname: '.css' }))
        .pipe(gulp.dest('_tmp'));
});

gulp.task('myth-dist', function () {
    return gulp.src([
            'src/styles/**/*.myth',
            'src/components/**/*.myth',
            'src/pages/**/*.myth',
            'src/support/**/*.myth'
        ], { base: 'src' })
        .pipe(myth())
        .pipe(rename({ extname: '.css' }))
        .pipe(gulp.dest('dist'));
});


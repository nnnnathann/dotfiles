'use strict';
var gulp = require('gulp');
var jspm = require('jspm');
var flatten = require('gulp-flatten');

function ambFonts(dest) {
    return function (done) {
        jspm.locate('GetAmbassador/conventions-bower').then(function (name) {
            var modulePath = name.replace(/\.js$/, '');
            gulp.src(modulePath + '/fonts/proxima-nova/*')
                .pipe(flatten())
                .pipe(gulp.dest(dest))
                .on('end', done);
        });
    };
}
gulp.task('ambassador-fonts', ambFonts('./_tmp/fonts'));
gulp.task('ambassador-fonts-dist', ambFonts('./dist/fonts'));
function ouiFonts(dest) {
    return function (done) {
        jspm.locate('oberd/oui').then(function (name) {
            var modulePath = name.replace(/\.js$/, '');
            gulp.src(modulePath + '/dist/fonts/*')
                .pipe(flatten())
                .pipe(gulp.dest(dest))
                .on('end', done);
        });
    };
}
function ouiCSS(dest) {
    return function (done) {
        jspm.locate('oberd/oui').then(function (name) {
            var modulePath = name.replace(/\.js$/, '');
            gulp.src(modulePath + '/dist/css/*')
                .pipe(flatten())
                .pipe(gulp.dest(dest))
                .on('end', done);
        });
    };
}
gulp.task('oui-fonts', ouiFonts('./_tmp/fonts'));
gulp.task('oui-fonts-dist', ouiFonts('./dist/fonts'));

gulp.task('oui-css', ouiCSS('./_tmp/styles'));
gulp.task('oui-css-dist', ouiCSS('./dist/styles'));

gulp.task('assets', ['oui-fonts', 'oui-css', 'ambassador-fonts']);
gulp.task('assets-dist', ['oui-fonts-dist', 'ambassador-fonts-dist']);

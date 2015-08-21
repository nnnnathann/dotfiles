'use strict';

var gulp = require('gulp');
var watch = require('gulp-watch');

var koa = require('koa');
var olive = require('olive-middleware-koa');
var stat = require('koa-static');

gulp.task('dist', ['bundle-dist'], function () {
    var port = process.env.PORT || 8000;
    var app = koa();
    app.use(olive.services());
    app.use(olive.icons());
    app.use(olive.session());
    app.use(olive.env());
    app.use(stat('./dist'));
    app.listen(port);
    console.log('Listening on: http://oberd.dev:' + port);
    console.log('Tests at: http://oberd.dev:' + port + '/test.html');
});

gulp.task('default', ['bundle-dev', 'myth', 'assets', 'test-files'], function () {
    var port = process.env.PORT || 8000;
    var app = koa();
    app.use(olive.services());
    app.use(olive.icons());
    app.use(olive.session());
    app.use(stat('./src'));
    app.use(stat('./_tmp'));
    app.use(olive.env());
    app.listen(port);
    console.log('Listening on: http://oberd.dev:' + port);
    console.log('Tests at: http://oberd.dev:' + port + '/test.html');
    watch(['src/**/*.myth'], function () {
        gulp.start('myth');
    });
    watch(['src/components/**/*test.{js,jsx}'], function () {
        gulp.start('test-files');
    });
});

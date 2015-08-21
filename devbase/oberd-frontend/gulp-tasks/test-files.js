'use strict';
var gulp = require('gulp');
var glob = require('multi-glob').glob;
var mkdirp = require('mkdirp').sync;
var fs = require('fs');

gulp.task('test-files', function (done) {
    glob([
        'components/**/*test.{js,jsx}',
        'pages/**/*test.{js,jsx}',
        'data/**/*test.{js,jsx}',
        'support/**/*test.{js,jsx}',
    ], { cwd: process.cwd() + '/src' }, function (err, files) {
        mkdirp(process.cwd() + '/_tmp');
        files = files.map(function (file) {
            return file.replace(/jsx$/, 'jsx!').replace(/\.js$/, '');
        });
        fs.writeFileSync(process.cwd() + '/_tmp/test-files.json', JSON.stringify(files));
        done();
    });
});

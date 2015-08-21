'use strict';
var gulp = require('gulp');
var jspm = require('jspm');
var glob = require('multi-glob').glob;
jspm.setPackagePath('.');

gulp.task('bundle-tests', function (done) {
    glob('tests/**/*.{js,jsx}', { cwd: process.cwd() + '/src' }, function (err, files) {
        var testBundle = [
            'mocha',
            'chai',
            'react',
            'react.backbone',
            'react-router',
            'underscore',
            'backbone',
            'jsx',
            'babel',
            'css',
            'add-to-homescreen',
            'favico.js',
            'react-toggle',
            'json'
        ];
        testBundle = testBundle.concat(files);
        var builder = new jspm.Builder();
        builder.build(testBundle.join(' + '), './_tmp/bundle-test.js', { inject: true})
            .then(function() {
                done();
            }, console.log.bind(console));
    });
});


var gulp = require('gulp');
var pump = require('pump');
var crass = require('gulp-crass');
var uglify = require('gulp-uglify');
var svgmin = require('gulp-svgmin');
var htmlmin = require('gulp-html-minifier');

gulp.task('default', ['crass', 'uglifyjs', 'svgmin', 'htmlmin']);

gulp.task('crass', function (cb) {
  pump(
    [
      gulp.src('./deploy/assets/**/*.css'),
      crass({
        pretty: false
      }),
      gulp.dest('deploy/assets/')
    ],
    cb
  );
});

gulp.task('uglifyjs', function (cb) {
  pump(
    [
      gulp.src('./deploy/assets/**/*.js'),
      uglify(),
      gulp.dest('deploy/assets/')
    ],
    cb
  );
});

gulp.task('svgmin', function (cb) {
  pump(
    [
      gulp.src('./deploy/assets/**/*.svg'),
      svgmin({
        plugins: [{
          removeComments: true
        }, {
          removeDesc: true
        }, {
          removeMetadata: true
        }, {
          removeTitle: true
        }]
      }),
      gulp.dest('deploy/assets/')
    ],
    cb
  );
});

gulp.task('htmlmin', function (cb) {
  pump(
    [
      gulp.src('./deploy/**/*.html'),
      htmlmin({
        collapseBooleanAttributes: true,
        collapseWhitespace: true,
        conservativeCollapse: true,
        decodeEntities: true,
        ignorePath: '/assets',
        minifyCSS: crass,
        minifyJS: uglify,
        removeComments: true,
        sortAttributes: true,
        sortClassName: true,
        useShortDoctype: true
      }),
      gulp.dest('deploy')
    ],
    cb
  );
});
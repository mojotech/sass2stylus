// Modules
var fs      = require('fs'),
    path    = require('path'),
    stylus  = require('stylus'),
    should  = require('should');

describe('sass2stylus method', function() {
  var sassFileContents, scssFileContents, stylFileContents;

  beforeEach(function(done) {
    var sass2stylus = require(path.join(path.resolve(__dirname, '..'), 'lib/sass2stylus'));

    sass2stylus('../fixtures/foo.sass', '../fixtures/foo.sass.tmp.styl', function() {
      sass2stylus('../fixtures/foo.scss', '../fixtures/foo.scss.tmp.styl', function(){
        // Files
          sassFileContents    = fs.readFileSync(path.join(path.resolve(__dirname, '..'), 'fixtures/foo.sass'), { encoding: 'utf8' });
          scssFileContents    = fs.readFileSync(path.join(path.resolve(__dirname, '..'), 'fixtures/foo.scss'), { encoding: 'utf8' });
          stylFileContents    = fs.readFileSync(path.join(path.resolve(__dirname, '..'), 'fixtures/foo.styl'), { encoding: 'utf8' });
          done();
      });
    });

  });
  it('should convert a Sass file to Stylus', function() {
    var sassTmpFileContents = fs.readFileSync(path.join(path.resolve(__dirname, '..'), 'fixtures/foo.sass.tmp.styl'), { encoding: 'utf8' });
    sassTmpFileContents.should.equal(stylFileContents);
  });
  it('should convert a SCSS file to Stylus', function() {
    var scssTmpFileContents = fs.readFileSync(path.join(path.resolve(__dirname, '..'), 'fixtures/foo.scss.tmp.styl'), { encoding: 'utf8' });
    scssTmpFileContents.should.equal(stylFileContents);
  });
});

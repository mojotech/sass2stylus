// Modules
var fs        = require('fs'),
    path      = require('path'),
    exec      = require('child_process').exec,
    tempWrite = require('temp-write'),
    clc       = require('cli-color');

module.exports = function(inputFileName, outputFileName, cb) {

  // Files
  var converter     = path.join(__dirname, '/node_converter.rb'),
      filePath      = path.join(__dirname, '/' + inputFileName),
      fileExt       = path.extname(filePath),
      tmpFile       = tempWrite.sync(fs.readFileSync(filePath), path.basename(inputFileName, '.sass')),
      outputFileExt = path.extname(outputFileName);

  // sass2stylus
  var sass2stylus = function() {
    exec('ruby ' + converter + ' ' + tmpFile, function(error, stdout, stderr) {
      console.log(clc.yellow('Converting from Sass to Stylus'));
      if(error !== null) {
        console.log(clc.red(error));
      } else {
        fs.writeFileSync(outputFileName, stdout);

        if (typeof cb === "function") {
         cb();
        }
      }
    });
  };

  if(fileExt === '.scss') {
    console.log(clc.yellow('Converting from SCSS to a tmp Sass file'));
    exec('sass-convert ' + tmpFile + ' ' + tmpFile + '.sass', function(error, stdout, stderr) {
      if(error !== null) {
        console.log(clc.red(error));
      } else {
        sass2stylus();
      }
    });
  } else if(fileExt === '.sass') {
    sass2stylus();
  } else {
    console.log(clc.red('Please pass a valid Sass or SCSS file as your first argument'));
    exit;
  }

  if(outputFileExt !== '.styl') {
    console.log(clc.red('Please pass a valid Stylus output filename as your second argument'));
    exit;
  }
};

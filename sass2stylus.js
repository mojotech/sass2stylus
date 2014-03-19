#!/usr/bin/env node

var exec = require('child_process').exec,
    fs = require('fs'),
    cliArg = process.argv,
    filename = cliArg[2],
    rawFilename = filename.replace(/.scss|.sass/, ''),
    sassFile = filename.replace('.scss', '.sass'),
    converter = __dirname +'/converter.rb',
    s2s = function() {
      exec('ruby '+ converter +' '+ sassFile, function(error, stdout, stderr) {
        console.log('Converting Sass to Stylus');
        fs.writeFileSync(rawFilename + '.styl', stdout);
        if(error !== null) {
          console.log(error);
        }
        if(filename.match(/.scss/)) {
          fs.unlinkSync(sassFile);
        }
      });
    };

if(filename.match(/.scss/)) {
  // Convert SCSS to Sass
  exec('sass-convert '+ filename +' '+ sassFile, function(error, stdout, stderr) {
    s2s();
    if(error !== null) {
      console.log(error);
    }
  });
} else if(filename.match(/.sass/)) {
  s2s();
} else {
  console.log('You didn\'t pass a Sass (or SCSS) file.\nUsage: sass2stylus foo.scss');
}

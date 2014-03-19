#!/usr/bin/env node

// Modules
var program     = require('commander'),
    package     = require('../package.json'),
    sass2stylus = require('../lib/sass2stylus');

// Commander
program
  .usage('input.scss output.styl')
  .version(package.version);

program.on('--help', function() {
  console.log('  Example:');
  console.log('');
  console.log('    $ sass2stylus foo.sass foo.styl');
  console.log('    $ sass2stylus foo.scss foo.styl');
  console.log('');
});

program.parse(process.argv);

if(!process.argv[2] || !process.argv[3]) {
  program.help();
  exit;
}

sass2stylus(process.argv[2], process.argv[3]);

# roots v2.1.2
# Files in this list will not be compiled - minimatch supported
ignore_files: ['_*', 'readme*', '.gitignore', '.DS_Store', '*.rb', '*.ru', "Gemfile", "Gemfile.lock", "package.json", "README.html", "sass2stylus.js"]
ignore_folders: ['.git', 'node_modules', 'public-tmp']

watcher_ignore_folders: ['components', 'node_modules']

# Layout file config
# `default` applies to all views. Override for specific
# views as seen below.
layouts:
  default: 'layout.jade'
  # 'special_view.jade': 'special_layout.jade'

# Locals will be made available on every page. They can be
# variables or (coffeescript) functions.
locals:
  title: 'sass2stylus - Easily convert sass to stylus'

# Precompiled template path, see http://roots.cx/docs/#precompile
# templates: 'views/templates'

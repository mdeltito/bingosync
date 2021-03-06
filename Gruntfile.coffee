sass = require('node-sass')
CssImporter = require('node-sass-css-importer')({
  import_paths: ['assets/vendor']
})

module.exports = (grunt)->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      compile:
        files:
          '.tmp/scripts/client.js': 'assets/scripts/**/*.coffee'

    concat:
      options:
        separator: ';'
      dist:
        src: [
          'assets/vendor/lodash/dist/lodash.js'
          'assets/vendor/jquery/dist/jquery.js'
          'assets/vendor/bootstrap-sass-official/vendor/assets/javascripts/bootstrap/button.js'
          'assets/vendor/bootstrap-sass-official/vendor/assets/javascripts/bootstrap/dropdown.js'
          'assets/vendor/bootstrap-sass-official/vendor/assets/javascripts/bootstrap/alert.js'
          'assets/vendor/bootstrap-sass-official/vendor/assets/javascripts/bootstrap/modal.js'
          'assets/vendor/remarkable-bootstrap-notify/bootstrap-growl.js'
          'assets/vendor/moment/moment.js'
          '.tmp/scripts/**/*.js'
        ]
        dest: 'public/scripts/<%= pkg.name %>.js'

    uglify:
      dist:
        options:
          sourceMap: true,
          sourceMapName: 'public/scripts/<%= pkg.name %>.map'
        files:
          'public/scripts/<%= pkg.name %>.min.js': ['<%= concat.dist.dest %>']

    clean:
      files:
        dot: true,
        src: ['.tmp', 'public/scripts/**/*.js', 'public/styles/**/*.css']

    copy:
      fonts:
        expand: true
        flatten: true
        src: ['assets/vendor/bootstrap-sass-official/vendor/assets/fonts/bootstrap/*']
        dest: 'public/fonts/'
        filter: 'isFile'


    sass:
      options:
        implementation: sass
        sourceMap: true
        includePaths: ['assets/vendor']
        importer: [CssImporter]
        outputStyle: 'expanded'
      dist:
        files:
          'public/styles/bingosync.css': 'assets/styles/bingosync.scss'

    cssmin:
      minify:
        expand: true
        cwd: 'public/styles/'
        src: ['*.css', '!*.min.css']
        dest: 'public/styles/'
        ext: '.min.css'

    nodemon:
      dev:
        script: 'app/app.coffee'
        options:
          watch: ['lib', 'app']
          nodeArgs: ['--nodejs', '--debug'],

    concurrent:
      dev:
        tasks: ['nodemon', 'watch']
        options:
          logConcurrentOutput: true

    watch:
      scss:
        files: ['assets/styles/**/*.scss']
        tasks: ['styles']
      coffee:
        files: ['Gruntfile.coffee', 'assets/**/*.coffee']
        tasks: ['scripts']
      scripts:
        files: ['assets/**/*.js']
        tasks: ['concat:dist', 'uglify']

    'node-inspector':
      'web-host': 'localhost'

  grunt.registerTask 'scripts', ['coffee:compile', 'concat:dist', 'uglify']
  grunt.registerTask 'styles',  ['sass', 'copy', 'cssmin']
  grunt.registerTask 'dev',     ['concurrent:dev']
  grunt.registerTask 'default', ['clean', 'scripts', 'styles']

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
          'assets/lib/lodash/dist/lodash.js'
          'assets/lib/jquery/dist/jquery.js'
          'assets/lib/bootstrap-sass-official/vendor/assets/javascripts/bootstrap/button.js'
          'assets/lib/bootstrap-sass-official/vendor/assets/javascripts/bootstrap/dropdown.js'
          'assets/lib/bootstrap-sass-official/vendor/assets/javascripts/bootstrap/alert.js'
          'assets/lib/bootstrap-growl/bootstrap-growl.js'
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
        src: ['assets/lib/bootstrap-sass-official/vendor/assets/fonts/bootstrap/*']
        dest: 'public/fonts/'
        filter: 'isFile'

    compass:
      options:
        config: 'config/compass.rb'
        sassDir: 'assets/styles'
        cssDir: 'public/styles'
        imagesDir: 'assets/images'
        javascriptsDir: 'assets/scripts'
        fontsDir: 'assets/styles/fonts'
        relativeAssets: false
        debugInfo: true
        bundleExec: true
      dist:
        options:
          debugInfo: false

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
  grunt.registerTask 'styles',  ['compass', 'copy', 'cssmin']
  grunt.registerTask 'dev',     ['concurrent:dev']
  grunt.registerTask 'default', ['clean', 'scripts', 'styles']

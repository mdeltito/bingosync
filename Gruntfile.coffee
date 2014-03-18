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
          'assets/lib/bootstrap-sass-official/vendor/assets/javascripts/bootstrap/alert.js'
          'assets/lib/jquery.gritter/js/jquery.gritter.js'
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

    compass:
      options:
        sassDir: 'assets/styles'
        cssDir: 'public/styles'
        generatedImagesDir: '.tmp/images/generated'
        imagesDir: 'assets/images'
        javascriptsDir: 'assets/scripts'
        fontsDir: 'assets/styles/fonts'
        importPath: ['assets/lib/bootstrap-sass-official/vendor/assets/stylesheets']
        httpImagesPath: '/images'
        httpGeneratedImagesPath: '/images/generated'
        httpFontsPath: '/styles/fonts'
        relativeAssets: false
        assetCacheBuster: false
        debugInfo: true
        raw: 'Sass::Script::Number.precision = 10\n'
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

  grunt.registerTask 'scripts', ['coffee:compile', 'concat:dist', 'uglify']
  grunt.registerTask 'styles',  ['compass', 'cssmin']
  grunt.registerTask 'dev',     ['concurrent:dev']
  grunt.registerTask 'default', ['clean', 'scripts', 'styles']

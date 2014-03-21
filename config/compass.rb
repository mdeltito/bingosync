require 'sass-css-importer'

Sass::Script::Number.precision = 10
add_import_path 'assets/lib'
add_import_path Sass::CssImporter::Importer.new("assets/lib/jquery.gritter/css")

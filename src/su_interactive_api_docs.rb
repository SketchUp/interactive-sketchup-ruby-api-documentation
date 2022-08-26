require 'extensions.rb'

module Trimble
  module InteractiveSketchUpRubyAPI

    extension = SketchupExtension.new("API Extension", "su_interactive_api_docs/main")
    extension.name = "Interactive API Documentation"
    extension.description = "Interactive SketchUp Ruby API documentation."
    extension.version = "1.0.0"
    extension.copyright = "2017-2022"
    extension.creator = "Trimble Inc"
    Sketchup.register_extension(extension, true)

  end
end

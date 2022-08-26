require "sketchup.rb"

require "su_interactive_api_docs/dialog"

module Trimble
  module InteractiveSketchUpRubyAPI

    unless file_loaded?(__FILE__)

      # Commands
      cmd = UI::Command.new("Interactive SketchUp Ruby API documentation") {
        DocumentationDialog.open
      }
      cmd.tooltip = "Open the Interactive Ruby API documentation dialog."
      cmd_interactive_documentation = cmd

      # Menus
      menu_name = Sketchup.version.to_f < 21.1 ? 'Plugins' : 'Developer'
      menu = UI.menu(menu_name)
      menu.add_item(cmd_interactive_documentation)

      # Toolbars
      toolbar = UI::Toolbar.new("Ruby API Documentation")
      toolbar.add_item(cmd_interactive_documentation)

      file_loaded(__FILE__)
    end

  end
end

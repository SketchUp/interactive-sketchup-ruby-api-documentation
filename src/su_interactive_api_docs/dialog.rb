module Trimble
  module InteractiveSketchUpRubyAPI

    module DocumentationDialog

      path = __dir__
      path.force_encoding('UTF-8')
      PATH = path.freeze

      #This is what gets called when the user clicks the Icon - this is where everything really starts.
      def self.open
        options = {
          :dialog_title => "Interactive SketchUp Ruby API documentation",
          :scrollable => true,
          :resizable => true,
          :width => 1100,
          :height => 700,
          :left => 100,
          :top => 100,
        }

        @dialog_to_ruby = UI::HtmlDialog.new(options)
        @dialog_to_ruby.set_url("https://ruby.sketchup.com/")


        # This block gets called every time a page in the API gets loaded. This
        # block is what kicks off the process to re-write all the sample
        # snippets as code editors.
        # What it does is first injects some special css styles into the page.
        @dialog_to_ruby.add_action_callback("page_loaded") { |action_context|
          inject_css(@dialog_to_ruby)
          inject_ace(@dialog_to_ruby)
        }

        # This gets called once the html is modified with the new css, the new
        # Ace editor code is injected and accepted. I had tried combining this
        # functionality with the inject_ace method. However when I tried to load
        # the ace.js script at the same time as running this script, it would
        # not work. I think there was a race condition and this script would not
        # find the ace editor js code. So that is why this has to be called
        # completely separately, after ace is completely loaded.
        @dialog_to_ruby.add_action_callback("inject_ace_editors") { |action_context|
          ace_loader_path = File.join(PATH, "resources", "aceloader.js")
          ace_loader_string = IO.read(ace_loader_path)
          @dialog_to_ruby.execute_script(ace_loader_string)
        }


        # This is what gets called by the editor when the user clicks the
        # "Execute in Sketchup" button. That button sends the string from the
        # editor to this block, which then evals the string in SketchUp.
        @dialog_to_ruby.add_action_callback("htmlDialog_to_ruby") { |action_context, code|
          SKETCHUP_CONSOLE.show
          result = eval(code)
          p result
        }

        @dialog_to_ruby.show
      end

      # Inject css to the head of the page to stylize the editor divs. This has
      # to happen before we attempt to inject the code editors because they
      # rely on this css.
      def self.inject_css(dialog)
        ace_css_path = File.join(PATH, "resources", "ace.css")
        ace_css_string = IO.read(ace_css_path)
        ace_css_string.delete!("\n")

        # This takes the nicely formatted css string and creates the appropriate
        # style element in the html page. Then injects the css into the page so
        # that the editors have some special css that they need.
        dialog.execute_script(%Q~
          var thehead = document.head;
          var style_wrap = document.createElement('style');
          style_wrap.innerHTML="#{ace_css_string}";
          thehead.appendChild(style_wrap);
        ~)
      end

      # This injects a script element into the page. It works like this: Once
      # the page is done loading, this script executes the callback defined in
      # this file called sketchup.inject_ace_editors. Read the comments on that
      # callback block to understand how the code editor swap works.
      # Another point to note. Ideally we could have just put this small js
      # script on every page, and removed the initial page_loaded callback. But
      # that would work to replace the code editors on the first page that loads
      # but it would not work on subsequent pages. So that is why I've added
      # a callback that tells the extension that a pages has loaded, then the
      # extension is aware of every time a new page loads, and the extension
      # starts the process of injecting css and js onto the page and swapping in
      # the code editors.
      def self.inject_ace(dialog)
        # The "A" parameter is a red herring. It does nothing. There is/was a
        # bug that required that I pass in something/anything. So I pass in the
        # A, but it is not used, nor does it mean anything.
        dialog.execute_script(%Q~
          var script = "https://cdn.jsdelivr.net/ace/1.2.3/min/ace.js";
          var el = document.createElement('script');
          var body = document.getElementsByTagName("body")[0]
          body.appendChild(el);
          el.onload = function() {
            sketchup.inject_ace_editors("A");
          };
          el.src = script;
        ~)
      end

    end
  end
end



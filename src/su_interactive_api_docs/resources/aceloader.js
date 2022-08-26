// The purpose of this script is to iterate over the webpage and find all 
// snippets of code and replace those snippets with a code editor and a button
// that will execute the code in SketchUp. This is where the bulk of the work
// to actually replace all the snippets actually occurs.
// Previous to this script running, the extension has injected the ace.js 
// source code, it has added some special css to the page to help format these 
// code editors.

// Create an array of all the html elements of class 'example'. These are the 
// examples that we will replacing with code editors.
var example_elements = document.getElementsByClassName("example code");

// Define some variables for later use
var count = 1;
var e_hash = new Object();

// All the example elements are iterated over one by one. This grabs the 
// example text and then deletes all the elements inside the example element.
// It then replaces the example div with a "editor" div and injects the 
// example text back into that div. This was the cleanest way I could find to
// keep the formatting of the text with indents and line breaks exactly where
// they belong. 
Array.from(example_elements).forEach(function (node) {
  var text = node.innerText;
  while (node.hasChildNodes()) {
    node.removeChild(node.lastChild);
  }
  
  var parent = node.parentNode;
  var new_div = document.createElement('div');
  
  parent.replaceChild(new_div, node);
  new_div.setAttribute("class", "editor");
  new_div.innerHTML = text;
});

// Create a new array of all the editor class elements. This gets iterated on
// in the next chunk of code.
var edit_elements = document.getElementsByClassName("editor");

  
// This now takes all the editor elements and begins the process of creating a
// new code ace editor for each of them. The process of creating a new ace 
// editor is a little involved and require unique ids and names and things. I
// use the count variable to help create unique names and ID's for each separate
// editor box.
Array.from(edit_elements).forEach(function (codeEl) {
    codeEl.setAttribute("id", ("Editor" + count));
    ace.config.set("basePath", "../ace/src-noconflict");
    
    var editor = ace.edit(codeEl);
    e_hash[codeEl.getAttribute("id")] = editor;

    // This wraps the div tag into another div tag, and adds the Execute in 
    // SketchUp button
    var parent = codeEl.parentNode;
    var wrapper = document.createElement('div');
    var form_wrapper = document.createElement('div');
    var form = document.createElement('form');
    var input = document.createElement('input');
    
    parent.replaceChild(wrapper, codeEl);
    wrapper.appendChild(codeEl);
    wrapper.appendChild(form_wrapper);

    // Add the "Execute in SketchUp" button. The onClick calls a js function
    // actually sends the text in the editor to SketchUp. The js function is
    // defined below.
    form_wrapper.appendChild(form);
    form.appendChild(input);
    form_wrapper.setAttribute("class", "editor_button");
    form.setAttribute("id", codeEl.getAttribute("id"));
    input.setAttribute("type", "button");
    input.setAttribute("onclick", "sendToRuby('" + codeEl.getAttribute("id") + "')");
    input.setAttribute("value", "Execute in SketchUp");


    // Set some properties of the code editor box.
    editor.setTheme("ace/theme/textmate");
    editor.getSession().setMode("ace/mode/ruby");
    editor.setHighlightActiveLine(true);
    editor.$blockScrolling = "Infinity";
    editor.setAutoScrollEditorIntoView(true);
    editor.setOption("maxLines", 100);
    editor.setOption("minLines", 3);
    editor.renderer.setScrollMargin(10, 10, 10, 10);
    editor.setOptions({
        fontFamily: "courier",
        fontSize: "12pt",
        readOnly: false
    });
    
    count++;
});



// Add the code that sends the string to execute back to the SketchUp extension 
// to be eval'd.
function sendToRuby(element_id){
    sketchup.htmlDialog_to_ruby(e_hash[element_id].getValue());
};
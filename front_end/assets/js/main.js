var S2S = S2S || {};

S2S.submitForm = function (stylus) {
  $.ajax({
    type: "POST",
    url: '/ajax',
    data: $("#form").serialize(),
    success: function (data) {
      stylus.getDoc().setValue(data);
    },
    error: function () {
      alert("Sorry, we were not able to process your code. \n" +
        "Please create a new issue and copy/paste your code at the provided link to help us fix the issue. \n"+
        "https://github.com/mojotech/sass2stylus/issues/new")
    }
  });
  return false;
};

S2S.readFile = function (sass, stylus, fileSelector) {
    var files = fileSelector.files;
    var file = files[0];
    var reader = new FileReader();

    // If we use onloadend, we need to check the readyState.
    reader.onloadend = function (e) {
      if (e.target.readyState == FileReader.DONE) { // DONE == 2
        sass.getDoc().setValue(e.target.result);
        sass.save();
        S2S.submitForm(stylus);
      }
    };

    var blob = file.slice(0, file.size);
    reader.readAsBinaryString(blob);
}

S2S.selectText = function (element) {
    var doc = document
        , text = doc.getElementById(element)
        , range, selection
    ;
    if (doc.body.createTextRange) { //ms
        range = doc.body.createTextRange();
        range.moveToElementText(text);
        range.select();
    } else if (window.getSelection) { //all others
        selection = window.getSelection();
        range = doc.createRange();
        range.selectNodeContents(text);
        selection.removeAllRanges();
        selection.addRange(range);
    }
}

var sassPlaceholder = "# write your SASS/SCSS here or upload"+
    "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

$(document).ready(function () {

  var copy_btn = new ZeroClipboard( document.getElementById("copy_btn") ),
      request_btn = new ZeroClipboard( document.getElementById("request_btn") ),
      response_btn = new ZeroClipboard( document.getElementById("response_btn") );

  copy_btn.on('noflash', function ( client, args ) {
    document.documentElement.className += "no_flash";
  });

  var sass_editor = CodeMirror.fromTextArea(document.getElementById("codemirror_sass"), {
    lineNumbers: true,
    matchBrackets: true,
    mode: "text/x-scss"
  });
  sass_editor.getDoc().setValue(sassPlaceholder);

  sass_editor.on('focus', function () {
    if( sass_editor.getValue() === sassPlaceholder ) {
      sass_editor.getDoc().setValue("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    }
  });

  var stylus_editor = CodeMirror.fromTextArea(document.getElementById("codemirror_stylus"),{
    lineNumbers: true,
  });
  stylus_editor.getDoc().setValue("# your code will be here!"+
    "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")

  copy_btn.on("dataRequested", function (client, args) {
    client.setText( stylus_editor.getValue() );
  });

  var fileSelector = document.getElementById('file_selector');

  fileSelector.onchange = function () {
    if (this.value !== "") {
      S2S.readFile(sass_editor, stylus_editor, fileSelector);
    }
  };

  $("#upload").click(function (e) {
    e.preventDefault();
    $("#file_selector").click();
  });

  $("#convert").click(function (e) {
    e.preventDefault();
    sass_editor.save();
    S2S.submitForm(stylus_editor);
  });

  $("#download_btn").click(function () {
    stylus_editor.save();
    document.getElementById("download_form").submit()
  });

  $('.api-code-block').click( function(){ S2S.selectText( $(this).attr('id')) });

  sass_editor.on('blur', function () {
    if( sass_editor.getValue().match(/^[\r\n ]+$/) ) {
      sass_editor.getDoc().setValue(sassPlaceholder);
    }
  });

});

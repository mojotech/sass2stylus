var S2S = S2S || {};

S2S.submitForm = function (stylus) {
  $.ajax({
    type: "POST",
    url: '/ajax',
    data: $("#form").serialize(),
    success: function (data) {
      stylus.getDoc().setValue(data);
      S2S.stylusCheck(stylus);
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

S2S.stylusCheck = function (stylus) {
  if(stylus.getValue() != ""){
    $('.conditional').prop("disabled", false).removeClass("inactive");
  }else{
    $('.conditional').prop("disabled", true).addClass("inactive");
  }
}

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
    placeholder: "Paste your sass code \nor drag a file here to convert.",
    theme: "neat",
    mode: "text/x-scss"
  });

  var stylus_editor = CodeMirror.fromTextArea(document.getElementById("codemirror_stylus"),{
    lineNumbers: true,
    placeholder: "Copy the converted code here \nor download the .styl file above.",
  });

  copy_btn.on("dataRequested", function (client, args) {
    client.setText( stylus_editor.getValue() );
  });

  $.scrollIt();

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
    console.log('download');
    stylus_editor.save();
    document.getElementById("download_form").submit()
  });

  stylus_editor.on( 'change', S2S.stylusCheck );

});

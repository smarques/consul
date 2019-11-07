(function() {
  "use strict";
  App.HTMLEditor = {
    initialize: function() {
      $("textarea.html-area").each(function() {
        if ($(this).hasClass("admin")) {
          CKEDITOR.inline(this.name, { language: $("html").attr("lang"), toolbar: "admin", height: 500 });
        } else {
          CKEDITOR.inline(this.name, { language: $("html").attr("lang") });
        }
      });
    }
  };
}).call(this);

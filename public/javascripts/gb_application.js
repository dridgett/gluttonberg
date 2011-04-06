// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {  
	$("#tabs").tabs();   
	
	dragTreeManager.init();
	
	$("#wrapper p#contextualHelp a").click(Help.click);  
	
	//initClickEventsForAssetLinks($("body"));
});



// Help Browser
// Displays the help in an overlayed box. Intended to be used for contextual
// help initially.
var Help = {
  load: function(url) {
    $.get(url, null, function(markup) {Help.show(markup)});
  },
  show: function(markup) {
    this.buildFrames();
    this.frame.html(markup)
    this.frame.find("a#closeHelp").click(this.close);
    var centerFunction = function() {
      Dialog.center(Help.frame, Help.overlay);
      Dialog.resizeDisplay(Help);
    };
    $(window).resize(centerFunction);
    $(document).scroll(centerFunction);
    centerFunction();
  },
  close: function() {
    Help.display = null;
    Help.offsets = null;
    Help.displayPadding = null;
    Help.frame.hide();
    Help.overlay.hide();
    return false;
  },
  click: function(e) {
    Help.load(this.href);
    return false;
  },
  buildFrames: function() {
    if (!this.overlay) {
      this.overlay = $('<div id="overlay">&nbsp</div>');
      $("body").append(this.overlay);
      this.frame = $('<div id="helpDialog">&nbsp</div>');
      $("body").append(this.frame);
    }
    else {
      this.overlay.show();
      this.frame.show();
    }
  }
};
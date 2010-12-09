$(function() {                 
                $("#tabs").tabs();                                
});

// Common utility functions shared between the different dialogs.
var Dialog = {
  center: function() {
    var offset = $(document).scrollTop();
    for (var i=0; i < arguments.length; i++) {
      arguments[i].css({top: offset + "px"});
    };
  },
  PADDING_ATTRS: ["padding-top", "padding-bottom"],
  resizeDisplay: function(object) {
    // Get the display and the offsets if we don't have them
    if (!object.display) object.display = object.frame.find(".display");
    if (!object.offsets) object.offsets = object.frame.find("> *:not(.display)");
    var offsetHeight = 0;
    object.offsets.each(function(i, node) {
      offsetHeight += $(node).outerHeight();
    });
    // Get the padding for the display
    if (!object.displayPadding) {
      object.displayPadding = 0
      for (var i=0; i < this.PADDING_ATTRS.length; i++) {
        object.displayPadding += parseInt(object.display.css(this.PADDING_ATTRS[i]).match(/\d+/)[0]);
      };
    }
    object.display.height(object.frame.innerHeight() - (offsetHeight + object.displayPadding));
  }
};

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

$(document).ready(function() {
  $("#wrapper p#contextualHelp a").click(Help.click);  
});

var AssetBrowser = {
  overlay: null,
  dialog: null,
  load: function(p, link, markup) {
    // Set everthing up
    AssetBrowser.showOverlay();
    $("body").append(markup);
    AssetBrowser.browser = $("#assetsDialog");
    AssetBrowser.target = $("#" + $(link).attr("rel"));
    AssetBrowser.nameDisplay = p.find("strong");
    // Grab the various nodes we need
    AssetBrowser.display = AssetBrowser.browser.find("#assetsDisplay");
    AssetBrowser.offsets = AssetBrowser.browser.find("> *:not(#assetsDisplay)");
    AssetBrowser.backControl = AssetBrowser.browser.find("#back a");
    AssetBrowser.backControl.css({display: "none"});
    // Calculate the offsets
    AssetBrowser.offsetHeight = 0;
    AssetBrowser.offsets.each(function(i, element) {
      AssetBrowser.offsetHeight += $(element).outerHeight();
    });
    // Initialize
    AssetBrowser.resizeDisplay();
    $(window).resize(AssetBrowser.resizeDisplay);
    // Cancel button
    AssetBrowser.browser.find("#cancel").click(AssetBrowser.close);
    // Capture anchor clicks
    AssetBrowser.display.find("a").click(AssetBrowser.click);
    AssetBrowser.backControl.click(AssetBrowser.back);
  },
  resizeDisplay: function() {
    var newHeight = AssetBrowser.browser.innerHeight() - AssetBrowser.offsetHeight;
    AssetBrowser.display.height(newHeight);
  },
  showOverlay: function() {
    if (!AssetBrowser.overlay) {
      var height = $('#wrapper').height() + 50;      
      AssetBrowser.overlay = $('<div id="assetsDialogOverlay" style="height:'+height+'px;">&nbsp</div>');      
      $("body").append(AssetBrowser.overlay);
    }
    else {
      AssetBrowser.overlay.css({display: "block"});
    }
  },
  close: function() {
    AssetBrowser.overlay.css({display: "none"});
    AssetBrowser.browser.remove();
  },
  handleJSON: function(json) {
    if (json.backURL) {
      AssetBrowser.backURL = json.backURL;
      AssetBrowser.backControl.css({display: "block"});
    }
    AssetBrowser.updateDisplay(json.markup);
  },
  updateDisplay: function(markup) {
    AssetBrowser.display.html(markup);
    AssetBrowser.display.find("a").click(AssetBrowser.click);
    $('#tabs').tabs();
  },
  click: function() {
    var target = $(this);
    if (target.is(".assetLink")) {
      var id = target.attr("href").match(/\d+$/);
      AssetBrowser.target.attr("value", id);
      var name = target.find("h2").html();
      AssetBrowser.nameDisplay.html(name);
      AssetBrowser.close();
    }
    else if (target.is("#previous") || target.is("#next")) {
      if (target.attr("href") != '') {
        $.getJSON(target.attr("href") + ".json", null, AssetBrowserEx.handleJSON);
      }
    }
    else {
      $.getJSON(target.attr("href") + ".json", null, AssetBrowser.handleJSON);
    }
    return false;
  },
  back: function() {
    if (AssetBrowser.backURL) {
      $.get(AssetBrowser.backURL, null, AssetBrowser.updateDisplay);
      AssetBrowser.backURL = null;
      AssetBrowser.backControl.css({display: "none"});
    }
    return false;
  }
};

var AssetBrowserEx = {
  overlay: null,
  dialog: null,
  rootPageUrl: null,
  onAssetSelect: null,
  show: function(){
    // display the dialog and do it's stuff
    var self = this;
    $("body").append('<div id="asset_load_point">&nbsp</div>');
   //  $.get(this.root_page_url, null, function(markup){
   $("#asset_load_point").load(this.rootPageUrl + ' #assetsDialog', null, function(){
      //$("body").append(markup);
      self.load();
    });

  },
  load: function(/*p, link, markup */) {
    var self = this;
    // Set everthing up
    this.showOverlay();
    
    this.browser = $("#assetsDialog");

    // Grab the various nodes we need
    this.display = this.browser.find("#assetsDisplay");
    // $("#assetsDialog").dialog({height: 500, width: 500});
    //$('#assetsDialog').jqm({modal: true});
    //$.jqmShow();
    this.offsets = this.browser.find("> *:not(#assetsDisplay)");
    this.backControl = this.browser.find("#back a");
    this.backControl.css({display: "none"});
    // Calculate the offsets
    this.offsetHeight = 0;
    this.offsets.each(function(i, element) {
      self.offsetHeight += $(element).outerHeight();
    });
    // Initialize
    this.resizeDisplay();
    $(window).resize(this.resizeDisplay);
    $(window).scroll(this.resizeDisplay);
    // Cancel button
    this.browser.find("#cancel").click(this.close);
    // Capture anchor clicks
    this.display.find("a").click(this.click);
    this.backControl.click(this.back);
  },
  resizeDisplay: function() {
    var newHeight = AssetBrowserEx.browser.innerHeight() - AssetBrowserEx.offsetHeight;
    AssetBrowserEx.display.height(newHeight);
  },
  getScrollXY: function() {
    var scrOfX = 0, scrOfY = 0;
    if( typeof( window.pageYOffset ) == 'number' ) {
      //Netscape compliant
      scrOfY = window.pageYOffset;
      scrOfX = window.pageXOffset;
    } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
      //DOM compliant
      scrOfY = document.body.scrollTop;
      scrOfX = document.body.scrollLeft;
    } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
      //IE6 standards compliant mode
      scrOfY = document.documentElement.scrollTop;
      scrOfX = document.documentElement.scrollLeft;
    }
    return [ scrOfX, scrOfY ];
  },
  showOverlay: function() {
    if (!AssetBrowserEx.overlay) {
      AssetBrowserEx.overlay = $('<div id="assetsDialogOverlay">&nbsp</div>');
      $("body").append(AssetBrowserEx.overlay);
    }
    else {
      AssetBrowserEx.overlay.css({display: "block"});
    }
  },
  close: function() {
    AssetBrowserEx.overlay.css({display: "none"});
    AssetBrowserEx.browser.remove();
  },
  handleJSON: function(json) {
    if (json.backURL) {
      AssetBrowserEx.backURL = json.backURL;
      AssetBrowserEx.backControl.css({display: "block"});
    }
    AssetBrowserEx.updateDisplay(json.markup);
  },
  updateDisplay: function(markup) {
    AssetBrowserEx.display.html(markup);
    AssetBrowserEx.display.find("a").click(AssetBrowserEx.click);
  },
  click: function() {
    // "this" is the item being clicked!
    var target = $(this);
    if (target.is(".assetLink")) {
      var id = target.attr("href").match(/\d+$/);
      AssetBrowserEx.onAssetSelect(id);
      AssetBrowserEx.close();
    }
    else if (target.is("#previous") || target.is("#next")) {
      if (target.attr("href") != '') {
        $.getJSON(target.attr("href") + ".json", null, AssetBrowserEx.handleJSON);
      }
    }
    else {
      $.getJSON(target.attr("href") + ".json", null, AssetBrowserEx.handleJSON);
    }
    return false;
  },
  back: function() {
    if (AssetBrowserEx.backURL) {
      $.get(AssetBrowserEx.backURL, null, AssetBrowserEx.updateDisplay);
      AssetBrowserEx.backURL = null;
      AssetBrowserEx.backControl.css({display: "none"});
    }
    return false;
  }
};

// Displays the Asset Browser popup. This allows the user to select an asset from the asset library
//   @config.rootUrl = The url to retieve the HTML for rendering the root library page (showing collections and asset types)
//   @config.onSelect = the function to execute when somone clicks an asset
function showAssetBrowser(config){
  AssetBrowserEx.rootPageUrl = config.rootUrl;
  AssetBrowserEx.onAssetSelect = config.onSelect;
  AssetBrowserEx.show();
}

function writeAssetToField(fieldId){
  var field = $("#" + fieldId);
  field.attr("value", id);
}

function writeAssetToAssetCollection(assetId, assetCollectionUrl){
 $.ajax({
   type: "POST",
   url: assetCollectionUrl,
   data: "asset_id=" + assetId,
   success: function(){
     window.location.reload();
   },
   error: function(){
     alert('Adding the Asset failed, sorry.');
     window.location.reload();
   }
 });
}

$(document).ready(function() {
  // Temporary hack called by old Asset Browser code until it is updated to
  // use the new code
  
  
  $("#wrapper .assetBrowserLink").click(function(e) {
    if ($(e.target).is("a[rel='clear-asset']")) {
      var input = $(this).find("input[type=hidden]");
      var strong = $(this).find("strong");
      strong.text("Nothing selected");
      input.val("");
    }
    else {
      var p = $(this);
      var link = p.find("a");
      $.get(link.attr("href"), null, function(markup) {AssetBrowser.load(p, link, markup);});
    }
    e.preventDefault();
  });
  
  
  $("#templateSections").click(function(e) {
    var target = $(e.target);
    if (target.is("a")) {
      // Ewwww, heaps dodgy
      var entry = target.parent().parent().parent();
      if (target.hasClass("plus")) {
        // Set the index on these correctly. Use a regex to find the number in the ID and increment it.
        // Do the same for all the following entries.
        var clonedEntry = entry.clone();
        clonedEntry.find("input").val("");
        clonedEntry.insertAfter(entry);
      }
      else {
        entry.remove();
      }
      return false;
    }
  });

  dragTreeManager.init();
});

function publish(id)
{
  var element = document.getElementById(id);
  element.value = "true";  
}



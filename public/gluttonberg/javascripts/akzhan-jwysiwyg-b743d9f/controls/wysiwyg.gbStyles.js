/**
 * Controls: Element CSS Wrapper plugin
 *
 * Depends on jWYSIWYG
 * 
 * By Yotam Bar-On (https://github.com/tudmotu)
 */

(function ($) {    
  if (undefined === $.wysiwyg) {
    throw "wysiwyg.gbStyles.js depends on $.wysiwyg";
  }
  /* For core enhancements #143
  $.wysiwyg.ui.addControl("gbStyles", {
    visible : false,
    groupIndex: 6,
    tooltip: "Styles",
    exec: function () { 
        $.wysiwyg.controls.gbStyles.init(this);
      }
  }
  */  
  if (!$.wysiwyg.controls) {
    $.wysiwyg.controls = {};
  }

  /*
   * Wysiwyg namespace: public properties and methods
   */
  $.wysiwyg.controls.gbStyles = {
    init: function (Wysiwyg) {
      var self = this, formWrapHtml, key, translation,
      dialogReplacements = {
        legend  : "Wrap Element",
        wrapperType : "Wrapper Type",
        ID : "ID",
        class : "Class",
        wrap  : "Wrap",
        unwrap: "Unwrap",
        cancel   : "Cancel"
      };
      
      var rulesValues = [];
      
      function findCss(stylesheet_name){
        css_index = -1;
        $.each(document.styleSheets , function(index , cssObject){
          if(cssObject.href.search(stylesheet_name) >= 0){
            css_index = index;
            return;
          }
        })
        if(css_index >= 0){
          return document.styleSheets[css_index];
        }

      }

      
      function prepareRulesHtml() {
          css_object = findCss("user-styles.css");
          var rulesHtml = "<ul id='rulesList'>";
          var rules = css_object.rules || css_object.cssRules
          for(var x=0;x<rules.length;x++) {
              var valueforLink = trim(rules[x].selectorText.replace(".wysiwygCssWrapper" , "") );
              rulesValues.push(valueforLink);
              var nameForLink = valueforLink.replace("." , "").replace("#" , "");
              rulesHtml += "<li> <a class='style' href='javascript:;' rel='"+valueforLink+"' > " + nameForLink + " </a> </li>"
          }
          
          rulesHtml += "</ul>";
          return rulesHtml;
        }
      

      formWrapHtml = '<div class="wysiwyg-style-list">' ;
      formWrapHtml += prepareRulesHtml();
      formWrapHtml += '<input type="reset" class="button cssWrap-cancel" value="{cancel}"/></div></fieldset>';
      formWrapHtml += '</div>';

      for (key in dialogReplacements) {
        if ($.wysiwyg.i18n) {
          translation = $.wysiwyg.i18n.t(dialogReplacements[key]);
          if (translation === dialogReplacements[key]) { // if not translated search in dialogs 
            translation = $.wysiwyg.i18n.t(dialogReplacements[key], "dialogs");
          }
          dialogReplacements[key] = translation;
        }
        formWrapHtml = formWrapHtml.replace("{" + key + "}", dialogReplacements[key]);
      }
      if (!$(".wysiwyg-dialog-wrapper").length) {
        $(formWrapHtml).appendTo("body");
        $("div.wysiwyg-style-list").dialog({
          modal: true,
          open: function (ev, ui) {
            $this = $(this);
            var range  = Wysiwyg.getInternalRange(), common;
            //var range  = Wysiwyg.getRange(), common;
            // We make sure that there is some selection:
            if (range) {
              if ($.browser.msie) {
                Wysiwyg.ui.focus();
              }
              common  = $(range.commonAncestorContainer);
            } else {
              alert("You must select some elements before you can style them.");
              $this.dialog("close");
              return 0;
            }
            var $nodeName = range.commonAncestorContainer.nodeName.toLowerCase();
            // If the selection is already a .wysiwygCssWrapper, then we want to change it and not double-wrap it.
            if (common.parent(".wysiwygCssWrapper").length) {
              
              var nodeName = common.parent(".wysiwygCssWrapper").get(0).nodeName.toLowerCase();
              var id = $(common.parent(".wysiwygCssWrapper").get(0)).attr('id');
              var classes = $(common.parent(".wysiwygCssWrapper").get(0)).attr('class');
              
              
              
              if($.inArray(nodeName, rulesValues) > -1 ){
                $("a[rel^="+nodeName+"]").addClass("active");
              }
              else{
                var classesTokens = classes.split(" ");
                $.each(classesTokens , function(index , class_name){
                    if($.inArray("."+class_name, rulesValues)  > -1 ){
                      $("a[rel^=."+class_name+"]").addClass("active");
                    }
                })
                
              }
              $("div.wysiwyg-style-list").find(".cssWrap-unwrap").show();
              $("div.wysiwyg-style-list").find(".cssWrap-unwrap").click(function(e) {
                e.preventDefault();
                if ($nodeName !== "body") {
                  common.unwrap();
                }
                $this.dialog("close");
                return 1;
              });
            }
            // style link.
            $("div.wysiwyg-style-list").find("a.style").click(function(e) {
              e.preventDefault();
              var styleVal = $(this).attr('rel');
              var activeStatus = $(this).is(".active");
              
              var $wrapper = 'span';
              var $id = '';
              var $class =  '';
              
              if(styleVal[0] != '#' && styleVal[0] != '.'){
                $wrapper = styleVal;
              }else if(styleVal[0] == '#' ){
                $id = styleVal.replace("#" , "");
              }else if(styleVal[0] == '.' ){
                $class =  styleVal.replace("." , "");
              }
              
              if( activeStatus){
                common.unwrap();
              }
              else if ($nodeName !== "body") {
                // If the selection is already a .wysiwygCssWrapper, then we want to change it and not double-wrap it.
                if (common.parent(".wysiwygCssWrapper").length) {
                    common.unwrap();
                } //else {
                  common.wrap('<'+$wrapper+' id="'+$id+'" class="'+"wysiwygCssWrapper "+$class+'"/>');
                //}
              } else {
                // Currently no implemntation for if $nodeName == 'body'.
              }
              $this.dialog("close");
            });
            // Cancel button.
            $("div.wysiwyg-style-list").find(".cssWrap-cancel").click(function(e) {
              e.preventDefault();
              $this.dialog("close");
              return 1;
            });
          },
          close: function () {
            $(this).dialog("destroy");
            $(this).remove();
          }
        });
        Wysiwyg.saveContent();
      }
      $(Wysiwyg.editorDoc).trigger("editorRefresh.wysiwyg");
      return 1;
    }
  }
})(jQuery);


function trim(s) {
	s = s.replace(/(^\s*)|(\s*$)/gi,"");
	s = s.replace(/[ ]{2,}/gi," ");
	s = s.replace(/\n /,"\n");
	return s;
}
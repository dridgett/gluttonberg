function enable_tinyMCE_on()
{
	enable_tinyMCE_on_class("mceEditor");
}    


function enable_tinyMCE_on_class(html_class)
{
tinyMCE.init({
                // General options
                //mode : "exact",
                //elements : ids,
                mode : "specific_textareas",
                editor_selector : "" + html_class,
                theme : "advanced",
                plugins : "safari,pagebreak,style,table,advlink,inlinepopups,fullscreen,noneditable,nonbreaking",

                // Theme options
                theme_advanced_buttons1 : "fullscreen,|,removeformat,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,styleselect,|,bullist,numlist,|,blockquote,|,sub,sup,",
                theme_advanced_buttons2 : "undo,redo,|,link,unlink,anchor,|,tablecontrols",
                theme_advanced_buttons3 : "",
                theme_advanced_toolbar_location : "top",
                theme_advanced_toolbar_align : "left",
                theme_advanced_statusbar_location : "bottom",
                theme_advanced_resizing : true,

                content_css : "/stylesheets/user-styles.css",

                valid_elements : "a[href|target=_blank],strong/b,em/i,p,ol,ul,li,u,strike,blockquote"
        });

 }
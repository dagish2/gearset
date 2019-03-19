({
	popupCenterDual : function(url, title, w, h) {
		// Fixes dual-screen position Most browsers Firefox 
            var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : screen.left; 
            var dualScreenTop = window.screenTop != undefined ? window.screenTop : screen.top; 
            var width = screen.width;
            var height = screen.height;
            
            var left = ((width / 2) - (w / 2)) + dualScreenLeft; 
            var top = ((height / 2) - (h / 2)) + dualScreenTop; 
            var newWindow = window.open(url, title, 'scrollbars=yes, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left); 
            
            // Puts focus on the newWindow 
            if (window.focus) { 
                if(newWindow != undefined)
                    newWindow.focus(); 
            } 
	},
    validateReferrer : function(component, recordId, onsuccess, onerror) {
        component.find("utils").execute("c.validateLead", {"recordId": recordId}, function(result){    
            component.find("utils").hideProcessing();
            onsuccess(result);
        }, function(error){
            onerror(error);
        });
    }
})
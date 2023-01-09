({
	doInit: function(component, event, helper) {
		var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message:'This account is not eligible to push to the hold status.',
            key: 'info_alt',
            type: 'warning',
            duration:' 10000',
            mode: 'dismissible'
        });
        
        toastEvent.fire();
    }
})
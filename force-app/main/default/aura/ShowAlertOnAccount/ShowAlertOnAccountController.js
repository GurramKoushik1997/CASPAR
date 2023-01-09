({
	doInit: function(component, event, helper) {
		var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message:'Please also change the clinic name in our Product if this clinic is a customer',
            key: 'info_alt',
            type: 'warning',
            duration:' 10000',
            mode: 'dismissible'
        });
        
        toastEvent.fire();
    }
})
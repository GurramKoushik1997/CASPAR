({
    init : function(component, event, helper) {
        var action = component.get("c.getAccount");
        action.setParams({"accountId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                component.set("v.account", response.getReturnValue());
                
                if(component.get("v.account.Caspar_Id__c") != null) {
                    component.set("v.registered", true);
                } else if(component.get("v.account.Email__c") != null && component.get("v.account.Country_Code__c") != null) {
                    component.set("v.validAccount", true);
                } else {
                    component.set("v.validAccount", false);
                }
            } else {
                component.set("v.messageError", true);
            }
        });
        $A.enqueueAction(action);
    },
    
    submit : function(component, event, helper) {
        var action = component.get("c.submitAccount");
        action.setParams({"theAccount": component.get("v.account")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var responseValue = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if(responseValue == '200') {
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Account successfully created!"
                    });
                    $A.get('e.force:refreshView').fire();
                } else {
                    toastEvent.setParams({
                        "title": "Account could not be created!",
                        "type": "error",
                        "duration": 10000,
                        "message": responseValue
                    });
                }
                toastEvent.fire();
                
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            } else {
                component.set("v.messageError", true);
            }
        });
        $A.enqueueAction(action);
    }
})
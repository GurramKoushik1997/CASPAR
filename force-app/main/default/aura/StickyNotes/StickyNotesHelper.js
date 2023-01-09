({
    getAccountName: function(component, event){
        var action = component.get("c.getAccountName");
        action.setParams({ "acc" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                let resp = response.getReturnValue();
                component.set( 'v.accountName', resp );
            } else if (state === "INCOMPLETE") {
                alert( "Incomplete" );
                component.set('v.isLoaded', false);
            } else if (state === "ERROR") {
                
                var errors = response.getError();
                console.log( errors );
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
                component.set('v.isLoaded', false);
            }
        });
        $A.enqueueAction(action);
        
    },
    getNote: function(component, event) {
        var action = component.get("c.getNotes");
        action.setParams({ "acc" : component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                let resp = response.getReturnValue();
                if(resp.length > 0){
                    component.set( 'v.accountName', resp[0].Account__r.Name );
                }else{
                    component.set('v.isExportToPDF',false);
                    this.getAccountName(component, event);
                }
                component.set( 'v.notes', resp );
            } else if (state === "INCOMPLETE") {
                alert( "Incomplete" );
                component.set('v.isLoaded', false);
            } else if (state === "ERROR") {
                
                var errors = response.getError();
                console.log( errors );
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
                component.set('v.isLoaded', false);
            }
        });
        $A.enqueueAction(action);
    },
    addNote: function(component, event) {
        let notes = component.get("v.notesbody");
        if(notes == null || notes == ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "error",
                "message": "Note should not be Empty",
                "type": "error"
            });
            toastEvent.fire();
        }else if(component.get("v.InternalList").length > 0 && component.get("v.selectedInternalList").length == 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "error",
                "message": "Select Internal Participants",
                "type": "error"
            });
            toastEvent.fire();
        }else if(component.get("v.ExternalList").length > 0 && component.get("v.selectedExternalList").length == 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "error",
                "message": "Select External Participants",
                "type": "error"
            });
            toastEvent.fire();
        }else{
            var action = component.get("c.addNotes");
            action.setParams({ "body" : notes,
                              "acc" : component.get("v.recordId"),
                              "TypeOfMeeting" : component.get("v.selectedOption"),
                              "Internal" : component.get("v.selectedInternalList").toString(),
                              "External" : component.get("v.selectedExternalList").toString(),
                              "Other" : component.get("v.otherParticipants"),
                              "MeetingDT" : component.get("v.MeetingDT"),
                              "Tasks" : component.get("v.TaskComment"),
                              "TaskDueDate" : component.get("v.DueDT")
                             });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    let resp = response.getReturnValue();
                    let noteBody = [];                    
                    component.set( 'v.notes', resp );
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Note is added successfully!",
                        "type": "success"
                    });
                    toastEvent.fire();
                    component.set("v.notesbody",'');
                    component.set("v.selectedExternalList",'Type of Meeting');
                    component.set("v.selectedInternalList",'');
                    component.set("v.selectedExternalList",'');
                    component.set("v.otherParticipants",'');
                    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    component.set("v.MeetingDT", today);
                    component.set("v.DueDT", today);
                } else if (state === "INCOMPLETE") {
                    alert( "Incomplete" );
                    component.set('v.isLoaded', false);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log( errors );
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " + 
                                  errors[0].message);
                        }
                    } else {
                        alert("Unknown error");
                    }
                    component.set('v.isLoaded', false);
                }
            });
            $A.enqueueAction(action);
            
            this.getUserName(component, event);
            this.getPicklistValues(component, event);
            this.createTask(component, event);
        }
    },
    getPicklistValues: function(component, event) {
        var action = component.get("c.getTypeOfMeetingValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.options", fieldMap);
                component.set("v.selectedOption", fieldMap[0].value);
            }
        });
        $A.enqueueAction(action);
    },
    cancelNote: function(component, event, noteToDelete) {
        var action = component.get("c.deleteNote");
        action.setParams({ "noteId" : noteToDelete,
                          "acc" : component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set( 'v.notes', response.getReturnValue() );
            } else if (state === "INCOMPLETE") {
                alert( "Incomplete" );
                component.set('v.isLoaded', false);
            } else if (state === "ERROR") {
                
                var errors = response.getError();
                console.log( errors );
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
                component.set('v.isLoaded', false);
            }
        });
        
        $A.enqueueAction(action);
    },
    getUserName:function(component, event) {
        var action = component.get("c.getUserName");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.currentUserName", result);
                this.getParticipants(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    getParticipants: function(component, event) {
        var action = component.get("c.getParticipantsValues");
        action.setParams({"acc" : component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var plValues = [];
                for (var i = 0; i < result.length; i++) {
                    plValues.push({
                        label: result[i],
                        value: result[i]
                    });
                }
                plValues.push({label: 'Other',value: 'Other'});
                component.set("v.ExternalList", plValues);
            }
        });
        $A.enqueueAction(action);
        var action1 = component.get("c.getactiveUsers");        
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var plValues = [];
                var plSelected = [];
                for (var i = 0; i < result.length; i++) {
                    plValues.push({
                        label: result[i],
                        value: result[i]
                    });
                    if(result[i] == component.get("v.currentUserName")){
                        plSelected.push(result[i]);
                    }
                }
                component.set("v.InternalList", plValues);
                component.set("v.selectedInternalList", plSelected);
            }else if (state === "INCOMPLETE") {
                alert( "Incomplete" );
                component.set('v.isLoaded', false);
            } else if (state === "ERROR") {
                
                var errors = response.getError();
                console.log( errors );
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
                component.set('v.isLoaded', false);
            }
        });
        $A.enqueueAction(action1);
    },
    createTask: function(component, event) {
        if(component.get("v.TaskComment") != '' && component.get("v.TaskComment") != null){
            component.set('v.isLoaded', true);
            var action = component.get("c.createTask");
            action.setParams({"accId" : component.get("v.recordId"),
                              "comment" : component.get("v.TaskComment"),
                              "dueDate" : component.get("v.DueDT"),
                              "MeetingDate" : component.get("v.MeetingDT")
                             });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    component.set("v.MeetingDT", today);
                    component.set("v.TaskComment", '');
                    component.set('v.showNextSteps', false);
                    component.set("v.tab", 'one');
                }else if (state === "INCOMPLETE") {
                    alert( "Incomplete" );
                    component.set('v.isLoaded', false);
                } else if (state === "ERROR") {
                    
                    var errors = response.getError();
                    console.log( errors );
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " + 
                                  errors[0].message);
                        }
                    } else {
                        alert("Unknown error");
                    }
                    component.set('v.isLoaded', false);
                }
            });
            $A.enqueueAction(action);
        }
    }
})
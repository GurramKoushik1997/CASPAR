({
    doInit: function(component, event, helper) {
        helper.getNote(component, event);
        helper.getPicklistValues(component, event);
        helper.getUserName(component, event);
        component.set("v.tab", 'one');
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set("v.MeetingDT", today);
        component.set("v.DueDT", today);
    },
    addNote: function(component, event, helper) {
        if(component.get("v.selectedOption") != ''){
            helper.addNote(component, event);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "error",
                "message": "Please select Type of Meeting",
                "type": "error"
            });
            toastEvent.fire();
        }
    },
    handleEdit: function(component, event, helper) {
        var allNotes = component.get("v.notes");
        var notes = [];
        var item = component.get("v.notes")[event.getSource().get("v.value")];
        for (const element of allNotes) {
            if(item.Id === element.Id ){
                element.isEdit__c = true;
            }
            notes.push(element);
        }
        component.set("v.notes",notes);   
    },
    handleSave: function(component, event, helper) {
        var item = component.get("v.notes")[event.getSource().get("v.value")];        
        var action = component.get("c.updateNote");
        action.setParams({ "noteId" : item.Id,
                          "body" : item.Body__c,
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
    handleCancel: function(component, event, helper) {
        let notes = component.get("v.notes");
        helper.cancelNote(component, event, notes[event.getSource().get("v.value")].Id);
    },
    fileUploadModal: function(component, event) {
        component.set("v.isFileModalOpen", true);
        let noteId = component.get("v.notes")[event.getSource().get("v.value")].Id;
        component.set("v.tempNoteId", noteId);
        component.set("v.accId",component.get("v.notes")[event.getSource().get("v.value")].Account__c);
    },
    closeFileModal: function(component, event,helper) {
        component.set("v.isFileModalOpen", false);
        helper.getNote(component, event)
    },
    handleUploadFinished: function(component, event, helper) {
        component.set("v.isFileModalOpen", false);
        component.set("v.tab", 'two');        
        var uploadedFiles = event.getParam("files");
        let attach = [];
        uploadedFiles.forEach(file => {
            attach.push( file );
        });
            var action = component.get("c.updateFileName");
            action.setParams({ "docId" : attach[0].documentId,
            "noteId" : component.get("v.tempNoteId"),
            "acc" : component.get("v.recordId"),});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set( 'v.notes', response.getReturnValue() );
                component.set("v.tempNoteId", '');
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
    addParticipents: function(component, event, helper){
        component.set('v.showParticipants', true);
        component.set("v.tab", 'three');        
    },
    nextSteps: function(component, event, helper){
        component.set('v.showNextSteps', true);
        component.set("v.tab", 'four');        
    },
    closeParticipents: function(component, event, helper){
        component.set('v.showParticipants', false);
        component.set("v.tab", 'one');
    },
    closeNextSteps : function(component, event, helper){
        component.set('v.showNextSteps', false);
        component.set("v.tab", 'one');
        component.set("v.TaskComment", '');
    },
    handleInternalChange: function (component, event, helper) {
        var selectedValues = event.getParam("value");
        component.set("v.selectedInternalList", selectedValues);
    },
    handleExternalChange: function (component, event, helper) {
        var selectedValues = event.getParam("value");
        if(selectedValues.includes('Other')){
            component.set("v.isExternalOther", true);
        }else{
            component.set("v.isExternalOther", false);
        }
        component.set("v.selectedExternalList", selectedValues);
    },
    AllParticipents: function(component, event, helper){
        let isInternal = true;
        let isExternal = true;
        if(component.get("v.InternalList").length > 0 && component.get("v.selectedInternalList").length == 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "error",
                "message": "Please select Internal Participants",
                "type": "error"
            });
            toastEvent.fire();
            isInternal = false;
        }else if(component.get("v.ExternalList").length > 0 && component.get("v.selectedExternalList").length == 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "error",
                "message": "Please select External Participants",
                "type": "error"
            });
            toastEvent.fire();
            isExternal = false;
        }else if(component.get("v.selectedExternalList").length > 0 ){
            let SelectedExternalList = component.get("v.selectedExternalList");
            let OtherSelected = false;
            for(var e of SelectedExternalList){
                if(e == 'Other'){
                    OtherSelected = true;
                }
            }
            if(OtherSelected && component.get("v.otherParticipants") == ''){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "error",
                    "message": "Enter Other Participants",
                    "type": "error"
                });
                toastEvent.fire();
                isExternal = false;
            }
        }
        if(isInternal && isExternal){
            component.set('v.showParticipants', false);
            component.set("v.tab", 'one');
        }
    },
    SaveNextSteps: function(component, event, helper){
        //helper.createTask(component, event);
        component.set('v.showNextSteps', false);
        component.set("v.tab", 'one');
    },
    exportoPDF: function(component, event, helper){
        component.set("v.isSelectNotes", true);
    },
    closeSelectModal:function(component, event, helper){
        component.set("v.isSelectNotes", false);
    },
    handleSelectedContacts: function(component, event, helper) {
        var selectedContacts = [];
        var checkvalue = component.find("checkNote");
        
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedContacts.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedContacts.push(checkvalue[i].get("v.text"));
                }
            }
        }
        if(selectedContacts.length > 0){
            component.set("v.isSelectNotes", false);
            let url = '/apex/Caspar_Meetings?id='+component.get("v.recordId")+'&QNIds='+selectedContacts.toString();
            var checkall = component.find("selectAll");
            checkall.set("v.value",false);
            window.open(url);
        }else{
            alert( "Please select atleast one" );
        }        
    },
    handleSelectAllContact: function(component, event, helper) {
        var getID = component.get("v.NotesList");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkNote = component.find("checkNote"); 
        if(checkvalue == true){
            for(var i=0; i<checkNote.length; i++){
                checkNote[i].set("v.value",true);
            }
        }
        else{
            for(var i=0; i<checkNote.length; i++){
                checkNote[i].set("v.value",false);
            }
        }
    },
})
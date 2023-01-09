public class QuickNotesController {
    
    @AuraEnabled
    public static String getUserName() {
        return userinfo.getName();
    }
    
    @AuraEnabled
    public static String getAccountName(String acc) {
        try {
            return [SELECT Id, Name FROM Account WHERE Id =:acc LIMIT 1].Name;
            
        } catch (Exception e) { return null; }
    }
    @AuraEnabled
    public static List<Quick_Note__c> getNotes(String acc) {
        try {
            return [SELECT Id, Name, Body__c, Account__c, Account__r.Name, Type_of_Meeting__c, Internal_Participants__c, External_Participants__c, Other_Participants__c, Due_Date__c  FROM Quick_Note__c WHERE Account__c =:acc ORDER BY CreatedDate DESC LIMIT 100];
            
        } catch (Exception e) { return null; }
    }
    
    @AuraEnabled
    public static List<Quick_Note__c> addNotes(String body, String acc, String TypeOfMeeting, String Internal, String External, String Other, String MeetingDT, String Tasks, String TaskDueDate) {
        String meetDate = '';
        if(MeetingDT != null && MeetingDT != ''){
            //getting date format 2023-01-02 chnaging to 02.01.2023
            List<String> lstMeetingDT = MeetingDT.split('-');
            meetDate = lstMeetingDT[2]+'.'+lstMeetingDT[1]+'.'+lstMeetingDT[0];
        }
        try {
            Quick_Note__c qNote = new Quick_Note__c();
            qNote.Name = (meetDate != null && meetDate != ''? meetDate+'-'+UserInfo.getName() :'' + System.now()+'-'+UserInfo.getName());
            qNote.Body__c = body;
            qNote.isEdit__c = false;
            qNote.Account__c = acc;
            qNote.Type_of_Meeting__c = TypeOfMeeting;
            qNote.Internal_Participants__c = Internal;
            qNote.External_Participants__c = External;
            qNote.Other_Participants__c = Other;
            qnote.Due_Date__c = Date.valueof(MeetingDT);
            qnote.Tasks__c = Tasks;
            qnote.Task_Due_Date__c = Date.valueof(TaskDueDate);
            insert qNote;
        } catch (Exception e) {}
        return getNotes(acc);
    }
    
    @AuraEnabled
    public static List<Quick_Note__c> updateNote(String noteId,String body,String acc) {
        try {
            Quick_Note__c qn = [SELECT Id,Name, Body__c, isEdit__c FROM Quick_Note__c WHERE Id = :noteId];
            qn.isEdit__c = false;
            qn.Body__c = body;
            update qn;
        } catch (Exception e) {}
        
        return getNotes(acc);
    }
    
    @AuraEnabled
    public static List<Quick_Note__c> deleteNote(String noteId,String acc) {
        try {
            delete [SELECT Id FROM Quick_Note__c WHERE Id = :noteId];
        } catch (Exception e) {}
        
        return getNotes(acc);
    }
    
    @AuraEnabled
    public static List<Quick_Note__c> updateFileName(String docId,String noteId,String acc) {
        try {
            ContentDocument cd = [SELECT Id,Title FROM ContentDocument WHERE Id=:docId LIMIT 1];
            Quick_Note__c qn = [SELECT Id,Name FROM Quick_Note__c WHERE Id = :noteId LIMIT 1];
            cd.Title = 'Caspar Meeting-'+qn.Name;
            Update cd;
        } catch (Exception e) {}
        
        return getNotes(acc);
    }
    
    @AuraEnabled 
    public static Map<String, String> getTypeOfMeetingValue(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Quick_Note__c.Type_of_Meeting__c .getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List <String> getParticipantsValues(String acc) {
        List<String> plValues = new List<String>();
        
        List<Contact> accountContacts = [SELECT Id,Name FROM Contact WHERE AccountId = :acc];
        for( Contact cName: accountContacts) {
            plValues.add(cName.Name);
        }
        plValues.sort();
        return plValues;
    }
    
    @AuraEnabled
    public static List<String> getactiveUsers() {
        List<String> allUsers = new List<String>();
        List<User> activeUsers = [SELECT Id,Name FROM User WHERE IsActive=:true];
        for( User u: activeUsers) {
            allUsers.add(u.Name);
        }
        allUsers.sort();
        return allUsers;
    }
    @AuraEnabled
    public static void createTask(String accId, String comment, String dueDate, String MeetingDate) {
        String meetDate = '';
        if(MeetingDate != null && MeetingDate != ''){
            //getting date format 2023-01-02 chnaging to 02.01.2023
            List<String> lstMeetingDate = MeetingDate.split('-');
            meetDate = lstMeetingDate[2]+'.'+lstMeetingDate[1]+'.'+lstMeetingDate[0];
        }
        List<String> lstComments = new List<String>();
        List<Task> lstTasks = new List<Task>();
        if(comment != null && comment != ''){
            lstComments = comment.split(',');
        }
        if(lstComments.size() > 1){
            for(String newtask : lstComments){
                Task t = new Task();
                t.WhatId = accId;
                t.Priority = 'Normal';
                t.Status = 'Open';
                t.Subject = newtask.stripHtmlTags().length() > 255 ? 'Meeting-'+meetDate+': '+newtask.stripHtmlTags().substring(0,120)+'....' : 'Meeting-'+meetDate+': '+newtask.stripHtmlTags();
                t.Description = newtask.stripHtmlTags();
                t.ActivityDate = Date.valueOf(dueDate);
                lstTasks.add(t);
            }
            try{
                if(lstTasks.size() > 0){
                    insert lstTasks;
                }
                CustomNotificationType Notification = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'New_Task_is_created_for_you' LIMIT 1];
                for(Task t : lstTasks){
                    Messaging.CustomNotification singleNotification = new Messaging.CustomNotification();
                    singleNotification.setTitle(t.Subject);
                    singleNotification.setBody('Please Review');
                    singleNotification.setNotificationTypeId(Notification.Id);
                    singleNotification.setTargetId(t.Id);
                    set<String> setUser = new set<String>{UserInfo.getUserId()};
                        singleNotification.send(setUser); 
                }
            }catch(Exception e){
                System.debug('e->'+e);
            }
        }else{
            try {
                Task t = new Task();
                t.WhatId = accId;
                t.Priority = 'Normal';
                t.Status = 'Open';
                t.Subject = comment.stripHtmlTags().length() > 255 ? 'Meeting-'+meetDate+': '+comment.stripHtmlTags().substring(0,120)+'....' : 'Meeting-'+meetDate+': '+comment.stripHtmlTags();
                t.Description = comment.stripHtmlTags();
                t.ActivityDate = Date.valueOf(dueDate);
                insert t;
                CustomNotificationType Notification = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'New_Task_is_created_for_you' LIMIT 1];
                Messaging.CustomNotification singleNotification = new Messaging.CustomNotification();
                singleNotification.setTitle(t.Subject);
                singleNotification.setBody('Please Review');
                singleNotification.setNotificationTypeId(Notification.Id);
                singleNotification.setTargetId(t.Id);
                set<String> setUser = new set<String>{UserInfo.getUserId()};
                    singleNotification.send(setUser);            
            } catch(Exception e){
                System.debug('e->'+e);
            }
        }
    }
}
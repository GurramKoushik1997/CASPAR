public class QuickNotesPdfController {
    public List<Quick_Note__c> quickNotesRecords {get;set;}
    //public String QNIds {get;set;}
    public QuickNotesPdfController(ApexPages.StandardController controller) {
        quickNotesRecords = new List<Quick_Note__c>();
        String AccountId = ApexPages.CurrentPage().getparameters().get('id');
        String QNrecIds = ApexPages.CurrentPage().getparameters().get('QNIds');
        if(QNrecIds != null && QNrecIds != ''){
            List<String> QNIdList = QNrecIds.split(',');
            quickNotesRecords.addAll([SELECT Id, Name, Body__c, Account__c, Account__r.Name, Type_of_Meeting__c, Internal_Participants__c, External_Participants__c, Other_Participants__c, Tasks__c, Task_Due_Date__c  FROM Quick_Note__c WHERE Account__c =:AccountId AND Id IN : QNIdList ORDER BY CreatedDate DESC LIMIT 100]);
        }else{
            quickNotesRecords.addAll([SELECT Id, Name, Body__c, Account__c, Account__r.Name, Type_of_Meeting__c, Internal_Participants__c, External_Participants__c, Other_Participants__c, Tasks__c, Task_Due_Date__c  FROM Quick_Note__c WHERE Account__c =:AccountId ORDER BY CreatedDate DESC LIMIT 100]);
        }
    }    
}
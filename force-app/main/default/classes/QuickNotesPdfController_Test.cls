@isTest
public class QuickNotesPdfController_Test {
    
    @testsetup static void Testdata(){
        
        Account a = new Account();
        a.Name = 'test';
        a.Account_Hold__c = true;
        a.Account_lost__c = false;
        a.Aftercare_Patients__c = true;
        a.Arge__c = true;
        a.Caspar_Clinic_Betreuung__c = true;
        a.cirrusadv__Created_by_Cirrus_Insight__c = true;
        a.Is_active__c = true;
        a.Is_deactivated__c = false;
        a.Qualified_Lead__c = false;
        a.Rabattstaffelung__c = false;
        a.rztl_Abschlussgespr_ch__c = true;
        a.ShowProductNameChangeAlert__c = true;
        a.USt__c = false;
        a.White_Label__c = false;
        a.Country_Code__c = 'DE';
        insert a;
        
        Quick_Note__c qn = new Quick_Note__c();
        qn.Account__c = a.Id;
        qn.Other_Participants__c = 'o1,o2';
        qn.Name = '' + System.now()+'-'+UserInfo.getName();
        qn.Body__c = 'test body';
        qn.isEdit__c=false;
        qn.Type_of_Meeting__c = 'Jour fixe';
        qn.Internal_Participants__c = 'Internal';
        qn.External_Participants__c = 'External';
        insert qn;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'Test',
            PathOnClient   = 'Test.txt',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = a.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }
    
    @isTest
    public static void testMethod1(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Quick_Note__c qn = [SELECT Id FROM Quick_Note__c LIMIT 1];
        ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        
        Test.startTest();
        QuickNotesController.getAccountName(acc.Id);
        QuickNotesController.getNotes(acc.Id);
        QuickNotesController.addNotes('body',acc.Id,'Jour fixe','Internal','External','Other1,Other2','2023-01-02','Task','2023-01-02');
        QuickNotesController.updateNote(qn.Id,'body',acc.Id);
        QuickNotesController.getTypeOfMeetingValue();
        QuickNotesController.getactiveUsers();
        QuickNotesController.getParticipantsValues(acc.Id);
        QuickNotesController.updateFileName(document.Id,qn.Id,acc.Id);
        QuickNotesController.createTask(acc.Id,'Test task comment','2023-01-02','2023-01-02');
        QuickNotesController.getUserName();
        
        
        PageReference testPage = Page.Caspar_Meetings; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(acc.Id));
        testPage.getParameters().put('QNIds', String.valueOf(qn.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(acc);     
        QuickNotesPdfController ext = new QuickNotesPdfController(sc);         
        
        QuickNotesController.deleteNote(qn.Id,acc.Id);
        Test.stopTest();
    }
    @isTest
    public static void testMethod2(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Quick_Note__c qn = [SELECT Id FROM Quick_Note__c LIMIT 1];
        Test.startTest();
        QuickNotesController.createTask(acc.Id,'Test task comment1,Test task comment2,Test task comment3','2023-01-02','2023-01-02');
        PageReference testPage = Page.Caspar_Meetings; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(acc.Id));
        testPage.getParameters().put('QNIds', '');
        ApexPages.StandardController sc = new  ApexPages.StandardController(acc);     
        QuickNotesPdfController ext = new QuickNotesPdfController(sc);         
        QuickNotesController.deleteNote(qn.Id,acc.Id);
        Test.stopTest();
    }
}
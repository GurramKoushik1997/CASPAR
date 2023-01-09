/*********************************************
 * Test class for Service_SyncPatientTherapistOnTask
 * *******************************************/
@isTest
private class Service_SyncPatientTherapistOnTask_Test {
	@testSetup static void setupData(){   	
        
        List<Medical_Concept__c> mclist = new List<Medical_Concept__c>();
        Medical_Concept__c mc1 = new Medical_Concept__c(Name = 'Prävention');
        mclist.add(mc1);
        
        Medical_Concept__c mc2 = new Medical_Concept__c(Name = 'digIRENA');
        mclist.add(mc2);
        insert mclist;
        
        List<Automatic_Task__c > tasklist = new List<Automatic_Task__c>();
        Automatic_Task__c task1 = new Automatic_Task__c(Days__c = 1,Subject__c = 'Task 1', due_date_type__c = 'Days',
                                                        Medizinisches_Konzept__c = mclist[0].Id);
        tasklist.add(task1);
        Automatic_Task__c task2 = new Automatic_Task__c(Days__c = 10,Subject__c = 'Task 2', due_date_type__c = 'Days',
                                                        Medizinisches_Konzept__c = mclist[0].Id);
        tasklist.add(task2);
        Automatic_Task__c task3 = new Automatic_Task__c(Days__c = 10,Subject__c = 'Task 1', due_date_type__c = 'Months',
                                                        Medizinisches_Konzept__c = mclist[1].Id);
        tasklist.add(task3);
        insert tasklist;     
        
        Account acc = new Account(Name = 'Test Account 1',Country_Code__c = 'DE');
        insert acc;
        Patient__c p1 = new Patient__c(Name = '2331',Account__c = acc.Id,Geschlecht__c = 'männlich', 
                                       Medizinisches_Konzept__c = 'Prävention', 
                                       Startdatum__c = Date.today(),
                                      Therapist__c = 'Sabrina Rohde');
        Patient__c p2 = new Patient__c(Name = '2332',Account__c = acc.Id,Geschlecht__c = 'männlich', 
                                       Medizinisches_Konzept__c = 'digIRENA', Startdatum__c = Date.today(),
                                      Therapist__c = 'Sabrina Rohde');
        
        List<Patient__c> patientist = new List<Patient__c>{p1,p2};
        insert patientist;
    }
    @isTest static void syncTherapist_Test() {
        Patient__c p1 = [Select id,Therapist__c From Patient__c WHERE Name = '2331' limit 1];
        p1.Therapist__c = 'Britta Krisch';
        update p1;
        List<Task> tasklist = [Select id From Task Where whatId =: p1.Id AND Automatic_Task__c = true AND Therapist__c = 'Britta Krisch'];
        System.assert(tasklist.size() > 0, tasklist);
    }
}
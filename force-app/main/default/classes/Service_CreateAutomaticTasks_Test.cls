/*********************************************
 * Test class for Service_CreateAutomaticTasks
 * *******************************************/
@isTest
private class Service_CreateAutomaticTasks_Test {
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
    
    @isTest static void createTasks_Test() {
		Patient__c p1 = [Select id,Medizinisches_Konzept__c From Patient__c WHERE Name = '2331' limit 1];        
        p1.Medizinisches_Konzept__c = 'digIRENA';
        update p1;
        
        List<Task> tasklist = [Select id From Task Where WhatId =: p1.Id AND Automatic_Task__c = TRUE];
        System.assertEquals(1, tasklist.size());
    }
    @isTest static void createTasks_Test2() {
		Patient__c p1 = [Select id,Medizinisches_Konzept__c From Patient__c WHERE Name = '2332' limit 1];        
        p1.Medizinisches_Konzept__c = 'Prävention';
        update p1;
        
        List<Task> tasklist = [Select id From Task Where WhatId =: p1.Id AND Automatic_Task__c = TRUE];
        System.assertEquals(2, tasklist.size());
    }
    
    @isTest static void createTasks_Test3() {
		Patient__c p1 = [Select id,Medizinisches_Konzept__c From Patient__c WHERE Name = '2332' limit 1];         
        p1.Medizinisches_Konzept__c = 'hybride IRENA';
        update p1;
        
        List<Task> tasklist = [Select id From Task Where WhatId =: p1.Id AND Automatic_Task__c = TRUE];
        System.assertEquals(0, tasklist.size());
    }
}
@isTest
private class PatientAfterInsert_TEST {

    private static Account acc1,acc2;
    private static List<Patient__c> pat1,pat2;
    private static Nachsorgequote__c nsq1,nsq2;
    
    private static testMethod void init() {
        acc1 = new Account(
        	Name = 'Account 1',
            Country_Code__c = 'DE'
        );
        insert acc1;
        
        acc2 = new Account(
        	Name = 'Account 2',
            Country_Code__c = 'DE'
        );
        insert acc2;
        
        nsq1 = new Nachsorgequote__c(
        	Account__c = acc1.Id,
            Anzahl_TRN_Patienten__c = 10,
            Jahr__c = String.valueOf(Date.today().year()),
            Monat__c = mMonthName.get(Date.today().month())
        );
        insert nsq1;
        
        nsq2 = new Nachsorgequote__c(
        	Account__c = acc1.Id,
            Anzahl_TRN_Patienten__c = 5,
            Jahr__c = String.valueOf(Date.today().year()-1),
            Monat__c = mMonthName.get(Date.today().month())
        );
        insert nsq2;
        
        Patient__c p1 = new Patient__c(
        	Name = '1',
            Account__c = acc1.Id,
            Status__c = 'Aktiv',
            Startdatum__c = Date.today()
        );
        
        Patient__c p2 = new Patient__c(
        	Name = '2',
            Account__c = acc1.Id,
            Status__c = 'Aktiv',
            Startdatum__c = Date.today()
        );
        
        pat1 = new List<Patient__c>();
        pat1.add(p1);
        pat1.add(p2);
        
        Patient__c p3 = new Patient__c(
        	Name = '1',
            Account__c = acc2.Id,
            Status__c = 'Aktiv',
            Startdatum__c = Date.today()
        );
        
        Patient__c p4 = new Patient__c(
        	Name = '2',
            Account__c = acc2.Id,
            Status__c = 'Aktiv',
            Startdatum__c = Date.today()
        );
        
        pat2 = new List<Patient__c>();
        pat2.add(p3);
        pat2.add(p4);
    }
    
    private static testMethod void theTest() {
        init();
        
        test.startTest();
        
        insert pat1;
        insert pat2;
        
        test.stopTest();
        
        Nachsorgequote__c newNsq1 = [
            SELECT Id, Anzahl_TRN_Patienten__c
            FROM Nachsorgequote__c
            WHERE Id = :nsq1.Id
        ];
        System.assertEquals(12, newNsq1.Anzahl_TRN_Patienten__c);
        
        Nachsorgequote__c newNsq2 = [
            SELECT Id, Anzahl_TRN_Patienten__c
            FROM Nachsorgequote__c
            WHERE Account__c = :acc2.Id
        ];
        System.assertEquals(2, newNsq2.Anzahl_TRN_Patienten__c);
    }
    
    private static Map<Integer,String> mMonthName = new Map<Integer,String>{
        1 => 'Januar',
            2 => 'Februar',
            3 => 'März',
            4 => 'April',
            5 => 'Mai',
            6 => 'Juni',
            7 => 'Juli',
            8 => 'August',
            9 => 'September',
            10 => 'Oktober',
            11 => 'November',
            12 => 'Dezember'
     };
    
}
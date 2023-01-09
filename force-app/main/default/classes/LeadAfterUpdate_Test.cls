@isTest
public class LeadAfterUpdate_Test {
 private static List<Lead> lLead;
    private static Account mergeAcc;
    private static List<Contact> lMergeCon;
    
    public static void init() {
        lLead = new List<Lead>();
        for(Integer i = 0; i < 8; i++) {
            Lead tmpLead = new Lead(Status = 'Called', LastName = 'LeadCon'+i, Company = 'LeadAcc', Gender__c = 'Male', Department__c = 'Administration');
            lLead.add(tmpLead);
        }
        //Merge Contact Per Email
        lLead[0].Email = 'test@test-firma.de';
        lLead[0].Fax = '01234';
        lLead[0].Website = 'http://test-firma.de';
        
        lLead[1].Email = 'test@test-firma.com';
        lLead[1].Fax = '56789';
        lLead[1].Industry = 'Bekleidung';
        
        // Merge Contact Per Phone
        lLead[2].Phone = '00001';
        lLead[2].Fax = '01234';
        lLead[2].Website = 'http://test-firma.de';
        
        lLead[3].Phone = '00002';
        lLead[3].Fax = '56789';
        lLead[3].Industry = 'Bekleidung';
        
        // Merge Account per domain
        lLead[4].Email = 'firma@test-firma.de';
        lLead[4].Website = 'http://test-firma.de';
        
        lLead[5].Email = 'firma@test-firma.com';
        lLead[5].Industry = 'Bekleidung';
        
        // Merger Account per phone 
        lLead[6].Phone = '00003';
        lLead[6].Website = 'http://test-firma.de';
        
        // No Merging
        lLead[7].Email = 'test@company.com';
        insert lLead;
        
        mergeAcc = new Account(Name = 'MergeAcc');
        mergeAcc.Phone = '00003';
        insert mergeAcc;
        
        lMergeCon = new List<Contact>();
        for(Integer i = 0; i < 2; i++) {
            Contact tmpCon = new Contact(LastName = 'MergeCon'+i, Gender__c = 'Male', Department__c = 'Administration');
            tmpCon.AccountId = mergeAcc.Id;
            lMergeCon.add(tmpCon);
        }
        lMergeCon[0].Email = 'test@test-firma.de';
        lMergeCon[0].Phone = '00001';
        lMergeCon[1].Email = 'test@test-firma.com';
        lMergeCon[1].Phone = '00002';
        
        insert lMergeCon;   
    }
    
    public static TestMethod void testLeadWithMerging() {
        init();
        System.assert([SELECT Id FROM Account].size() == 1);
        System.assert([SELECT Id FROM Contact].size() == lMergeCon.size());
        
        lLead[0].Status = 'Prospect';
        lLead[1].Status = 'Prospect';
        List<Lead> tmpLeadList = new List<Lead>();
        tmpLeadList.add(lLead[0]);
        tmpLeadList.add(lLead[1]);
        update tmpLeadList;
        
        // Check if no new Account or Contact has been added, since the Leads should merge with existing Objects
        List<Account> lAcc = [SELECT Id, Name, Website, Industry FROM Account];
        List<Contact> lCon0 = [SELECT Id, LastName, Gender__c, EMail, Fax FROM Contact WHERE Id = :lMergeCon[0].Id];
        List<Contact> lCon1 = [SELECT Id, LastName, Gender__c, EMail, Fax FROM Contact WHERE Id = :lMergeCon[1].Id];
        System.assert([SELECT Id FROM Account].size() == 1);
        System.assert([SELECT Id FROM Contact].size() == lMergeCon.size());
       
        // Check if Merge hasn't overwritten data from exising mergeCon and mergeAcc
        System.assert(lAcc[0].Name == 'MergeAcc');
        System.assert(lCon0[0].Gender__c == 'Male');
        System.assert(lCon1[0].Gender__c == 'Male');
        
        // Check if Merge has added data to existing mergeCon and mergeAcc
        System.assert(lAcc[0].Website == 'http://test-firma.de');
        System.assert(lAcc[0].Industry == 'Bekleidung');
        System.assert(lCon0[0].Fax == '01234');
        System.assert(lCon1[0].Fax == '56789');  
    }
    
    public static TestMethod void testLeadWithMergingPhone() {
        init();
        System.assert([SELECT Id FROM Account].size() == 1);
        System.assert([SELECT Id FROM Contact].size() == lMergeCon.size());
        
        lLead[2].Status = 'Prospect';
        lLead[3].Status = 'Prospect';
        List<Lead> tmpLeadList = new List<Lead>();
        tmpLeadList.add(lLead[2]);
        tmpLeadList.add(lLead[3]);
        update tmpLeadList;
        
        // Check if no new Account or Contact has been added, since the Leads should merge with existing Objects
        List<Account> lAcc = [SELECT Id, Name, Website, Industry FROM Account];
        List<Contact> lCon0 = [SELECT Id, LastName, Gender__c, EMail, Fax FROM Contact WHERE Id = :lMergeCon[0].Id];
        List<Contact> lCon1 = [SELECT Id, LastName, Gender__c, EMail, Fax FROM Contact WHERE Id = :lMergeCon[1].Id];
        System.assert([SELECT Id FROM Account].size() == 1);
        System.assert([SELECT Id FROM Contact].size() == lMergeCon.size());
       
        // Check if Merge hasn't overwritten data from exising mergeCon and mergeAcc
        System.assert(lAcc[0].Name == 'MergeAcc');
        System.assert(lCon0[0].Gender__c.startsWith('Male'));
        System.assert(lCon1[0].Gender__c.startsWith('Male'));
        
        // Check if Merge has added data to existing mergeCon and mergeAcc
        System.assert(lAcc[0].Website == 'http://test-firma.de');
        System.assert(lAcc[0].Industry == 'Bekleidung');
        System.assert(lCon0[0].Fax == '01234');
        System.assert(lCon1[0].Fax == '56789');  
    }
    
    public static TestMethod void testLeadWithAccMerging() {
        init();
        System.assert([SELECT Id FROM Account].size() == 1);
        System.assert([SELECT Id FROM Contact].size() == lMergeCon.size());
        
        lLead[4].Status = 'Prospect';
        lLead[5].Status = 'Prospect';
        List<Lead> tmpLeadList = new List<Lead>();
        tmpLeadList.add(lLead[4]);
        tmpLeadList.add(lLead[5]);
        update tmpLeadList;
        
        // Check if no new Account and 2 Contacts have been added
		List<Account> lAcc = [SELECT Id, Name, Website, Industry FROM Account];
        System.assert(lAcc.size() == 1);
        
        List<Contact> lCon = [SELECT Id, Name, AccountId FROM Contact];
        System.assert(lCon.size() == lMergeCon.size() + 2);
        
        // Check if Account merged
        System.assert(lAcc[0].Name == 'MergeAcc');
        System.assert(lAcc[0].Website == 'http://test-firma.de');
        System.assert(lAcc[0].Industry == 'Bekleidung');
               
        // Check if Contacts where added to Account
        for(Contact con : lCon) {
            System.assert(con.AccountId == mergeAcc.Id);
        }       
    }
    
    public static TestMethod void testLeadWithAccMergingPhone() {
        init();
        System.assert([SELECT Id FROM Account].size() == 1);
        System.assert([SELECT Id FROM Contact].size() == lMergeCon.size());
        
        lLead[6].Status = 'Prospect';
        update lLead[6];
        
        // Check if no new Account and 1 Contact have been added
		List<Account> lAcc = [SELECT Id, Name, Website, Industry FROM Account];
        System.assert(lAcc.size() == 1);
        
        List<Contact> lCon = [SELECT Id, Name, AccountId FROM Contact];
        System.assert(lCon.size() == lMergeCon.size() + 1);
        
        // Check if Account merged
        System.assert(lAcc[0].Name == 'MergeAcc');
        System.assert(lAcc[0].Website == 'http://test-firma.de');
               
        // Check if Contacts where added to Account
        for(Contact con : lCon) {
            System.assert(con.AccountId == mergeAcc.Id);
        }       
    }
    
    public static TestMethod void testLeadWithoutMerging() {
        init();
        lLead[7].Status = 'Prospect';
        update lLead[7];
        
        List<Account> lAcc = [SELECT Id, Name FROM Account WHERE Name = 'LeadAcc'];
        System.assert(lAcc.size() == 1);
        
        List<Contact> lCon = [SELECT Id, LastName, AccountId FROM Contact WHERE LastName Like 'LeadCon%'];
        System.debug(lCon.size());
        if(lCon.size() == 1) {
           System.assert(lCon[0].AccountId != mergeAcc.Id); 
        }
        else {
            System.assert(false);
        }
    }
}
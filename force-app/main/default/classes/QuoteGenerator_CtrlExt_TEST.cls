@isTest
public class QuoteGenerator_CtrlExt_TEST {

    @testSetup
    static void testSetup() {
        Opportunity__c oppSetting = new Opportunity__c(Number__c = 101, Year__c = 2020);
        insert oppSetting;
        
        Account acc = new Account(Name = 'Test Account', Country_Code__c = 'DE');
        insert acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'Test Opp',
            CloseDate = Date.today(),
            StageName = 'Pending',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert opp;
        
        Product2 p1 = new Product2(
            Name = 'P1',
            Zahlungsmodalit_ten__c = 'monatlich'
        );
        Product2 p2 = new Product2(
            Name = 'P2',
            Zahlungsmodalit_ten__c = 'variabel'
        );
        Product2 p3 = new Product2(
            Name = 'P3',
            Zahlungsmodalit_ten__c = 'einmalig'
        );
        insert new Product2[]{p1, p2, p3};
        
        PricebookEntry pe1 = new PricebookEntry(
            Product2Id = p1.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 100,
            IsActive = true
        );
        PricebookEntry pe2 = new PricebookEntry(
            Product2Id = p2.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 1000,
            IsActive = true
        );
        PricebookEntry pe3 = new PricebookEntry(
            Product2Id = p3.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 200,
            IsActive = true
        );
        insert new PricebookEntry[]{pe1, pe2, pe3};
            
        OpportunityLineItem oli1 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = p1.Id,
            UnitPrice = 100,
            Quantity = 1
        );
        OpportunityLineItem oli2 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = p2.Id,
            UnitPrice = 1000,
            Quantity = 1
        );
        OpportunityLineItem oli3 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = p3.Id,
            UnitPrice = 200,
            Quantity = 1
        );
        insert new OpportunityLineItem[]{oli1, oli2, oli3};
    }
    
    static testMethod void testGenerator() {
        Opportunity opp = [SELECT Id FROM Opportunity];
        
        test.startTest();
        
        PageReference pageRef = new PageReference('/apex/QuoteGenerator?id='+opp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        QuoteGenerator_CtrlExt ctrl = new QuoteGenerator_CtrlExt(sc);
        ctrl.generate();
        
        test.stopTest();
        
        List<ContentDocumentLink> cdl = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :opp.Id];
        System.assert(!cdl.isEmpty());
    }
    
    static testMethod void testPdf() {
        Opportunity opp = [SELECT Id FROM Opportunity];
        
        test.startTest();
        
        PageReference pageRef = new PageReference('/apex/QuotePdf?id='+opp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        QuotePdf_CtrlExt ctrl1 = new QuotePdf_CtrlExt(sc);
        ctrl1.getProducts1();
        ctrl1.getProducts2();
        ctrl1.getProducts3();
        ctrl1.getOli1Discount();
        ctrl1.getOli1ListPrice();
        ctrl1.getOli1TotalAmount();
        ctrl1.getOli2Discount();
        ctrl1.getOli2ListPrice();
        ctrl1.getOli2TotalAmount();
        ctrl1.getOli3Discount();
        ctrl1.getOli3ListPrice();
        ctrl1.getOli3TotalAmount();
        
        test.stopTest();
    }
    
}
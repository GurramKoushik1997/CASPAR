@isTest
public class AccountSubmitViaApiCtrl_TEST {

    public static Account acc;
    
    public static void init() {
        acc = new Account(Name = 'Test Account', Email__c = 'testaccount@testing123.de', Country_Code__c = 'DE');
        insert acc;
    }
    
    public static testMethod void testSuccess() {
        init();
        
        test.startTest();
        
        AccountSubmitViaApiCtrl.serverResponse.saved = true;
        AccountSubmitViaApiCtrl.serverResponse.caspar_id = 12345;
        AccountSubmitViaApiCtrl.serverResponse.temporary_password = 'qwertz';
        
        AccountSubmitViaApiCtrl.getAccount(acc.Id);
        AccountSubmitViaApiCtrl.submitAccount(acc);
        
        test.stopTest();
    }
    
    public static testMethod void testFailure() {
        init();
        
        test.startTest();
        
        AccountSubmitViaApiCtrl.serverResponse.saved = false;
        List<String> errors = new List<String>();
        errors.add('Name is missing');
        errors.add('Email already taken');
        AccountSubmitViaApiCtrl.serverResponse.errors = errors;
        
        AccountSubmitViaApiCtrl.getAccount(acc.Id);
        AccountSubmitViaApiCtrl.submitAccount(acc);
        
        test.stopTest();
    }
    
}
@isTest
public class AccountDeactivateViaApiCtrl_TEST {

    public static Account acc;
    
    public static void init() {
        acc = new Account(Name = 'Test Account', Caspar_Id__c = 10, Is_Deactivated__c = false);
        insert acc;
    }
    
    public static testMethod void testSuccess() {
        init();
        
        test.startTest();
        
        AccountDeactivateViaApiCtrl.resBody = 'true';
        
        AccountDeactivateViaApiCtrl.getAccount(acc.Id);
        AccountDeactivateViaApiCtrl.deactivateAccount(acc);
        
        test.stopTest();
    }
    
    public static testMethod void testFailure() {
        init();
        
        test.startTest();
        
        AccountDeactivateViaApiCtrl.resBody = 'false';
        
        AccountDeactivateViaApiCtrl.getAccount(acc.Id);
        AccountDeactivateViaApiCtrl.deactivateAccount(acc);
        
        test.stopTest();
    }
    
}
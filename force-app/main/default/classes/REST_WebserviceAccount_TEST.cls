@isTest
public class REST_WebserviceAccount_TEST {

    public static Account acc;
    public static RecordType rt;
    public static Therapist__c tp;
    
    public static void init() {
        rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Customer'];
        
        acc = new Account(Name = 'Test Account 01', RecordTypeId = rt.Id, Caspar_Id__c = 10);
        insert acc;
        
        tp = new Therapist__c(Name = 'Test Therapist 01', Account__c = acc.Id, First_Name__c = 'Test', Last_Name__c = 'Therapist 01', Gender__c = 'Male', Email__c = 'test@therapist.com', Caspar_Id__c = 11);
        insert tp;
    }
    
    /*
     * POST SUCCESS
     */
    
    public static testMethod void testPostAccountSuccess() {
        init();
        
        test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/account';
        req.requestBody = Blob.valueOf('{"account": {"name": "Test Account 02","caspar_id": 33,"last_activity_at": 1489446378}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        RestContext.request.addHeader('token',Label.request_token);
        REST_WebserviceAccount.SyncResponse results = REST_WebserviceAccount.doPost();
        
        test.stopTest();
        
        List<Account> account = [SELECT Id FROM Account WHERE Caspar_Id__c = 33];
        System.assertEquals(account.size(),1);
    }
    
    public static testMethod void testPostTherapistSuccess() {
        init();
        
        test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/account/10/therapists';
        req.requestBody = Blob.valueOf('{"therapist": {"name": "Test Therapist 02","caspar_id": 33,"firstname": "Test","lastname": "Therapist 02","gender": "male","email": "test@therapist02.com","last_activity_at": 1489446378}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        RestContext.request.addHeader('token',Label.request_token);
        REST_WebserviceAccount.SyncResponse results = REST_WebserviceAccount.doPost();
        
        test.stopTest();
        
        List<Therapist__c> therapist = [SELECT Id FROM Therapist__c WHERE Caspar_Id__c = 33];
        System.assertEquals(therapist.size(),1);
    }
    
    /*
     * POST FAILURE
     */
    
    public static testMethod void testPostTherapistAccountNotFound() {
        init();
        
        test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/account/44/therapists';
        req.requestBody = Blob.valueOf('{"therapist": {"name": "Test Therapist 02","caspar_id": 33,"firstname": "Test","lastname": "Therapist 02","gender": "male","email": "test@therapist02.com","last_activity_at": 1489446378}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        RestContext.request.addHeader('token',Label.request_token);
        REST_WebserviceAccount.SyncResponse results = REST_WebserviceAccount.doPost();
        
        test.stopTest();
    }
    
    public static testMethod void testPostWrongToken() {
        init();
        
        test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/account/10/therapists';
        req.requestBody = Blob.valueOf('{"therapist": {"name": "Test Therapist 02","caspar_id": 33,"firstname": "Test","lastname": "Therapist 02","gender": "male","email": "test@therapist02.com","last_activity_at": 1489446378}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        RestContext.request.addHeader('Token','12345abcde');
        REST_WebserviceAccount.SyncResponse results = REST_WebserviceAccount.doPost();
        
        test.stopTest();
    }
    
    public static testMethod void testPostWrongObjecttype() {
        init();
        
        test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/account/10/therapist';
        req.requestBody = Blob.valueOf('{"therapist": {"name": "Test Therapist 02","caspar_id": 33,"firstname": "Test","lastname": "Therapist 02","gender": "male","email": "test@therapist02.com","last_activity_at": 1489446378}}');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        RestContext.request.addHeader('token',Label.request_token);
        REST_WebserviceAccount.SyncResponse results = REST_WebserviceAccount.doPost();
        
        test.stopTest();
    }
    
    /*
     * PATCH SUCCESS
     */
    
    public static testMethod void testPatchAccountSuccess() {
        init();
        
        test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/account/10';
        req.requestBody = Blob.valueOf('{"account": {"name": "Test Account 01 Updated","caspar_id": 10,"last_activity_at": 1489446378}}');
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;
        
        RestContext.request.addHeader('token',Label.request_token);
        REST_WebserviceAccount.SyncResponse results = REST_WebserviceAccount.doPatch();
        
        test.stopTest();
        
        List<Account> account = [SELECT Id, Last_Activity__c FROM Account WHERE Caspar_Id__c = 10 AND Last_Activity__c != null];
        System.assertEquals(account.size(),1);
    }
    
    public static testMethod void testPatchTherapistSuccess() {
        init();
        
        test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/account/10/therapists/11';
        req.requestBody = Blob.valueOf('{"therapist": {"name": "Test Therapist 02 Updated","caspar_id": 11,"last_activity_at": 1489446378}}');
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;
        
        RestContext.request.addHeader('token',Label.request_token);
        REST_WebserviceAccount.SyncResponse results = REST_WebserviceAccount.doPatch();
        
        test.stopTest();
        
        List<Therapist__c> therapist = [SELECT Id, Last_Activity__c FROM Therapist__c WHERE Caspar_Id__c = 11 AND Last_Activity__c != null];
        System.assertEquals(therapist.size(),1);
    }
    
    /*
     * PATCH FAILURE
     */
    
    public static testMethod void testPatchAccountNotFound() {
        init();
        
        test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/account/44';
        req.requestBody = Blob.valueOf('{"therapist": {"name": "Test Therapist 02","caspar_id": 33,"firstname": "Test","lastname": "Therapist 02","gender": "male","email": "test@therapist02.com","last_activity_at": 1489446378}}');
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;
        
        RestContext.request.addHeader('token',Label.request_token);
        REST_WebserviceAccount.SyncResponse results = REST_WebserviceAccount.doPatch();
        
        test.stopTest();
    }
    
    public static testMethod void testPatchTherapistNotFound() {
        init();
        
        test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/account/10/therapists/55';
        req.requestBody = Blob.valueOf('{"therapist": {"name": "Test Therapist 02","caspar_id": 33,"firstname": "Test","lastname": "Therapist 02","gender": "male","email": "test@therapist02.com","last_activity_at": 1489446378}}');
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;
        
        RestContext.request.addHeader('token',Label.request_token);
        REST_WebserviceAccount.SyncResponse results = REST_WebserviceAccount.doPatch();
        
        test.stopTest();
    }
    
    public static testMethod void testPatchTherapistAccountNotFound() {
        init();
        
        test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/account/44/therapists/55';
        req.requestBody = Blob.valueOf('{"therapist": {"name": "Test Therapist 02","caspar_id": 33,"firstname": "Test","lastname": "Therapist 02","gender": "male","email": "test@therapist02.com","last_activity_at": 1489446378}}');
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;
        
        RestContext.request.addHeader('token',Label.request_token);
        REST_WebserviceAccount.SyncResponse results = REST_WebserviceAccount.doPatch();
        
        test.stopTest();
    }
    
    public static testMethod void testPatchWrongToken() {
        init();
        
        test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/account/10/therapists';
        req.requestBody = Blob.valueOf('{"therapist": {"name": "Test Therapist 02","caspar_id": 33,"firstname": "Test","lastname": "Therapist 02","gender": "male","email": "test@therapist02.com","last_activity_at": 1489446378}}');
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;
        
        RestContext.request.addHeader('Token','12345abcde');
        REST_WebserviceAccount.SyncResponse results = REST_WebserviceAccount.doPatch();
        
        test.stopTest();
    }
    
    public static testMethod void testPatchWrongObjecttype() {
        init();
        
        test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/account/10/therapist';
        req.requestBody = Blob.valueOf('{"therapist": {"name": "Test Therapist 02","caspar_id": 33,"firstname": "Test","lastname": "Therapist 02","gender": "male","email": "test@therapist02.com","last_activity_at": 1489446378}}');
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;
        
        RestContext.request.addHeader('token',Label.request_token);
        REST_WebserviceAccount.SyncResponse results = REST_WebserviceAccount.doPatch();
        
        test.stopTest();
    }
}
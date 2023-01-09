global class AccountDeactivateViaApiCtrl {
    
    public static Account currentAccount {get;set;}
    public static String resBody {get;set;}
    
    @AuraEnabled
    Webservice static String deactivateAccount(Account theAccount) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        
        req.setMethod('DELETE');
        req.setEndpoint(Label.backend_url_account_post + '/' + theAccount.Caspar_Id__c);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('token', Label.backend_token);
        
        try {
            if(!Test.isRunningTest()) {
                Http http = new Http();
                res = http.send(req);
                System.Debug('##### res body: ' + res.getBody() + ' #####');
                
                resBody = res.getBody();
            }
            
            // success
            if(resBody.containsIgnoreCase('true')) {
                // update account information
                theAccount.Is_deactivated__c = true;
                
                try {
                    update theAccount;
                    return String.valueOf(res.getStatusCode());
                } catch(System.DmlException e) {
                    System.Debug('Error updating account: ' + e);
                    return 'Error updating account: ' + e;
                }
            }
            
            // failure
            else {
                return 'An unknown error occurred. Please contact your system administrator.';
            }
        } catch(System.CalloutException e) {
            System.debug('Callout failed: ' + e);
            return 'Callout failed: ' + e;
        }
    }
    
    @AuraEnabled
    public static Account getAccount(Id accountId) {
        currentAccount = [SELECT Id, Name, Caspar_Id__c, Is_deactivated__c FROM Account WHERE Id = :accountId];
        return currentAccount;
    }
    
}
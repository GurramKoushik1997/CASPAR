global class AccountSubmitViaApiCtrl {
    
    public static Account currentAccount {get;set;}
    public static OutgoingBackendResponse serverResponse = new OutgoingBackendResponse();
    
    @AuraEnabled
    Webservice static String submitAccount(Account theAccount) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        
        String body = '{\"account\": {';
        body += '\"name\": \"' + theAccount.Name + '\",';
        body += '\"email\": \"' + theAccount.Email__c + '\",';
        body += '\"country\": \"' + theAccount.Country_Code__c + '\"';
        body += '}}';
        
        req.setBody(body);
        
        req.setMethod('POST');
        req.setEndpoint(Label.backend_url_account_post);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('token', Label.backend_token);
        
        try {
            if(!Test.isRunningTest()) {
                Http http = new Http();
                res = http.send(req);
                
                System.Debug('##### res body: ' + res.getBody() + ' #####');
                
                try {
                    serverResponse = (OutgoingBackendResponse) JSON.deserialize(res.getBody(), OutgoingBackendResponse.class);
                    System.Debug('serverResponse: ' + serverResponse);
                } catch(System.JSONException e) {
                    System.Debug('Error parsing json: ' + e);
                    return String.valueOf(e);
                }
            }
            
            // success
            if(serverResponse.saved) {
                // update account information
                theAccount.Caspar_Id__c = serverResponse.caspar_id;
                theAccount.Temporary_Password__c = serverResponse.temporary_password;
                
                try {
                    update theAccount;
                    return String.valueOf(res.getStatusCode());
                } catch(System.DmlException e) {
                    System.Debug('Error updating account: ' + e);
                    return 'Error updating account: ' + e;
                } catch(System.NullPointerException e) {
                    System.Debug('Error updating account: ' + e);
                    return 'Error updating account: ' + e;
                }
            }
            
            // failure
            else {
                String errorResponse;
                if(!serverResponse.errors.isEmpty()) {
                    for(Integer i=0; i < serverResponse.errors.size(); i++) {
                        if(i == 0) {
                            errorResponse = serverResponse.errors[i];
                        } else {
                            errorResponse += ' and ' + serverResponse.errors[i];
                        }
                    }
                }
                return errorResponse;
            }
        } catch(System.CalloutException e) {
            System.debug('Callout failed: ' + e);
            return 'Callout failed: ' + e;
        }
    }
    
    @AuraEnabled
    public static Account getAccount(Id accountId) {
        currentAccount = [SELECT Id, Name, Email__c, Country_Code__c, Caspar_Id__c, Temporary_Password__c FROM Account WHERE Id = :accountId];
        return currentAccount;
    }
    
}
@RestResource(urlMapping='/account/*')
global with sharing class REST_WebserviceAccount {

    /*
     * POST
     */
    
    /* ACCOUNT INSERT
    /services/apexrest/account
    {
    "account": {
    "name": "Test Therapist 01",
    "caspar_id": 33
    }
    }
	*/
    
    /* THERAPIST INSERT
    /services/apexrest/account/14/therapists
    {
    "therapist": {
    "name": "Test Therapist 01",
    "firstname": "Test",
    "lastname": "Therapist 01",
    "caspar_id": 3,
    "email": "test@therapist01.de",
    "gender": "Male"
    }
    }
	*/
    
    @HttpPost
    global static SyncResponse doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        SyncResponse resp = new SyncResponse();
        
        Map<String, String> headers = req.headers; // request headers
        String token = headers.get('token'); // security token
        if(token == null) {
            token = headers.get('Token');
        }
        
        // only continue if security token is correct
        if(token == Label.request_token) {
            
            String objectType = req.requestURI.substringAfterLast('/'); // sObjectType (therapist)
            System.Debug('##### objectType: ' + objectType + ' #####');
            
            Map<String,Object> reqBody = (Map<String,Object>) JSON.deserializeUntyped(req.requestBody.toString());
            System.Debug('##### reqBody: ' + reqBody + ' #####');
            
            // account
            if(objectType == 'account') {
                // get key value pairs from request
                Map<String,Object> mAccount = (Map<String,Object>) reqBody.get('account');
                System.Debug('##### mAccount: ' + mAccount + ' #####');
                
                // get field mapping
                List<SyncItem> syncItems = getSyncItems('Account');
                
                // create new account
                Account accToInsert = new Account();
                
                // account recordtype 'customer'
                RecordType rtAccount = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Customer'];
                accToInsert.RecordTypeId = rtAccount.Id;
                
                // set field values
                for(String field : mAccount.keySet()) {
                    for(SyncItem item : syncItems) {
                        if(item.field == field) {
                            // null values
                            if(mAccount.get(field) == null) {
                                accToInsert.put(item.value, null);
                            }
                            // datetime
                            else if(item.dataType == 'dt') {
                                // need to convert timestamp to datetime object
                                Datetime theDatetime = datetime.newInstance(0);
                                Integer startInt = integer.valueOf(mAccount.get(field));
                                theDatetime = theDatetime.addSeconds(startInt);
                                
                                accToInsert.put(item.value, theDatetime);
                            }
                            // all other data types
                            else {
                                accToInsert.put(item.value, mAccount.get(field));
                            }
                        }
                    }
                }
                
                try {
                    insert accToInsert;
                    System.Debug('##### Account successfully inserted. #####');
                    resp.success = true;
                    resp.status = 201;
                    resp.errorMessage = null;
                } catch(Exception e) {
                    System.Debug('##### Error inserting Account: ' + e + ' #####');
                    resp.success = false;
                    resp.status = 400;
                    resp.errorMessage = e.getMessage();
                }
            }
            
            // therapists
            else if(objectType == 'therapists') {
                
                // account´s Caspar Id from request uri
                String accountCasparId = req.requestURI.substringBeforeLast('/'); // account´s Caspar Id
                accountCasparId = accountCasparId.substringAfterLast('/');
                System.Debug('##### accountCasparId: ' + accountCasparId + ' #####');
                
                // find parent account of therapist
                List<Account> lAcc = [SELECT Id FROM Account WHERE Caspar_Id__c = :Integer.valueOf(accountCasparId)];
                
                // continue of account was found
                if(!lAcc.isEmpty()) {
                    String accountId = lAcc[0].Id;
                    
                    // get key value pairs from request
                    Map<String,Object> mTherapist = (Map<String,Object>) reqBody.get('therapist');
                    System.Debug('##### mTherapist: ' + mTherapist + ' #####');
                    
                    // get field mapping
                    List<SyncItem> syncItems = getSyncItems('Therapist');
                    
                    
                    // create new therapist
                    Therapist__c tpToInsert = new Therapist__c();
                    
                    tpToInsert.Account__c = accountId;
                    
                    // set field values
                    for(String field : mTherapist.keySet()) {
                        for(SyncItem item : syncItems) {
                            if(item.field == field) {
                                // null values
                                if(mTherapist.get(field) == null) {
                                    tpToInsert.put(item.value, null);
                                }
                                // datetime
                                else if(item.dataType == 'dt') {
                                    // need to convert timestamp to datetime object
                                    Datetime theDatetime = datetime.newInstance(0);
                                    Integer startInt = integer.valueOf(mTherapist.get(field));
                                    theDatetime = theDatetime.addSeconds(startInt);
                                    
                                    tpToInsert.put(item.value, theDatetime);
                                }
                                // all other data types
                                else {
                                    tpToInsert.put(item.value, mTherapist.get(field));
                                }
                            }
                        }
                    }
                    
                    try {
                        insert tpToInsert;
                        System.Debug('##### Therapist successfully inserted. #####');
                        resp.success = true;
                        resp.status = 201;
                        resp.errorMessage = null;
                    } catch(Exception e) {
                        System.Debug('##### Error inserting Therapist: ' + e + ' #####');
                        resp.success = false;
                        resp.status = 400;
                        resp.errorMessage = e.getMessage();
                    }
                }
                
                // acount not found
                else {
                    resp.success = false;
                    resp.status = 404;
                    resp.errorMessage = 'No account with id ' + accountCasparId + ' found';
                }
            }
            
            // wrong objectType
            else {
                resp.success = false;
                resp.status = 400;
                resp.errorMessage = 'Object type ' + objectType + ' invalid for that kind of action';
            }
            
        }
        
        // wrong / missing security token
        else {
            resp.success = false;
            resp.status = 400;
            resp.errorMessage = 'Access denied';
        }
        
        return resp;
    }
    
    /*
     * PATCH
     */
    
    /* ACCOUNT UPDATE
    /services/apexrest/account/20
    {
    "account": {
    "active_patients_count": 21,
    "inactive_patients_count": 6
    }
    }
    */
    
    /* THERAPIST UPDATE
    /services/apexrest/account/20/therapists/11
    {
    "therapist": {
    "firstname": "Peter",
    "email": "peter_test_therapist@therapists01.de"
    }
    }
    */
    
    @HttpPatch
    global static SyncResponse doPatch() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        SyncResponse resp = new SyncResponse();
        
        Map<String, String> headers = req.headers; // request headers
        String token = headers.get('token'); // security token
        if(token == null) {
            token = headers.get('Token');
        }
        
        // only continue if security token is correct
        if(token == Label.request_token) {
            
            String recordId = req.requestURI.substringAfterLast('/'); // record´s Caspar Id
            System.Debug('##### recordId: ' + recordId + ' #####');
            
            String objectType = req.requestURI.substringBeforeLast('/'); // sObjectType (account or therapist)
            objectType = objectType.substringAfterLast('/');
            System.Debug('##### objectType: ' + objectType + ' #####');
            
            Map<String,Object> reqBody = (Map<String,Object>) JSON.deserializeUntyped(req.requestBody.toString());
            System.Debug('##### reqBody: ' + reqBody + ' #####');
            
            Boolean queryError = false; // used to display correct error message if query failed due to wrong fields
            
            // account
            if(objectType == 'account') {
                // get key value pairs from request
                Map<String,Object> mAccount = (Map<String,Object>) reqBody.get('account');
                System.Debug('##### mAccount: ' + mAccount + ' #####');
                
                // get field mapping
                List<SyncItem> syncItems = getSyncItems('Account');
                
                // query account
                String query = 'SELECT';
                for(SyncItem field : syncItems) {
                    query += ' ' + field.value + ',';
                }
                query = query.removeEnd(',');
                query += ' FROM Account WHERE Caspar_Id__c = ' + recordId + ' LIMIT 1';
                
                List<Account> lAcc = new List<Account>();
                
                try {
                    lAcc = Database.query(query);
                } catch(System.QueryException e) {
                    queryError = true;
                    System.Debug('Error in account query: ' + e);
                    resp.success = false;
                    resp.status = 400;
                    resp.errorMessage = e.getMessage();
                }
                
                // only continue if account was found
                if(!lAcc.isEmpty()) {
                    Account accToUpdate = lAcc[0];
                    
                    // update fields
                    for(String field : mAccount.keySet()) {
                        for(SyncItem item : syncItems) {
                            if(item.field == field) {
                                // null values
                                if(mAccount.get(field) == null) {
                                    accToUpdate.put(item.value, null);
                                }
                                // datetime
                                else if(item.dataType == 'dt') {
                                    // need to convert timestamp to datetime object
                                    Datetime theDatetime = datetime.newInstance(0);
                                    Integer startInt = integer.valueOf(mAccount.get(field));
                                    theDatetime = theDatetime.addSeconds(startInt);
                                    
                                    accToUpdate.put(item.value, theDatetime);
                                }
                                // all other data types
                                else {
                                    accToUpdate.put(item.value, mAccount.get(field));
                                }
                            }
                        }
                    }
                    
                    try {
                        update accToUpdate;
                        System.Debug('##### Account successfully updated. #####');
                        resp.success = true;
                        resp.status = 200;
                        resp.errorMessage = null;
                    } catch(Exception e) {
                        System.Debug('##### Error updating account: ' + e + ' #####');
                        resp.success = false;
                        resp.status = 400;
                        resp.errorMessage = e.getMessage();
                    }
                }
                
                // account not found
                else if(!queryError) {
                    resp.success = false;
                    resp.status = 404;
                    resp.errorMessage = 'No account with id ' + recordId + ' found';
                }
            }
            
            // therapists
            else if(objectType == 'therapists') {
                // get key value pairs from request
                Map<String,Object> mTherapist = (Map<String,Object>) reqBody.get('therapist');
                System.Debug('##### mTherapist: ' + mTherapist + ' #####');
                
                // get field mapping
                List<SyncItem> syncItems = getSyncItems('Therapist');
                
                // query therapist
                String query = 'SELECT';
                for(SyncItem field : syncItems) {
                    query += ' ' + field.value + ',';
                }
                query = query.removeEnd(',');
                query += ' FROM Therapist__c WHERE Caspar_Id__c = ' + recordId + ' LIMIT 1';
                
                List<Therapist__c> lTherapists = new List<Therapist__c>();
                
                try {
                    lTherapists = Database.query(query);
                } catch(System.QueryException e) {
                    queryError = true;
                    System.Debug('Error in therapist query: ' + e);
                    resp.success = false;
                    resp.status = 400;
                    resp.errorMessage = e.getMessage();
                }
                
                // only continue if therapist was found
                if(!lTherapists.isEmpty()) {
                    Therapist__c therapistToUpdate = lTherapists[0];
                    
                    // update fields
                    for(String field : mTherapist.keySet()) {
                        for(SyncItem item : syncItems) {
                            if(item.field == field) {
                                // null values
                                if(mTherapist.get(field) == null) {
                                    therapistToUpdate.put(item.value, null);
                                }
                                // datetime
                                else if(item.dataType == 'dt') {
                                    // need to convert timestamp to datetime object
                                    Datetime theDatetime = datetime.newInstance(0);
                                    Integer startInt = integer.valueOf(mTherapist.get(field));
                                    theDatetime = theDatetime.addSeconds(startInt);
                                    
                                    therapistToUpdate.put(item.value, theDatetime);
                                }
                                // all other data types
                                else {
                                    therapistToUpdate.put(item.value, mTherapist.get(field));
                                }
                            }
                        }
                    }
                    
                    try {
                        update therapistToUpdate;
                        System.Debug('##### Therapist successfully updated. #####');
                        resp.success = true;
                        resp.status = 200;
                        resp.errorMessage = null;
                    } catch(Exception e) {
                        System.Debug('##### Error updating Therapist: ' + e + ' #####');
                        resp.success = false;
                        resp.status = 400;
                        resp.errorMessage = e.getMessage();
                    }
                }
                
                // therapist not found
                else if(!queryError) {
                    resp.success = false;
                    resp.status = 404;
                    resp.errorMessage = 'No therapist with id ' + recordId + ' found';
                }
            }
            
            // wrong objectType
            else {
                resp.success = false;
                resp.status = 400;
                resp.errorMessage = 'Object type ' + objectType + ' invalid for that kind of action';
            }
            
        }
        
        // wrong / missing security token
        else {
            resp.success = false;
            resp.status = 400;
            resp.errorMessage = 'Access denied';
        }
        
        return resp;
    }
    
    // get field mapping from static resource
    public static List<SyncItem> getSyncItems(String objectType) {
        List<SyncItem> syncItems = new List<SyncItem>();
        
        String srName = 'REST_Mapping_' + objectType;
        
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = :srName LIMIT 1];
        
        List<String> lFieldMapping = sr.Body.toString().split(','); // split body into field groups
        
        for(String field : lFieldMapping) {
            List<String> parts = field.split(':'); // split field group to backend field name, salesforce field name, data type (e.g. account_id:id:s)
            SyncItem wrap = new SyncItem(parts[0],parts[1],parts[2]);
            syncItems.add(wrap);
        }
        
        return syncItems;
    }
    
    // wrapper class for fields
    global class SyncItem {
        global String field {get;set;}
        global String value {get;set;}
        global String dataType {get;set;}
        
        global SyncItem(String field, String value, String dataType) {
            this.field = field;
            this.value = value;
            this.dataType = dataType;
        }
    }
    
    // wrapper class for response
    global class SyncResponse {
        global Boolean success {get;set;}
        global Integer status {get;set;}
        global String errorMessage {get;set;}
        
        global SyncResponse() {}
    }
    
}
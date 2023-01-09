trigger PatientAfterInsert on Patient__c (after insert) {

    /*
     * UPDATE COUNT ON NACHSORGEQUOTE / CREATE NEW NACHSORGEQUOTE IF NECCESSARY
     * + CREATE TASKS FOR THERAPEUT
     */
    
    Map<Id,List<Patient__c>> mPatientCount = new Map<Id,List<Patient__c>>();
    
    Map<Integer,String> mMonthName = new Map<Integer,String>{
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
    
    List<Task> tasksToInsert = new List<Task>();
    
    for(Patient__c pat : trigger.new) {
        // nachsorgequote
        List<Patient__c> patients = mPatientCount.get(pat.Account__c);
        if(patients == null) {
            patients = new List<Patient__c>();
        }
        patients.add(pat);
        mPatientCount.put(pat.Account__c, patients);
    }
    
    // nachsorgequote
    if(!mPatientCount.isEmpty()) {
        String currentYear = String.valueOf(Date.today().year());
        String currentMonth = mMonthName.get(Date.today().month());
        
        List<Nachsorgequote__c> nsqs = [
            SELECT Id, Anzahl_TRN_Patienten__c, Account__c
            FROM Nachsorgequote__c
            WHERE Account__c IN :mPatientCount.keySet()
            AND Jahr__c = :currentYear
            AND Monat__c = :currentMonth
        ];
        
        Map<Id,Nachsorgequote__c> mNsqs = new Map<Id,Nachsorgequote__c>();
        for(Nachsorgequote__c nsq : nsqs) {
            mNsqs.put(nsq.Account__c,nsq);
        }
        
        List<Nachsorgequote__c> nsqsToUpsert = new List<Nachsorgequote__c>();
        for(Id accountId : mPatientCount.keySet()) {
            Nachsorgequote__c nsq = mNsqs.get(accountId);
            if(nsq == null) {
                nsq = new Nachsorgequote__c();
                nsq.Account__c = accountId;
                nsq.Jahr__c = currentYear;
                nsq.Monat__c = currentMonth;
                nsq.Anzahl_TRN_Patienten__c = 0;
            }
            nsq.Anzahl_TRN_Patienten__c += mPatientCount.get(accountId).size();
            System.Debug(nsq);
            nsqsToUpsert.add(nsq);
        }
        
        try {
            upsert nsqsToUpsert;
        } catch(Exception e) {
            System.Debug('An unknown error occurred upserting nachsorgequoten: ' + e);
        }
    }
    
}
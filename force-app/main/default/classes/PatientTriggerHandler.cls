public class PatientTriggerHandler {
	public static void run(){
        if(trigger.isBefore){
            
        }else{
            if(trigger.isInsert){
                createAutomativeTasks();
                syncTherapist();
            }else if(trigger.isUpdate){
                createAutomativeTasks();
                syncTherapist();
            }
        }
    }
    
    private static void createAutomativeTasks(){
        Set<String> patientIds = new Set<String>();
        for(Patient__c p : (List<Patient__c>)trigger.new){
            if(trigger.isInsert && p.Medizinisches_Konzept__c  != null && p.Startdatum__c != null && p.Therapist__c != null){
                patientIds.add(p.Id);
            }else if(trigger.isUpdate && p.Startdatum__c != null && p.Therapist__c != null && p.Medizinisches_Konzept__c != null){
                Patient__c oldPatient = (Patient__c)trigger.oldmap.get(p.Id);
                if( (p.Medizinisches_Konzept__c != oldPatient.Medizinisches_Konzept__c)
                   || (p.Therapist__c != oldPatient.Therapist__c && oldPatient.Therapist__c == null)
                   || (p.Startdatum__c != oldPatient.Startdatum__c && oldPatient.Startdatum__c == null)){
                    patientIds.add(p.Id);
                }
            }   
        }
        if(patientIds.size()>0){
            Service_CreateAutomaticTasks.createTasks(patientIds);
            System.debug(Service_CreateAutomaticTasks.log);
        }        
    }
    
    private static void syncTherapist(){
        Set<String> patientIds = new Set<String>();
        for(Patient__c p : (List<Patient__c>)trigger.new){            
            if(trigger.isInsert && p.Therapist__c != null){
                patientIds.add(p.Id);
            }else if(trigger.isUpdate && p.Therapist__c != ((Patient__c)trigger.oldmap.get(p.Id)).Therapist__c){
                patientIds.add(p.Id);
            }
        }
        if(patientIds.size()>0){
            Service_SyncPatientTherapistOnTask.syncTherapist(patientIds);
            System.debug(Service_SyncPatientTherapistOnTask.log);
        }        
    } 
}
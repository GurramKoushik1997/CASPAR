public class Service_SyncPatientTherapistOnTask {
    public static boolean stopSync = false;
	public static String log;
    static{
        log = 'Intiate server| '+ System.now();
    }
    
    public static void syncTherapist(Set<String> patientIds){
        log += '\nMetohd entry | syncTherapist(Set<String> patientIds)';
        if(stopSync){
           log += '\nInfo | syncTherapist stopped by boolean flag';
            Service_SyncPatientTherapistOnTask.stopSync = false;
           return; 
        }
        Map<String,Patient__c > patients = getFreshPatients(patientIds);
        if(patients.size() == 0){
            log += '\nFatal Error | No patients found';
            return;
        }
        
        List<Task> existingTasks = getExistingAutomaticTask(patientIds);
        if(existingTasks.size() == 0){
            log += '\nFatal Error | No automatice task found';
            return;
        }
        
        boolean flag = updateAutomaticTaks(existingTasks,patients);
        log += '\nSuccess | Successfully update Therapist on automatic tasks.';
        log += '\nMetohd exit | syncTherapist(Set<String> patientIds)';
    }
    
    private static Map<String,Patient__c > getFreshPatients(Set<String> patientIds){
        log += '\nMetohd entery | getFreshPatients(Set<String> patientIds)';
        
        Map<String,Patient__c > patientmap = new Map<String,Patient__c >([Select id,Therapist__c  From Patient__c Where ID IN : patientIds]);
        
        log += '\nMetohd exit | getFreshPatients(Set<String> patientIds) | Patients: '+patientmap.size();
        return patientmap;
   }
   private static List<Task> getExistingAutomaticTask(Set<String> patientIds){
        log += '\nMetohd entery | getExistingAutomaticTask(Set<String> patientIds)';
        
        List<Task> tasklist = new List<Task>();
        tasklist = [Select id,Therapist__c,whatId From Task Where Automatic_Task__c = true AND whatId IN : patientIds];
        
        log += '\nMetohd exit | getExistingAutomaticTask(Set<String> patientIds) | tasks: '+tasklist.size();
        return tasklist;
   }
    
   private static boolean updateAutomaticTaks(List<Task> tasks,Map<String,Patient__c > patients){
       boolean success = true;
       try{
           List<Task> updatelist = new List<Task>();
           for(Task t : tasks){
               if(patients.containskey(t.whatId)){
                   t.Therapist__c = patients.get(t.whatId).Therapist__c;
                   updatelist.add(t);
               }
           }
           if(updatelist.size()>0){
               update updatelist;
           }
	           
       }catch(Exception ex){
           success = false;
           log += '\nFatal Error | '+ex.getMessage();           
       }
       log += '\nMetohd exit | updateAutomaticTaks(List<Task> tasks,Map<String,Patient__c > patients) | updated tasks: '+success;
       return success;
   }
    
}
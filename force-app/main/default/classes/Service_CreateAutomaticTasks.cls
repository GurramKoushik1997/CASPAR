/******************************************
 * Service class to create automatic task for set 
 * of accounts
 * *****************************************/
public class Service_CreateAutomaticTasks {
	public static String log;
    static{
        log = 'Intiate server| '+ System.now();
    }
    
    public static void createTasks(Set<String> patientIds){
        log += '\nMetohd entry | createTasks(Set<String> patientIds)';
        
        List<Patient__c > patients = getFreshPatients(patientIds);
        if(patients.size() == 0){
            log += '\nFatal Error | No patients found';
            return;
        }
        
        List<Task> existingTasks = getExistingAutomaticTask(patientIds);
        
        boolean flag = deleteExistingTask(existingTasks);
        if(flag == false){return;}
        
        Map<String,List<Automatic_Task__c>> automaticTaskListMap = getAutomativeTask(patients);
        if(automaticTaskListMap.size() == 0){
            log += '\nFatal Error | No automatic task for the accounts: '+patientIds;
            return;
        }
        
        flag = createNewTasks(patients,automaticTaskListMap);
        if(flag == false){return;}
        
        log += '\nSuccess | Successfully created tasks for the passed accounts.';
        log += '\nMetohd exit | createTasks(Set<String> patientIds)';   
        Service_SyncPatientTherapistOnTask.stopSync = true;
    }
    
    private static List<Patient__c > getFreshPatients(Set<String> patientIds){
        log += '\nMetohd entery | getFreshPatients(Set<String> patientIds)';
        
        List<Patient__c > patientlist = new List<Patient__c >();
        patientlist = [Select id,Medizinisches_Konzept__c,Account__r.OwnerId, Startdatum__c, Therapist__c  From Patient__c Where ID IN : patientIds];
        
        log += '\nMetohd exit | getFreshPatients(Set<String> patientIds) | Patients: '+patientlist.size();
        return patientlist;
    }
    
    private static List<Task> getExistingAutomaticTask(Set<String> patientIds){
        log += '\nMetohd entery | getExistingAutomaticTask(Set<String> patientIds)';
        
        List<Task> tasklist = new List<Task>();
        tasklist = [Select id From Task Where Automatic_Task__c = true AND whatId IN : patientIds];
        
        log += '\nMetohd exit | getExistingAutomaticTask(Set<String> patientIds) | tasks: '+tasklist.size();
        return tasklist;
    }
    
    private static boolean deleteExistingTask(List<Task> tasks){
        log += '\nMetohd entery | deleteExistingTask(List<Task> tasks)';
        
        boolean success = true;
        if(tasks.size()>0){
            try{
                delete tasks;
                log += '\nMetohd exit | tasks: '+tasks.size() + ' successfully deleted.';
            }catch(Exception ex){
                log += '\nFatal Error | '+ex.getMessage();
                success = false;
            }
        }else{
            log += '\nMetohd exit | deleteExistingTask(List<Task> tasks) | No tasks to delete.';
        }
        return success;
    }
    
    private static Map<String,List<Automatic_Task__c>> getAutomativeTask(List<Patient__c> patients){
        log += '\nMetohd entery | getAutomativeTask(List<Patient__c> patients)';
        
        Map<String,List<Automatic_Task__c>> automaticTaskListMap = new Map<String,List<Automatic_Task__c>>();
        List<Automatic_Task__c> atuomaticTasks = new List<Automatic_Task__c>();
        Set<String> medicalConcepts = new Set<String>();
        for(Patient__c p : patients){
            if(p.Medizinisches_Konzept__c != null){
                medicalConcepts.add(p.Medizinisches_Konzept__c);
            }
        }
        
        if(medicalConcepts.size()>0){
            atuomaticTasks = [Select id, Medizinisches_Konzept__r.Name,Comment__c,Days__c,Subject__c,due_date_type__c 
                         FROM Automatic_Task__c WHERE Medizinisches_Konzept__r.Name IN : medicalConcepts];
        }    
        
        for(Automatic_Task__c at : atuomaticTasks){
            if(automaticTaskListMap.containsKey(at.Medizinisches_Konzept__r.Name)){
                automaticTaskListMap.get(at.Medizinisches_Konzept__r.Name).add(at);
            }else{
                automaticTaskListMap.put(at.Medizinisches_Konzept__r.Name,new List<Automatic_Task__c>{at});
            }
        }     
        
        log += '\nMetohd exit | getAutomativeTask(List<Patient__c> patients) | automatict task: '+atuomaticTasks.size(); 
        
        return automaticTaskListMap;
    }
    
    private static boolean createNewTasks(List<Patient__c> patients,Map<String,List<Automatic_Task__c>> automaticTaskListMap){
        boolean success = true;
        log += '\nMetohd entery | createNewTasks(List<Patient__c> patients,Map<String,List<Automatic_Task__c>> automaticTaskListMap)';
        
        List<Task> tasks = new List<Task>();
        for(Patient__c p : patients){
            if(automaticTaskListMap.containsKey(p.Medizinisches_Konzept__c)){
                for(Automatic_Task__c at : automaticTaskListMap.get(p.Medizinisches_Konzept__c)){
                    Task newTask = new Task();
                    newTask.Subject = at.Subject__c;
                    newTask.Description = at.Comment__c;
                    newTask.Therapist__c = p.Therapist__c;
                    if(at.due_date_type__c == 'Days'){
                        newTask.ActivityDate = p.Startdatum__c.addDays(Integer.valueOf(at.Days__c));
                    }else if(at.due_date_type__c == 'Months'){
                        newTask.ActivityDate = p.Startdatum__c.addMonths(Integer.valueOf(at.Days__c));
                    }
                    newTask.whatId = p.Id;
                    newTask.OwnerId = Label.automatic_task_owner_id;
                    newTask.Automatic_Task__c = true;
            		tasks.add(newTask);
                }
            }else{
                log += '\nInfo | There is no configured automatic task for '+ p.Medizinisches_Konzept__c + ' | PatientId: '+p.Id;
            }
            
        }
        if(tasks.size()>0){
            try{                
                insert tasks;
            }catch(Exception ex){
                success = false;
                log += '\nFatal Error | '+ex.getMessage();
            }            
        }
        
        log += '\nMetohd exit | createNewTasks(List<Patient__c> patients,Map<String,List<Automatic_Task__c>> automaticTaskListMap) | inserted tasks: '+tasks.size();
        return success;
    }
}
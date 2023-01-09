trigger PatientTrigger on Patient__c (after insert,after update) {
	PatientTriggerHandler.run();
}
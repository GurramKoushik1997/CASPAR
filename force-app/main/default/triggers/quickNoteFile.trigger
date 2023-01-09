trigger quickNoteFile on ContentDocument (before insert) {
    
    if(trigger.isInsert && trigger.isbefore){
        System.debug('--> '+Trigger.new);
    }
}
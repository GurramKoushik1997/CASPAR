trigger UserTrigger on User (after insert, after update) {

    // add all users with profile "Neuer Standardbenutzer" to public group "CSM Team"
    
    List<User> usersToAdd = new List<User>();
    
    for(Integer i=0; i < trigger.new.size(); i++) {
        if(trigger.isInsert) {
            if(trigger.new[i].ProfileId == Label.neuer_standardbenutzer_id) {
                usersToAdd.add(trigger.new[i]);
            }
        } else if(trigger.isUpdate) {
            if(trigger.new[i].ProfileId != trigger.old[i].ProfileId && trigger.new[i].ProfileId == Label.neuer_standardbenutzer_id) {
                usersToAdd.add(trigger.new[i]);
            }
        }
    }
    
    if(!usersToAdd.isEmpty()) {
        List<GroupMember> groupMembers = new List<GroupMember>();
        for(User u : usersToAdd) {
            GroupMember gm = new GroupMember();
            gm.GroupId = Label.csm_team_id;
            gm.UserOrGroupId = u.Id;
            groupMembers.add(gm);
        }
        try {
            insert groupMembers;
        } catch(Exception e) {
            System.Debug('Error inserting new group members: ' + e.getMessage());
        }
    }
}
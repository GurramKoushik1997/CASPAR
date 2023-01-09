@isTest
private class UserTrigger_TEST {

    private static User u1, u2;
    
    private static testMethod void init() {
        u1 = new User(
            Alias = 'standt',
            Email='standardu@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='de',
            LocaleSidKey='de',
            ProfileId = Label.neuer_standardbenutzer_id,
            TimeZoneSidKey='Europe/Berlin',
            UserName='standardu@testorg.com'
        );
        insert u1;
        
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND Id != :Label.neuer_standardbenutzer_id LIMIT 1];
        
        u2 = new User(
            Alias = 'stan2',
            Email='standardu2@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing2',
            LanguageLocaleKey='de',
            LocaleSidKey='de',
            ProfileId = p.Id,
            TimeZoneSidKey='Europe/Berlin',
            UserName='standardu2@testorg.com'
        );
        insert u2;
    }
    
    private static testMethod void testAddUserToPublicGroup() {
        List<GroupMember> groupMembers = [SELECT Id FROM GroupMember];
        
        test.startTest();
        
        init();
        u2.ProfileId = Label.neuer_standardbenutzer_id;
        update u2;
        
        test.stopTest();
        
        List<GroupMember> groupMembers2 = [SELECT Id FROM GroupMember];
        
        System.assertEquals(groupMembers.size() + 2, groupMembers2.size());
    }
    
}
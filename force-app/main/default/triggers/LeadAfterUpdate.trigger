trigger LeadAfterUpdate on Lead (after update) {

    List<Lead> lLead = new List<Lead>();
    List<Database.LeadConvert> lLc = new List<Database.LeadConvert>();
    
    // Saves Lead with E-Mails to map with Accounts and Contacts 
    Map<String, Lead> mapMailLead = new Map<String, Lead>();
    
    // Saves Lead with Phone to map with Accounts and Contacts 
    Map<String, Lead> mapPhoneLead = new Map<String, Lead>();
    
    for(Integer i=0; i < trigger.new.size(); i++) {
        if(!Trigger.new[i].IsConverted && Trigger.new[i].Status == 'Prospect' && Trigger.old[i].Status != 'Prospect') {
           		Lead lead = trigger.new[i];
        		lLead.add(lead);
        		if(lead.Email != null) {
            		mapMailLead.put(lead.Email, lead);
        		}
               	else if(lead.Phone != null) {
                   mapPhoneLead.put(lead.Phone, lead);
               	}
           }
    }
    
    // get associated Contacts from E-Mail and Phone
    Map<Lead, Contact> mapLeadContact = new Map<Lead,Contact>();
    for(Contact c : [SELECT Id, Email, Account.Id From Contact WHERE Email IN :mapMailLead.keySet()]) {
        mapLeadContact.put(mapMailLead.get(c.Email), c);
    }
    // TODO: Telefon zu Zahlenfolge 
    for(Contact c : [SELECT Id, Phone, Account.Id From Contact WHERE Phone IN :mapPhoneLead.keySet()]) {
        mapLeadContact.put(mapPhoneLead.get(c.Phone), c);
    }
    
    // get asscoiated Accounts from E-Mail-Domain and Phone:
    Map<Lead, String> mapLeadAccountId = new Map<Lead, String>();

    // get domains for Accounts
    Map<String, Lead> mapDomainLead = new Map<String, Lead>();
    for(Lead lead: mapMailLead.values()) {
        // only look at leads who are not already associated with a contact
        if(!mapLeadContact.containsKey(lead)) {
            String mail = lead.Email;
            String domain = mail.split('@')[1];
            System.debug(domain);
            mapDomainLead.put('%' + domain, lead);
        }
    }
    
    // map lead To AccountId depending on domain
    for(Contact c : [SELECT AccountId, Email From Contact Where Email LIKE :mapDomainLead.keySet()]) {
        String domain = '%' + c.Email.split('@')[1];
        Lead lead = mapDomainLead.get(domain);
        if(!mapLeadAccountId.containsKey(lead)) {
            System.debug(lead.Id + ' ' + c.AccountId);
            mapLeadAccountId.put(lead, c.AccountId);
        }
    }
    
    // map lead To AccountId depending on phone
    for(Account acc : [SELECT Id, Phone FROM Account WHERE Phone in :mapPhoneLead.keySet()]) {
        Lead lead = mapPhoneLead.get(acc.Phone);
        // only look at leads who are not already associated with a contact
        if(!mapLeadContact.containsKey(lead)) {
            mapLeadAccountId.put(lead, acc.Id);
        }
    }
       
    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                
    for(Lead lead: lLead) {
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.id);
        System.debug(mapLeadAccountId.size() + ' accs ' + mapLeadContact.size() + ' cons');
        System.debug(mapLeadAccountId.get(lead));
        // Tells LeadConvert to merge with eigther Account or Contact
        if(mapLeadAccountId.containsKey(lead)) {
            lc.setAccountId(mapLeadAccountId.get(lead));
            System.debug(lead.Id + ' ' + lc.getAccountId());
        }
        else if(mapLeadContact.containsKey(lead)) {
            lc.setAccountId(mapLeadContact.get(lead).AccountId);
            lc.setContactId(mapLeadContact.get(lead).id);
            
        }
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lLc.add(lc);
    }
    
    if(!lLc.isEmpty()) {
        List<Database.LeadConvertResult> lcr = Database.convertLead(lLc);
    }      
}
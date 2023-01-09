trigger contractTrigger on Contract (before insert, before update) {
    Id beitrittserklaerungCustomizedRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Beitrittserklaerung_Customized').getRecordTypeId();
    Id beitrittserklaerungStandardRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Beitrittserklaerung_STD').getRecordTypeId();
    Id rahmenvertragRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Rahmenvertrag').getRecordTypeId();
    Set<Id> accountIds = new Set<Id>();
    Map<id, List<Contract>> accountIdWithContracts = new Map<id, List<Contract>>();
    
    for(Contract c : trigger.new){
        if(c.Account.ParentId == null) continue;
        accountIds.add(c.Account.ParentId);
    }
    List<Contract> RahmenvertragContract = 
        [SELECT Id, Account.ParentId, StartDate, EndDate FROM Contract WHERE RecordTypeId =:rahmenvertragRecordTypeId AND Account.ParentId IN :accountIds limit 1];
    for(Contract con : RahmenvertragContract){
        if(con.Account.ParentId == null) continue;
        if(accountIdWithContracts.containsKey(con.Account.ParentId)){
            List<Contract> contracts = accountIdWithContracts.get(con.Account.ParentId);
            contracts.add(con);
            accountIdWithContracts.put(con.Account.ParentId, contracts);
        }
        else{
            List<Contract> contracts = new List<Contract>();
            contracts.add(con);
            accountIdWithContracts.put(con.Account.ParentId, contracts);
        }
        
    }
    for(Contract c : trigger.new){
        if(c.Account.ParentId == null) continue;
        if(!accountIdWithContracts.containsKey(c.Account.ParentId)) continue;
        List<Contract> accountRahmenvertragContract = accountIdWithContracts.get(c.Account.ParentId);
        if(c.RecordTypeId == beitrittserklaerungCustomizedRecordTypeId || c.RecordTypeId == beitrittserklaerungStandardRecordTypeId)
        {
            if(accountRahmenvertragContract[0].StartDate >= c.StartDate)
            {
                c.addError('start date error');
            }
            else if(accountRahmenvertragContract[0].EndDate <= c.EndDate){
                c.addError('end date error');
            }
        }
    }
}
public class QuoteGenerator_CtrlExt {

    public Opportunity opp {get;set;}
    
    public QuoteGenerator_CtrlExt(ApexPages.StandardController sc) {
        opp = (Opportunity) sc.getRecord();
    }
    
    public PageReference generate() {
        opp = [SELECT Id, Name FROM Opportunity WHERE Id = :opp.Id];
        PageReference pdf = new PageReference('/apex/QuotePdf?id=' + opp.Id);
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
        contentVersion.PathOnClient = 'Angebot ' + opp.Name + '.pdf';
        contentVersion.Title = 'Angebot ' + opp.Name + '.pdf';
        if(Test.isRunningTest()) {
            contentVersion.VersionData = Blob.valueOf('Test');
        } else {
            contentVersion.VersionData = pdf.getContent();
        }
        insert contentVersion;
        
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = cv.ContentDocumentId;
        contentDocumentLink.LinkedEntityId = opp.Id;
        contentDocumentLink.ShareType = 'I'; // Inferred permission
        insert contentDocumentLink;
        
        return new PageReference('/' + opp.Id);
    }
    
}
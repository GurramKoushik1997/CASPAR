public class QuotePDF_CtrlExt {
    
    public String quoteDate {get;set;}
    public String startDate {get;set;}
    public String validityDate {get;set;}
    
    public Opportunity opp {get;set;}
    public List<OpportunityLineItem> oli1 {get;set;}
    public List<OpportunityLineItem> oli2 {get;set;}
    public List<OpportunityLineItem> oli3 {get;set;}
    public List<OpportunityContactRole> clientContact {get;set;}

    public QuotePDF_CtrlExt(ApexPages.StandardController sc) {
        opp = (Opportunity) sc.getRecord();
        init();
    }
    
    private void init() {
        opp = [
            SELECT Id, Name, Vertragsbeginn__c, G_ltigkeit_des_Angebots__c, Zusatzinformationen_Template__c, Zahlungsmodalit_ten__c,Vertragslaufzeit_in_Monaten__c,
            Account.Name, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCity,
            Owner.Name, Owner.Title, Owner.Phone, Owner.Email
            FROM Opportunity
            WHERE Id = :opp.Id
        ];
        
        quoteDate = toGermanDate(Date.today());
        startDate = toGermanDate(opp.Vertragsbeginn__c);
        validityDate = toGermanDate(opp.G_ltigkeit_des_Angebots__c);
        
        oli1 = [
            SELECT Id, Product2.Name, St_ckpreis__c, UnitPrice, TotalPrice, Discount, Product2.Description, Quantity, Zahlungsmodalit_ten__c
            FROM OpportunityLineItem
            WHERE OpportunityId = :opp.Id AND Zahlungsmodalit_ten__c = 'monatlich'
            ORDER BY CreatedDate ASC
        ];
        
        oli2 = [
            SELECT Id, Product2.Name, St_ckpreis__c, UnitPrice, TotalPrice, Discount, Product2.Description, Quantity, Zahlungsmodalit_ten__c
            FROM OpportunityLineItem
            WHERE OpportunityId = :opp.Id AND Zahlungsmodalit_ten__c = 'variabel'
            ORDER BY CreatedDate ASC
        ];
        
        oli3 = [
            SELECT Id, Product2.Name, St_ckpreis__c, UnitPrice, TotalPrice, Discount, Product2.Description, Quantity, Zahlungsmodalit_ten__c
            FROM OpportunityLineItem
            WHERE OpportunityId = :opp.Id AND Zahlungsmodalit_ten__c = 'einmalig'
            ORDER BY CreatedDate ASC
        ];
        
        clientContact = [
            SELECT Id, Contact.Name, Contact.Gender__c FROM OpportunityContactRole WHERE OpportunityId = :opp.Id AND Role = 'Client'
        ];
    }
    
    public List<Product> getProducts1() {
        List<Product> products = new List<Product>();
        for(OpportunityLineItem oli : oli1) {
            Product product = new Product(oli);
            product.listPrice = toGermanCurrency(oli.UnitPrice);
            product.unitPrice = toGermanCurrency(oli.St_ckpreis__c);
            if(oli.Product2.Description != null) {
                product.specs = oli.Product2.Description.split('###');
            }
            products.add(product);
        }
        return products;
    }
    
    public List<Product> getProducts2() {
        List<Product> products = new List<Product>();
        for(OpportunityLineItem oli : oli2) {
            Product product = new Product(oli);
            product.listPrice = toGermanCurrency(oli.UnitPrice);
            product.unitPrice = toGermanCurrency(oli.St_ckpreis__c);
            if(oli.Product2.Description != null) {
                product.specs = oli.Product2.Description.split('###');
            }
            products.add(product);
        }
        return products;
    }
    
    public List<Product> getProducts3() {
        List<Product> products = new List<Product>();
        for(OpportunityLineItem oli : oli3) {
            Product product = new Product(oli);
            product.listPrice = toGermanCurrency(oli.UnitPrice);
            product.unitPrice = toGermanCurrency(oli.St_ckpreis__c);
            if(oli.Product2.Description != null) {
                product.specs = oli.Product2.Description.split('###');
            }
            products.add(product);
        }
        return products;
    }
    
    public Decimal getOli1ListPrice() {
        Decimal d = 0;
        for(OpportunityLineItem oli : oli1) {
            d += oli.UnitPrice * oli.Quantity;
        }
        return d;
    }
    
    public String getOli1ListPriceCurrency() {
        return toGermanCurrency(getOli1ListPrice());
    }
    
    public Decimal getOli1TotalAmount() {
        Decimal d = 0;
        for(OpportunityLineItem oli : oli1) {
            d += oli.St_ckpreis__c * oli.Quantity;
        }
        return d;
    }
    
    public String getOli1TotalAmountCurrency() {
        return toGermanCurrency(getOli1TotalAmount());
    }
    
    public Decimal getOli1Discount() {
        return getOli1TotalAmount() - getOli1ListPrice();
    }
    
    public Decimal getOli2ListPrice() {
        Decimal d = 0;
        for(OpportunityLineItem oli : oli2) {
            d += oli.UnitPrice * oli.Quantity;
        }
        return d;
    }
    
    public String getOli2ListPriceCurrency() {
        return toGermanCurrency(getOli2ListPrice());
    }
    
    public Decimal getOli2TotalAmount() {
        Decimal d = 0;
        for(OpportunityLineItem oli : oli2) {
            d += oli.St_ckpreis__c * oli.Quantity;
        }
        return d;
    }
    
    public String getOli2TotalAmountCurrency() {
        return toGermanCurrency(getOli2TotalAmount());
    }
    
    public Decimal getOli2Discount() {
        return getOli2TotalAmount() - getOli2ListPrice();
    }
    
    public Decimal getOli3ListPrice() {
        Decimal d = 0;
        for(OpportunityLineItem oli : oli3) {
            d += oli.UnitPrice * oli.Quantity;
        }
        return d;
    }
    
    public String getOli3ListPriceCurrency() {
        return toGermanCurrency(getOli3ListPrice());
    }
    
    public Decimal getOli3TotalAmount() {
        Decimal d = 0;
        for(OpportunityLineItem oli : oli3) {
            d += oli.St_ckpreis__c * oli.Quantity;
        }
        return d;
    }
    
    public String getOli3TotalAmountCurrency() {
        return toGermanCurrency(getOli3TotalAmount());
    }
    
    public Decimal getOli3Discount() {
        return getOli3TotalAmount() - getOli3ListPrice();
    }
    
    private String toGermanDate(Date d) {
        String s = '';
        
        if(d != null) {
            if(d.day() < 10) {
                s += '0';
            }
            s += String.valueOf(d.day()) + '.';
            if(d.month() < 10) {
                s += '0';
            }
            s += String.valueOf(d.month()) + '.' + String.valueOf(d.year());
        }
            
        return s;
    }
    
    public String toGermanCurrency(Decimal d) {
        String s = '';
        
        List<String> parts = String.valueOf(d).split('\\.');

        if(parts[0].length() == 7) {
            s = parts[0].substring(0,1) + '.' + parts[0].substring(1,4) + '.' + parts[0].substring(4,7);
        } else if(parts[0].length() == 4) {
            s = parts[0].substring(0,1) + '.' + parts[0].substring(1);
        } else {
            s = parts[0];
        }
        
        s += ',';
        
        if(parts.size() == 2) {
            if(Integer.valueOf(parts[1]) == 0) {
                s += '00';
            } else {
                s += parts[1].substring(0,2);
            }
        } else {
            s += '00';
        }
        
        return s;
    }
    
    public class Product {
        public OpportunityLineItem oli {get;set;}
        public List<String> specs {get;set;}
        public String unitPrice {get;set;}
        public String listPrice {get;set;}
        
        public Product(OpportunityLineItem oli) {
            this.oli = oli;
            specs = new List<String>();
        }
    }
}
@isTest
private class MarginTriggerHelper_Test {
    @TestSetup
    static void makeData(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        AccountGroup__c accountGroup = (AccountGroup__c) testFactory.createSObject(new AccountGroup__c());
        insert accountGroup;

        Account account = (Account) testFactory.createSObject(new Account(AccountGroup__c = accountGroup.Id));
        insert account;

        Contact contact = (Contact) testFactory.createSObject(new Contact(AccountId = account.Id));
        insert contact;

        Country__c country = (Country__c) testFactory.createSObject(new Country__c());
        insert country;

        State__c state = (State__c) testFactory.createSObject(new State__c(Country__c = country.Id));
        insert state;

        City__c city = (City__c) testFactory.createSObject(new City__c(State__c = state.Id));
        insert city;

        DistributionCenter__c distributionCenter = (DistributionCenter__c) testFactory.createSObject(new DistributionCenter__c());
        insert distributionCenter;

        ProductHierarchy__c productHierarchy = (ProductHierarchy__c) testFactory.createSObject(new ProductHierarchy__c());
        insert productHierarchy;

        Product2 product = (Product2) testFactory.createSObject(new Product2(ProductHierarchy__c = productHierarchy.Id));
        insert product;

        Margin__c margin = (Margin__c) testFactory.createSObject(new Margin__c(
            Product__c = product.Id,
            Account__c = account.Id,
            City__c = city.Id,
            DistributionCenter__c = distributionCenter.Id,
            Value__c = 10));
        insert margin;
    }

    @isTest
    static void testInsertTwoDistinctMargins() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        City__c city = [SELECT Id, State__c FROM City__c LIMIT 1];
        DistributionCenter__c distributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Margin__c margin = [SELECT Id FROM Margin__c LIMIT 1];
        margin.City__c = null;
        margin.State__c = city.State__c;
        margin.Value__c = 15;

        Database.SaveResult result = Database.insert(margin, false);

        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
    }

    @isTest
    static void testInsertTwoDuplicateMargins() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        City__c city = [SELECT Id FROM City__c LIMIT 1];
        DistributionCenter__c distributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Margin__c margin = [SELECT Id FROM Margin__c LIMIT 1];

        Database.SaveResult result = Database.insert(margin, false);

        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Duplicate margin found', result.getErrors()[0].getMessage());
    }
}
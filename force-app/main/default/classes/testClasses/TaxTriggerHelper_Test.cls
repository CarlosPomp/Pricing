@isTest
private class TaxTriggerHelper_Test {
    @TestSetup
    static void makeData(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

        Country__c country = (Country__c) testFactory.createSObject(new Country__c());
        insert country;

        State__c state1 = (State__c) testFactory.createSObject(new State__c(Country__c = country.Id));
        State__c state2 = (State__c) testFactory.createSObject(new State__c(Country__c = country.Id));
        insert new List<State__c>{state1, state2};

        DistributionCenter__c distributionCenter = (DistributionCenter__c) testFactory.createSObject(new DistributionCenter__c());
        insert distributionCenter;

        ProductHierarchy__c productHierarchy = (ProductHierarchy__c) testFactory.createSObject(new ProductHierarchy__c());
        insert productHierarchy;

        Product2 product1 = (Product2) testFactory.createSObject(new Product2(ProductHierarchy__c = productHierarchy.Id));
        Product2 product2 = (Product2) testFactory.createSObject(new Product2(ProductHierarchy__c = productHierarchy.Id));
        insert new List<Product2>{product1, product2};

        Tax__c tax1 = (Tax__c) testFactory.createSObject(new Tax__c(
            Product__c = product1.Id,
            State__c = state1.Id,
            DistributionCenter__c = distributionCenter.Id,
            TaxPercentage__c = 10));
        
        Tax__c tax2 = (Tax__c) testFactory.createSObject(new Tax__c(
            Product__c = product2.Id,
            State__c = state2.Id,
            DistributionCenter__c = distributionCenter.Id,
            TaxPercentage__c = 12));
        
        insert new List<Tax__c>{tax1, tax2};
    }

    @isTest
    static void testInsertTwoDistinctTaxes() {
        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product Test 5' LIMIT 1];
        State__c state = [SELECT Id FROM State__c WHERE Acronym__c = '2' LIMIT 1];
        DistributionCenter__c distributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];

        Tax__c tax = new Tax__c();

        tax.Product__c = product.Id;
        tax.State__c = state.Id;
        tax.DistributionCenter__c = distributionCenter.Id;
        tax.Status__c = 'Approved';
        tax.TaxPercentage__c = 15;

        Database.SaveResult result = Database.insert(tax, false);

        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
    }

    @isTest
    static void testInsertTwoDuplicateTaxes() {
        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product Test 5' LIMIT 1];
        State__c state = [SELECT Id FROM State__c WHERE Acronym__c = '1' LIMIT 1];
        DistributionCenter__c distributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];

        Tax__c tax = new Tax__c();
        tax.Product__c = product.Id;
        tax.State__c = state.Id;
        tax.DistributionCenter__c = distributionCenter.Id;
        tax.TaxPercentage__c = 15;

        Database.SaveResult result = Database.insert(tax, false);

        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('There is already a tax for this product and state.', result.getErrors()[0].getMessage());
    }

    @isTest
    static void testUpdateIntoADuplicateTax() {
        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product Test 5' LIMIT 1];
        State__c state = [SELECT Id FROM State__c WHERE Acronym__c = '1' LIMIT 1];
        DistributionCenter__c distributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];

        Tax__c tax = [SELECT Id FROM Tax__c WHERE TaxPercentage__c = 12 LIMIT 1];
        tax.Product__c = product.Id;
        tax.State__c = state.Id;
        tax.DistributionCenter__c = distributionCenter.Id;

        Database.SaveResult result = Database.update(tax, false);

        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('There is already a tax for this product and state.', result.getErrors()[0].getMessage());
    }
}
@isTest
private class ShippingFeeTriggerHelper_Test {
    @TestSetup
    static void makeData(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();

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

        ShippingFee__c fee1 = (ShippingFee__c) testFactory.createSObject(new ShippingFee__c(
            Product__c = product.Id,
            City__c = city.Id,
            DistributionCenter__c = distributionCenter.Id,
            Value__c = 10));
        
        ShippingFee__c fee2 = (ShippingFee__c) testFactory.createSObject(new ShippingFee__c(
            ProductHierarchy__c = productHierarchy.Id,
            City__c = city.Id,
            DistributionCenter__c = distributionCenter.Id,
            Value__c = 12));
        
        insert new List<ShippingFee__c>{fee1, fee2};
    }

    @isTest
    static void testInsertTwoDistinctShippingFees() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        City__c city = [SELECT Id, State__c FROM City__c LIMIT 1];
        DistributionCenter__c distributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];

        ShippingFee__c fee = new ShippingFee__c();

        fee.Product__c = product.Id;
        fee.State__c = city.State__c;
        fee.DistributionCenter__c = distributionCenter.Id;
        fee.Status__c = 'Approved';
        fee.Value__c = 15;

        Database.SaveResult result = Database.insert(fee, false);

        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
    }

    @isTest
    static void testInsertTwoDuplicateShippingFees() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        City__c city = [SELECT Id FROM City__c LIMIT 1];
        DistributionCenter__c distributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];

        ShippingFee__c fee = new ShippingFee__c();
        fee.Product__c = product.Id;
        fee.City__c = city.Id;
        fee.DistributionCenter__c = distributionCenter.Id;
        fee.Value__c = 15;

        Database.SaveResult result = Database.insert(fee, false);

        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Duplicate shipping fee found.', result.getErrors()[0].getMessage());
    }

    @isTest
    static void testUpdateIntoADuplicateShippingFee() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        City__c city = [SELECT Id FROM City__c LIMIT 1];
        DistributionCenter__c distributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];

        ShippingFee__c fee = [SELECT Id FROM ShippingFee__c WHERE Value__c = 12 LIMIT 1];
        fee.Product__c = product.Id;
        fee.City__c = city.Id;
        fee.DistributionCenter__c = distributionCenter.Id;

        Database.SaveResult result = Database.update(fee, false);

        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Duplicate shipping fee found.', result.getErrors()[0].getMessage());
    }
}
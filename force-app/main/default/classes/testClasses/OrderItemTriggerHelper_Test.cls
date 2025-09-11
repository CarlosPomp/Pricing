@isTest
private class OrderItemTriggerHelper_Test {
    @TestSetup
    static void makeData(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();
		Id pricebookId = TestFactorySObject.getStandardPricebookId();

        ProductHierarchy__c productHierarchy = (ProductHierarchy__c) testFactory.createSObject(new ProductHierarchy__c());
        insert productHierarchy;

        Product2 product = (Product2) testFactory.createSObject(new Product2(ProductHierarchy__c = productHierarchy.Id, ProductionCost__c = 25));
        insert product;

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

        AccountAddress__c accountAddress = (AccountAddress__c) testFactory.createSObject(new AccountAddress__c(Account__c = account.Id, City__c = city.Id));
        insert accountAddress;

        PayCondition__c payCondition = (PayCondition__c) testFactory.createSObject(new PayCondition__c());
        insert payCondition;

        DistributionCenter__c distributionCenter = (DistributionCenter__c) testFactory.createSObject(new DistributionCenter__c());
        insert distributionCenter;

        Order order = (Order) testFactory.createSObject(new Order(
            AccountId = account.Id,
            Address__c = accountAddress.Id,
            ContactName__c = contact.Id,
            DistributionCenter__c = distributionCenter.Id,
            PayCondition__c = payCondition.Id,
        	Pricebook2Id = pricebookId));
        insert order;

        PricebookEntry pricebookEntry = (PricebookEntry) testFactory.createSObject(new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id));
        insert pricebookEntry;

        Margin__c margin = (Margin__c) testFactory.createSObject(new Margin__c(
            Product__c = product.Id,
            Account__c = account.Id,
            City__c = city.Id,
            DistributionCenter__c = distributionCenter.Id,
            Value__c = 10));
        insert margin;

        ShippingFee__c fee = (ShippingFee__c) testFactory.createSObject(new ShippingFee__c(
            Product__c = product.Id,
            City__c = city.Id,
            DistributionCenter__c = distributionCenter.Id,
            Value__c = 15));
        insert fee;

        Tax__c tax = (Tax__c) testFactory.createSObject(new Tax__c(
            Product__c = product.Id,
            State__c = state.Id,
            DistributionCenter__c = distributionCenter.Id,
            TaxPercentage__c = 7));
        insert tax;
    }

    @IsTest
    static void testInsertOrderItem() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        OrderItem orderItem = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = pricebookEntry.Id,
            Product2Id = product.Id,
            Quantity = 1,
            UnitPrice = 40);
        Database.SaveResult result = Database.insert(orderItem, false);

        System.assertEquals(47.08, orderItem.FullPrice__c);
    }
}
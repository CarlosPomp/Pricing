@isTest
private class OrderTriggerHelper_Test {
    @TestSetup
    static void makeData(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();
		Id pricebookId = TestFactorySObject.getStandardPricebookId();

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

        ProductHierarchy__c productHierarchy = (ProductHierarchy__c) testFactory.createSObject(new ProductHierarchy__c());
        insert productHierarchy;

        Product2 product = (Product2) testFactory.createSObject(new Product2(ProductHierarchy__c = productHierarchy.Id));
        insert product;

        PricebookEntry pricebookEntry = (PricebookEntry) testFactory.createSObject(new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id));
        insert pricebookEntry;

        OrderItem orderItem = (OrderItem) testFactory.createSObject(new OrderItem(OrderId = order.Id, Product2Id = product.Id, PricebookEntryId = pricebookEntry.Id));
        OrderItemTriggerHandler.disableTrigger();
        insert orderItem;
    }

    @isTest
    static void testUpdateApprovedOrder() {
        Order order = [SELECT Id, Status FROM Order LIMIT 1];

        order.Status = 'Approved';

        Database.update(order, true);
        
        order.FreightType__c = 'FOB';
        
        Database.SaveResult result = Database.update(order, true);

        System.Assert.isTrue(!result.isSuccess());
        System.Assert.isTrue(result.getErrors().size() > 0);
        System.assertEquals('Cannot modify activated order',
            result.getErrors()[0].getMessage());
    }
}
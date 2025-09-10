@isTest
private class AccountTriggerHelper_Test {
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
            PayCondition__c = payCondition.Id));
        insert order;
    }

    @isTest
    static void testUpdateAccountWithOrder() {
        Account account = [SELECT Id, Active__c FROM Account LIMIT 1];
        account.Active__c = 'Yes';
        Database.SaveResult result = Database.update(account);

        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Cannot update account with orders',
            result.getErrors()[0].getMessage());
    }
}
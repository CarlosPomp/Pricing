public with sharing class AccountTriggerHelper {
    public static void verifyOrders(List<Account> newRecordList) {
        Set<Id> selfIds = new Set<Id>();

        for (Account account : newRecordList) {
            selfIds.add(account.Id);
        }

        List<Order> ordersPresent = [SELECT Id, AccountId FROM Order WHERE AccountId IN :selfIds];
        Set<Id> accountOrderIds = new Set<Id>();

        for (Order order : ordersPresent) {
            accountOrderIds.add(order.AccountId);
        }

        for (Account account : newRecordList) {
            if (accountOrderIds.contains(account.Id)) {
                account.addError('Cannot update account with orders');
            }
        }
    }
}
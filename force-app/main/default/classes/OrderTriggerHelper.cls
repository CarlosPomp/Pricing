public with sharing class OrderTriggerHelper {
    public OrderTriggerHelper() {}

    public static void verifyActivation(List<Order> newRecordList) {
        List<Order> orders = [SELECT Id, Status FROM Order WHERE Id IN :newRecordList];
        for (Order order : orders) {
            if (order.Status != 'Draft' || order.Status != 'In Progress') {
                order.addError('Cannot modify activated order');
            }
        }
    }
}
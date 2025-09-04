public with sharing class AccountTriggerHandler {
    private static Boolean isEnabled;
	static {
		isEnabled = true;
	}
	public static Boolean isTriggerEnabled() {
		return isEnabled;
	}
	public static Boolean disableTrigger() {
		return isEnabled = false;
	}
	public static Boolean enableTrigger() {
		return isEnabled = true;
	}

    List<Account> oldRecordList { get; set; }
    List<Account> newRecordList { get; set; }

    public AccountTriggerHandler(List<Account> oldRecordList, List<Account> newRecordList) {
        this.oldRecordList = oldRecordList;
        this.newRecordList = newRecordList;
    }

    private void verifyOrders() {
        Set<Id> selfIds = new Set<Id>();

        for (Account account : this.newRecordList) {
            selfIds.add(account.Id);
        }

        List<Order> ordersPresent = [SELECT Id, AccountId FROM Order WHERE AccountId IN :selfIds];
        Set<Id> accountOrderIds = new Set<Id>();

        for (Order order : ordersPresent) {
            accountOrderIds.add(order.AccountId);
        }

        for (Account account : this.newRecordList) {
            if (accountOrderIds.contains(account.Id)) {
                account.addError('Cannot delete account with orders');
            }
        }
    }

    public void beforeUpdate() {
        this.verifyOrders();
    }
}
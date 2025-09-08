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

    public void beforeUpdate() {
        AccountTriggerHelper.verifyOrders(this.newRecordList);
    }
}
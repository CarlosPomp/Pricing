public with sharing class OrderTriggerHandler {
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

    List<Order> oldRecordList { get; set; }
	List<Order> newRecordList { get; set; }

    public OrderTriggerHandler(List<Order> oldRecordList, List<Order> newRecordList) {
        this.oldRecordList = oldRecordList;
        this.newRecordList = newRecordList;
    }

    public void beforeUpdate() {
        OrderTriggerHelper.verifyActivation(this.newRecordList);
    }
}
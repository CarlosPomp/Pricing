public with sharing class OrderItemTriggerHandler {
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

    List<OrderItem> oldRecordList { get; set; }
	List<OrderItem> newRecordList { get; set; }

    public OrderItemTriggerHandler(List<OrderItem> oldRecordList, List<OrderItem> newRecordList) {
        this.oldRecordList = oldRecordList;
        this.newRecordList = newRecordList;
    }

    public void beforeInsert() {
        OrderItemTriggerHelper.handleTrigger(newRecordList);
    }

    public void beforeUpdate() {
        OrderItemTriggerHelper.handleTrigger(newRecordList);
    }
}
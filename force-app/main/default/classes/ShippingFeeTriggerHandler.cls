public with sharing class ShippingFeeTriggerHandler {
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

    List<ShippingFee__c> oldRecordList { get; set; }
	List<ShippingFee__c> newRecordList { get; set; }

    public ShippingFeeTriggerHandler(List<ShippingFee__c> oldRecordList, List<ShippingFee__c> newRecordList) {
        this.oldRecordList = oldRecordList;
        this.newRecordList = newRecordList;
    }

    public void beforeInsert() {
        ShippingFeeTriggerHelper.validateNoDuplicate(this.oldRecordList, this.newRecordList);
    }

    public void beforeUpdate() {
        ShippingFeeTriggerHelper.validateNoDuplicate(this.oldRecordList, this.newRecordList);
    }
}
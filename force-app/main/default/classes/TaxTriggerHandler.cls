public with sharing class TaxTriggerHandler {
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

    List<Tax__c> oldRecordList { get; set; }
	List<Tax__c> newRecordList { get; set; }

    public TaxTriggerHandler(List<Tax__c> oldRecordList, List<Tax__c> newRecordList) {
        this.oldRecordList = oldRecordList;
        this.newRecordList = newRecordList;
    }

    public void beforeInsert() {
        TaxTriggerHelper.validateNoDuplicate(this.oldRecordList, this.newRecordList);
    }

    public void beforeUpdate() {
        TaxTriggerHelper.validateNoDuplicate(this.oldRecordList, this.newRecordList);
    }
}
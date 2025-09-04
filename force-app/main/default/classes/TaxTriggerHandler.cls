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

    private void validateNoDuplicate() {
        Set<Id> setIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();

        if (this.oldRecordList != null) {
            for (Tax__c tax : this.oldRecordList) {
                setIds.add(tax.Id);
            }
        }

        for (Tax__c tax : this.newRecordList) {
            productIds.add(tax.Product__c);
            stateIds.add(tax.State__c);
        }

        List<Tax__c> existingTaxes = [SELECT Id, Product__c, State__c FROM Tax__c WHERE Product__c IN :productIds AND State__c IN :stateIds AND Id NOT IN :setIds];
        Map<Id, List<Id>> existingTaxesMap = new Map<Id, List<Id>>();

        for (Tax__c tax : existingTaxes) {
            if (!existingTaxesMap.containsKey(tax.Product__c)) {
                existingTaxesMap.put(tax.Product__c, new List<Id>());
            }
            existingTaxesMap.get(tax.Product__c).add(tax.State__c);
        }

        for (Tax__c tax : this.newRecordList) {
            if (tax.Product__c == null) {
                tax.addError('This field is required.');
            }

            if (existingTaxesMap.containsKey(tax.Product__c) && existingTaxesMap.get(tax.Product__c).contains(tax.State__c)) {
                tax.addError('There is already a tax for this product and state.');
            }
        }
    }

    public void beforeInsert() {
        this.validateNoDuplicate();
    }

    public void beforeUpdate() {
        this.validateNoDuplicate();
    }
}
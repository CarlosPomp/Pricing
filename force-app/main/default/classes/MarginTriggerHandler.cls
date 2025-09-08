public with sharing class MarginTriggerHandler {
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

    List<Margin__c> oldRecordList { get; set; }
	List<Margin__c> newRecordList { get; set; }

    public MarginTriggerHandler(List<Margin__c> oldRecordList, List<Margin__c> newRecordList) {
        this.oldRecordList = oldRecordList;
        this.newRecordList = newRecordList;
    }

    private void validateNoDuplicate() {
        Set<Id> selfIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> locationIds = new Set<Id>();

        for (Margin__c margin : this.newRecordList) {
            if (margin.Product__c != null) {
                productIds.add(margin.Product__c);
            } else {
                productIds.add(margin.Product_Hierarchy__c);
            }
            if (margin.Account__c != null) {
                accountIds.add(margin.Account__c);
            } else {
                accountIds.add(margin.AccountGroup__c);
            }
            if (margin.City__c != null) {
                locationIds.add(margin.City__c);
            } else if (margin.State__c != null) {
                locationIds.add(margin.State__c);
            } else {
                locationIds.add(margin.Country__c);
            }
        }

        if (this.oldRecordList != null) {
            for (Margin__c margin : this.oldRecordList) {
                selfIds.add(margin.Id);
            }
        }

        List<Margin__c> existingMargins = [SELECT Id, Product__c, Product_Hierarchy__c, Account__c, AccountGroup__c, City__c, State__c, Country__c FROM Margin__c 
            WHERE (Product__c IN :productIds OR Product_Hierarchy__c IN :productIds)
            AND (Account__c IN :accountIds OR AccountGroup__c IN :accountIds)
            AND (City__c IN :locationIds OR State__c IN :locationIds OR Country__c IN :locationIds)
            AND Id NOT IN :selfIds];
        if (existingMargins.size() == 0) { return; }

        Map<String, List<Margin__c>> existingMarginsProductMap = new Map<String, List<Margin__c>>();
        Id key;
        Id accountKey;
        String productPlusAccountKey;

        for (Margin__c margin : existingMargins) {
            if (margin.Product__c != null) {
                key = margin.Product__c;
            } else {
                key = margin.Product_Hierarchy__c;
            }
            if (margin.Account__c != null) {
                accountKey = margin.Account__c;
            } else {
                accountKey = margin.AccountGroup__c;
            }
            productPlusAccountKey = String.valueOf(key) + '-' + accountKey;
            if (!existingMarginsProductMap.containsKey(productPlusAccountKey)) {
                existingMarginsProductMap.put(productPlusAccountKey, new List<Margin__c>());
            }
            existingMarginsProductMap.get(productPlusAccountKey).add(margin);
        }
        
        for (Margin__c newMargin : this.newRecordList) {
            if (newMargin.Product__c != null) {
                key = newMargin.Product__c;
            } else {
                key = newMargin.Product_Hierarchy__c;
            }
            if (newMargin.Account__c != null) {
                accountKey = newMargin.Account__c;
            } else {
                accountKey = newMargin.AccountGroup__c;
            }
            productPlusAccountKey = String.valueOf(key) + '-' + accountKey;
            for (Margin__c existingMargin : existingMarginsProductMap.get(productPlusAccountKey)) {
                if (newMargin.City__c == existingMargin.City__c &&
                    newMargin.State__c == existingMargin.State__c &&
                    newMargin.Country__c == existingMargin.Country__c) {

                    newMargin.addError('Duplicate shipping fee found.');
                }
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
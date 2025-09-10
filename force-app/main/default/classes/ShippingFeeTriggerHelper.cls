public with sharing class ShippingFeeTriggerHelper {
    public static void validateNoDuplicate(List<ShippingFee__c> oldRecordList, List<ShippingFee__c> newRecordList) {
        Set<Id> selfIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> locationIds = new Set<Id>();

        for (ShippingFee__c fee : newRecordList) {
            if (fee.Product__c != null) {
                productIds.add(fee.Product__c);
            } else {
                productIds.add(fee.ProductHierarchy__c);
            }
            if (fee.City__c != null) {
                locationIds.add(fee.City__c);
            } else if (fee.State__c != null) {
                locationIds.add(fee.State__c);
            } else {
                locationIds.add(fee.Country__c);
            }
        }

        if (oldRecordList != null) {
            for (ShippingFee__c fee : oldRecordList) {
                selfIds.add(fee.Id);
            }
        }

        List<ShippingFee__c> existingFees = [SELECT Id, Product__c, ProductHierarchy__c, City__c, State__c, Country__c FROM ShippingFee__c 
            WHERE (Product__c IN :productIds OR ProductHierarchy__c IN :productIds) 
            AND (City__c IN :locationIds OR State__c IN :locationIds OR Country__c IN :locationIds)
            AND Id NOT IN :selfIds];
        if (existingFees.size() == 0) { return; }

        Map<Id, List<ShippingFee__c>> existingFeesProductMap = new Map<Id, List<ShippingFee__c>>();
        Id key;

        for (ShippingFee__c fee : existingFees) {
            if (fee.Product__c != null) {
                key = fee.Product__c;
            } else {
                key = fee.ProductHierarchy__c;
            }
            if (!existingFeesProductMap.containsKey(key)) {
                existingFeesProductMap.put(key, new List<ShippingFee__c>());
            }
            existingFeesProductMap.get(key).add(fee);
        }
        
        for (ShippingFee__c newFee : newRecordList) {
            if (newFee.Product__c != null) {
                key = newFee.Product__c;
            } else {
                key = newFee.ProductHierarchy__c;
            }
            for (ShippingFee__c existingFee : existingFeesProductMap.get(key)) {
                if (newFee.City__c == existingFee.City__c &&
                    newFee.State__c == existingFee.State__c &&
                    newFee.Country__c == existingFee.Country__c) {

                    newFee.addError('Duplicate shipping fee found.');
                }
            }
        }
    }
}
public with sharing class TaxTriggerHelper {
    public static void validateNoDuplicate(List<Tax__c> oldRecordList, List<Tax__c> newRecordList) {
        Set<Id> setIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();

        if (oldRecordList != null) {
            for (Tax__c tax : oldRecordList) {
                setIds.add(tax.Id);
            }
        }

        for (Tax__c tax : newRecordList) {
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

        for (Tax__c tax : newRecordList) {
            if (tax.Product__c == null) {
                tax.addError('This field is required.');
            }

            if (existingTaxesMap.containsKey(tax.Product__c) && existingTaxesMap.get(tax.Product__c).contains(tax.State__c)) {
                tax.addError('There is already a tax for this product and state.');
            }
        }
    }
}
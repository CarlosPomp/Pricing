trigger ShippingFeeTrigger on ShippingFee__c (before insert, before update) {
    ShippingFeeTriggerHandler handler = new ShippingFeeTriggerHandler(Trigger.old, Trigger.new);

    if (ShippingFeeTriggerHandler.isTriggerEnabled()) {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                handler.beforeInsert();
            }
            when BEFORE_UPDATE {
                handler.beforeUpdate();
            }
        }
    }
}
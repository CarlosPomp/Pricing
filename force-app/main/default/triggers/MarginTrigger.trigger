trigger MarginTrigger on Margin__c (before insert, before update) {
    MarginTriggerHandler handler = new MarginTriggerHandler(Trigger.old, Trigger.new);

    if (MarginTriggerHandler.isTriggerEnabled()) {
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
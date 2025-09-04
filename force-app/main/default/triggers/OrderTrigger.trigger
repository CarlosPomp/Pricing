trigger OrderTrigger on Order (before update) {
    OrderTriggerHandler handler = new OrderTriggerHandler(Trigger.old, Trigger.new);

    if (OrderTriggerHandler.isTriggerEnabled()) {
        switch on Trigger.operationType {
            when BEFORE_UPDATE {
                handler.beforeUpdate();
            }
        }
    }
}
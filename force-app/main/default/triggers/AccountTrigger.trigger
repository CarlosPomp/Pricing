trigger AccountTrigger on Account (before update) {
    AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.old, Trigger.new);

    if (AccountTriggerHandler.isTriggerEnabled()) {
        switch on Trigger.operationType {
            when BEFORE_UPDATE {
                handler.beforeUpdate();
            }
        }
    }
}
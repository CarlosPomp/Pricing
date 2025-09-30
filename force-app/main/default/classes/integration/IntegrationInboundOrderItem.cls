//@RestResource(urlMapping='/upsertOrderItem/*')
global with sharing class IntegrationInboundOrderItem {

    //OrderItem upsert integration

    //@HttpPost
    global static Map<String, List<DataIntegrationFields.Response>> upsertOrderItem(List<DataIntegrationFields.OrderItemINData> request) {
        Map<String, List<DataIntegrationFields.Response>> responseMap = new Map<String, List<DataIntegrationFields.Response>>();
        List<OrderItem> orderItemListToUpsert = new List<OrderItem>();

        //OrderItem ExternalId Map to Order ExternalId for association of responses
        Map<String, String> parentMapKeys = new Map<String, String>();
        for(DataIntegrationFields.OrderItemINData orderItem : request) {
            parentMapKeys.put(orderExternalId + '|' + orderItemId, orderItem.orderExternalId);
        }

        //Converting template to object list and validating required fields
        FactoryDataIntegration.convertSObjectChild(
            new OrderItem(), 
            'IN', 
            request, 
            responseMap, 
            orderItemListToUpsert, 
            parentMapKeys
        );

        //Upserting records
        List<Database.UpsertResult> upsResults = Database.upsert(orderItemListToUpsert, OrderItem.ExternalId__c, false);

        IntegrationUtils.upsertChildRecords(upsResults, responseMap, orderItemListToUpsert, OrderItem.ExternalId__c); 
        
        //Returning response
        return responseMap;
    }
}
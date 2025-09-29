@RestResource(urlMapping='/order/*')
global with sharing class OrderManager {
    private static List<Order> getInternalOrderIds(List<Order> orders) {
        Set<String> accountIds = new Set<String>();
        Set<String> addressIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        Set<String> contractIds = new Set<String>();
        Set<String> distributionCenterIds = new Set<String>();
        Set<String> payConditionIds = new Set<String>();

        for (Order order : orders) {
            accountIds.add(order.accountId);
            addressIds.add(order.address__c);
            contactIds.add(order.contactName__c);
            contractIds.add(order.contractId);
            distributionCenterIds.add(order.distributionCenter__c);
            payConditionIds.add(order.payCondition__c);
        }

        List<Account> accounts = [SELECT Id, ExternalId__c FROM Account WHERE ExternalId__c IN :accountIds];
        List<AccountAddress__c> addresses = [SELECT Id, ExternalId__c FROM AccountAddress__c WHERE ExternalId__c IN :addressIds];
        List<Contact> contacts = [SELECT Id, ExternalId__c FROM Contact WHERE ExternalId__c IN :contactIds];
        List<Contract> contracts = [SELECT Id, ExternalId__c FROM Contract WHERE ExternalId__c IN :contractIds];
        List<DistributionCenter__c> centers = [SELECT Id, ExternalId__c FROM DistributionCenter__c WHERE ExternalId__c IN :distributionCenterIds];
        List<PayCondition__c> conditions = [SELECT Id, ExternalId__c FROM PayCondition__c WHERE ExternalId__c IN :payConditionIds];

        Map<String, Id> externalToId = new Map<String, Id>();
        for (Account account : accounts) {
            externalToId.put(account.ExternalId__c, account.Id);
        }
        for (AccountAddress__c address : addresses) {
            externalToId.put(address.ExternalId__c, address.Id);
        }
        for (Contact contact : contacts) {
            externalToId.put(contact.ExternalId__c, contact.Id);
        }
        for (Contract contract : contracts) {
            externalToId.put(contract.ExternalId__c, contract.Id);
        }
        for (DistributionCenter__c center : centers) {
            externalToId.put(center.ExternalId__c, center.Id);
        }
        for (PayCondition__c condition : conditions) {
            externalToId.put(condition.ExternalId__c, condition.Id);
        }

        List<Order> thisOrders = new List<Order>();
 
        for (Order order : orders) {
            Order thisOrder = new Order(
                AccountId = externalToId.get(order.accountId),
                Address__c = externalToId.get(order.address__c),
                ContactName__c = externalToId.get(order.contactName__c),
                ContractId = externalToId.get(order.contractId),
                DeliveryDate__c = order.deliveryDate__c,
                DistributionCenter__c = externalToId.get(order.distributionCenter__c),
                EffectiveDate = order.effectiveDate,
                ExternalId__c = order.externalId__c,
                FreightType__c = order.freightType__c,
                IsOnTotvs__c = true,
                Observation__c = order.observation__c,
                PayCondition__c = externalToId.get(order.payCondition__c),
                Status = order.status
            );
            if (order.Id != null) {
                thisOrder.Id = order.Id;
            }
            thisOrders.add(thisOrder);
        }
        return thisOrders;
    }

    private static List<OrderItem> getInternalOrderItemIds(List<OrderItem> orderItems) {
        Set<String> orderIds = new Set<String>();
        Set<String> productIds = new Set<String>();

        for (OrderItem orderItem : orderItems) {
            orderIds.add(orderItem.orderId);
            productIds.add(orderItem.product2Id);
        }

        List<Order> orders = [SELECT Id, ExternalId__c FROM Order WHERE ExternalId__c IN :orderIds];
        List<Product2> products = [SELECT Id, ExternalId__c FROM Product2 WHERE ExternalId__c IN :productIds];

        Map<String, Id> externalToId = new Map<String, Id>();
        for (Order order : orders) {
            externalToId.put(order.ExternalId__c, order.Id);
        }
        for (Product2 product : products) {
            externalToId.put(product.ExternalId__c, product.Id);
        }
        
        List<OrderItem> thisOrderItems = new List<OrderItem>();
 
        for (OrderItem orderItem : orderItems) {
            OrderItem thisOrderItem = new OrderItem(
                ListPrice = orderItem.listPrice,
                OrderId = externalToId.get(orderItem.orderId),
                Product2Id = externalToId.get(orderItem.product2Id),
                Quantity = orderItem.quantity,
                ServiceDate = orderItem.serviceDate,
                UnitPrice = orderItem.unitPrice
            );
            if (orderItem.Id != null) {
                thisOrderItem.Id = orderItem.Id;
            }
            thisOrderItems.add(thisOrderItem);
        }
        return thisOrderItems;
    }

    @HttpPost
    global static void createOrders(List<Order> orders, List<OrderItem> orderItems) {
        List<OrderLog__c> newLogs = new List<OrderLog__c>();
        List<Order> newOrders = getInternalOrderIds(orders);
        insert newOrders;

        List<OrderItem> newOrderItems = getInternalOrderItemIds(orderItems);
        insert newOrderItems;

        for (Order order : newOrders) {
            OrderLog__c log = new OrderLog__c(
                OrderId__c = order.Id,
                Message__c = 'Order created at ' + DateTime.now()
            );
            newLogs.add(log);
        }

        insert newLogs;
    }

    @HttpPut
    global static void upsertOrders(List<Order> orders, List<OrderItem> orderItems) {
        Map<String, Order> externalOrderIdMap = new Map<String, Order>();
        Map<String, OrderItem> externalOrderItemIdMap = new Map<String, OrderItem>();

        for (Order order : orders) {
            externalOrderIdMap.put(order.ExternalId__c, order);
        }

        for (OrderItem orderItem : orderItems) {
            externalOrderItemIdMap.put(orderItem.ExternalId__c, orderItem);
        }

        List<Order> existingOrders = [SELECT Id, ExternalId__c FROM Order WHERE ExternalId__c IN :externalOrderIdMap.keySet()];
        List<OrderItem> existingOrderItems = [SELECT Id, ExternalId__c FROM OrderItem WHERE ExternalId__c IN :externalOrderItemIdMap.keySet()];

        for (Order existingOrder : existingOrders) {
            Order order = externalOrderIdMap.get(existingOrder.ExternalId__c);
            order.Id = existingOrder.Id;
        }

        for (OrderItem existingOrderItem : existingOrderItems) {
            OrderItem orderItem = externalOrderItemIdMap.get(existingOrderItem.ExternalId__c);
            orderItem.Id = existingOrderItem.Id;
        }

        List<Order> ordersToCreate = new List<Order>();
        List<Order> ordersToUpdate = new List<Order>();
        List<OrderItem> orderItemsToCreate = new List<OrderItem>();
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();

        for (Order order : orders) {
            if (order.Id == null) {
                ordersToCreate.add(order);
            } else {
                ordersToUpdate.add(order);
            }
        }

        for (OrderItem orderItem : orderItems) {
            if (orderItem.Id == null) {
                orderItemsToCreate.add(orderItem);
            }
        }

        createOrders(ordersToCreate, orderItemsToCreate);
        updateOrders(ordersToUpdate, orderItemsToUpdate);
    }

    @HttpPatch
    global static void updateOrder() {
        RestRequest request = RestContext.request;
        String orderId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        Order thisOrder = [SELECT Id, Status FROM Order WHERE ExternalId__c = :orderId];

        Map<String,Object> params = (Map<String,Object>) JSON.deserializeUntyped(request.requestBody.toString());

        for (String fieldName : params.keySet()) {
            thisOrder.put(fieldName, params.get(fieldName));
        }
        update thisOrder;
    }

    private static void updateOrders(List<Order> orders, List<OrderItem> orderItems) {
        List<OrderLog__c> newLogs = new List<OrderLog__c>();
        List<Order> newOrders = getInternalOrderIds(orders);
        update newOrders;

        List<OrderItem> newOrderItems = getInternalOrderItemIds(orderItems);
        update newOrderItems;

        for (Order order : newOrders) {
            OrderLog__c log = new OrderLog__c(
                OrderId__c = order.Id,
                Message__c = 'Order updated at ' + DateTime.now()
            );
            newLogs.add(log);
        }

        insert newLogs;
    }

    @HttpDelete
    global static void deleteOrder() {
        RestRequest request = RestContext.request;
        String orderId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        Order thisOrder = [SELECT Id FROM Order WHERE ExternalId__c = :orderId];
        thisOrder.IsOnTotvs__c = false;
        update thisOrder;
    }
}
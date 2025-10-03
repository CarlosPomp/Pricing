public with sharing class OrderItemTriggerHelper {
    private static void joinMap(Map<Id,Id> map1, Map<Id,Id> map2) {
        for (Id key: map1.keySet()) {  
            map1.put(key, map2.get(map1.get(key)));
        }
    }

    private static void verifyActivation(List<OrderItem> recordList) {
        Set<Id> orderIds = new Set<Id>();
        
        for (OrderItem orderItem : recordList) {
            orderIds.add(orderItem.OrderId);
        }
        
        List<Order> orders = [SELECT Id, Status FROM Order WHERE Id IN :orderIds];
        for (Order order : orders) {
            if (order.Status != 'Draft' && order.Status != 'In Progress') {
                order.addError('Cannot create order item on activated order');
            }
        }
    }
    
    private static void setFullPrice(List<OrderItem> recordList) {
        Set<Id> productIds = new Set<Id>();

        for (OrderItem order : recordList) {
            productIds.add(order.Product2Id);
        }

        List<Product2> products = [SELECT Id, ProductionCost__c FROM Product2 WHERE Id IN :productIds];
        Map<Id, Product2> productCostMap = new Map<Id, Product2>(products);

        for (OrderItem order : recordList) {
            if (order.TaxPercentage__c == null || order.Margin_Percentage__c == null || order.FreightValue__c == null) {
                order.addError('Selling of this product is not authorized due to lack of parameters, please contact your pricing team.');
            } else {
                Decimal fullPrice = productCostMap.get(order.Product2Id).ProductionCost__c + order.FreightValue__c;
                fullPrice += (fullPrice * order.TaxPercentage__c / 100);
                fullPrice += (fullPrice * order.Margin_Percentage__c / 100);
                order.FullPrice__c = fullPrice.setScale(2);
            }
        }
    }

    private static void setDiscount(List<OrderItem> recordList) {
        for (OrderItem order : recordList) {
            if (order.FullPrice__c != null) {
                order.Discount__c = 100*(order.FullPrice__c - order.UnitPrice)/order.FullPrice__c;
                order.Discount__c = order.Discount__c.setScale(2);
            }
        }
    }

    private static void searchTaxField(List<OrderItem> recordList) {
        Set<Id> productIds = new Set<Id>();
        Map<Id,Id> orderToStateMap = new Map<Id,Id>();
        Map<Id,Id> auxiliaryMap = new Map<Id,Id>();

        for (OrderItem orderItem : recordList) {
            productIds.add(orderItem.Product2Id);
            orderToStateMap.put(orderItem.Id, orderItem.OrderId);
        }

        for (Order order : [SELECT Id, Address__c FROM Order WHERE Id IN :orderToStateMap.values()]) {
            auxiliaryMap.put(order.Id, order.Address__c);
        }

        joinMap(orderToStateMap, auxiliaryMap);
        auxiliaryMap.clear();

        for (AccountAddress__c accountAddress : [SELECT Id, City__r.State__c FROM AccountAddress__c WHERE Id IN :orderToStateMap.values()]) {
            auxiliaryMap.put(accountAddress.Id, accountAddress.City__r.State__c);
        }

        joinMap(orderToStateMap, auxiliaryMap);

        List<Tax__c> taxes = [SELECT Id, Product__c, State__c, TaxPercentage__c FROM Tax__c WHERE Product__c IN :productIds AND State__c IN :orderToStateMap.values() AND Status__c = 'Approved'];
        Map<Id, List<Tax__c>> productMap = new Map<Id, List<Tax__c>>();

        for (Tax__c tax : taxes) {
            if (!productMap.containsKey(tax.Product__c)) {
                productMap.put(tax.Product__c, new List<Tax__c>());
            }
            productMap.get(tax.Product__c).add(tax);
        }

        for (OrderItem orderItem : recordList) {
            for (Tax__c tax : productMap.get(orderItem.Product2Id)) {
                if (tax.State__c == orderToStateMap.get(orderItem.Id)) {
                    orderItem.TaxPercentage__c = tax.TaxPercentage__c;
                }
            }
        }
    }

    private static void searchShippingFeeField(List<OrderItem> recordList) {
        Set<Id> productIds = new Set<Id>();
        Map<Id,Id> cityToStateMap = new Map<Id,Id>();
        Map<Id,Id> cityToCountryMap = new Map<Id,Id>();
        Map<Id,Id> orderToHierarchyMap = new Map<Id,Id>();

        Map<Id,Id> orderToCityMap = new Map<Id,Id>();
        Map<Id,Id> auxiliaryMap = new Map<Id,Id>();

        for (OrderItem orderItem : recordList) {
            productIds.add(orderItem.Product2Id);
            orderToCityMap.put(orderItem.Id, orderItem.OrderId);
            orderToHierarchyMap.put(orderItem.Id, orderItem.Product2Id);
        }

        for (Product2 product : [SELECT Id, ProductHierarchy__c FROM Product2 WHERE Id IN :productIds]) {
            productIds.add(product.ProductHierarchy__c);
            auxiliaryMap.put(product.Id, product.ProductHierarchy__c);
        }

        joinMap(orderToHierarchyMap, auxiliaryMap);
        auxiliaryMap.clear();

        for (Order order : [SELECT Id, Address__c FROM Order WHERE Id IN :orderToCityMap.values()]) {
            auxiliaryMap.put(order.Id, order.Address__c);
        }

        joinMap(orderToCityMap, auxiliaryMap);
        auxiliaryMap.clear();

        for (AccountAddress__c accountAddress : [SELECT Id, City__c FROM AccountAddress__c WHERE Id IN :orderToCityMap.values()]) {
            auxiliaryMap.put(accountAddress.Id, accountAddress.City__c);
        }

        joinMap(orderToCityMap, auxiliaryMap);

        for (City__c city : [SELECT Id, State__c, State__r.Country__c FROM City__c WHERE Id IN :orderToCityMap.values()]) {
            cityToStateMap.put(city.Id, city.State__c);
            cityToCountryMap.put(city.Id, city.State__r.Country__c);
        }

        List<ShippingFee__c> shippingFees = [SELECT Id, Product__c, ProductHierarchy__c, City__c, State__c, Country__c, Value__c FROM ShippingFee__c
            WHERE (Product__c IN :productIds OR ProductHierarchy__c IN :productIds)
            AND (City__c IN :orderToCityMap.values() OR State__c IN :cityToStateMap.values() OR Country__c IN :cityToCountryMap.values())
            AND Status__c = 'Approved'];
        Map<Id, List<ShippingFee__c>> productMap = new Map<Id, List<ShippingFee__c>>();
        Id key;

        for (ShippingFee__c fee : shippingFees) {
            if (fee.Product__c != null) {
                key = fee.Product__c;
            } else {
                key = fee.ProductHierarchy__c;
            }
            if (!productMap.containsKey(key)) {
                productMap.put(key, new List<ShippingFee__c>());
            }
            productMap.get(key).add(fee);
        }

        Boolean ignoreCountry = false;

        for (OrderItem orderItem : recordList) {
            if (productMap.containsKey(orderItem.Product2Id)) {
                key = orderItem.Product2Id;
            } else {
                key = orderToHierarchyMap.get(orderItem.Id);
            }
            for (ShippingFee__c fee : productMap.get(key)) {
                if (fee.City__c != null) {
                    if (fee.City__c == orderToCityMap.get(orderItem.Id)) {
                        orderItem.FreightValue__c = fee.Value__c;
                        break;
                    }
                } else if (fee.State__c != null) {
                    if (fee.State__c == cityToStateMap.get(orderToCityMap.get(orderItem.Id))) {
                        orderItem.FreightValue__c = fee.Value__c;
                        ignoreCountry = true;
                    }
                } else {
                    if ((fee.Country__c == cityToCountryMap.get(orderToCityMap.get(orderItem.Id))) && !ignoreCountry) {
                        orderItem.FreightValue__c = fee.Value__c;
                    }
                }
            }
        }
    }

    private static void searchMarginField(List<OrderItem> recordList) {
        Set<Id> productIds = new Set<Id>();
        Map<Id,Id> cityToStateMap = new Map<Id,Id>();
        Map<Id,Id> cityToCountryMap = new Map<Id,Id>();
        Map<Id,Id> accountToGroupMap = new Map<Id, Id>();
        Map<Id,Id> orderToHierarchyMap = new Map<Id,Id>();

        Map<Id,Id> orderToAccountMap = new Map<Id,Id>();
        Map<Id,Id> orderToCityMap = new Map<Id,Id>();
        Map<Id,Id> auxiliaryMap = new Map<Id,Id>();

        for (OrderItem orderItem : recordList) {
            productIds.add(orderItem.Product2Id);
            orderToCityMap.put(orderItem.Id, orderItem.OrderId);
            orderToAccountMap.put(orderItem.Id, orderItem.OrderId);
            orderToHierarchyMap.put(orderItem.Id, orderItem.Product2Id);
        }

        for (Product2 product : [SELECT Id, ProductHierarchy__c FROM Product2 WHERE Id IN :productIds]) {
            productIds.add(product.ProductHierarchy__c);
            auxiliaryMap.put(product.Id, product.ProductHierarchy__c);
        }

        joinMap(orderToHierarchyMap, auxiliaryMap);
        auxiliaryMap.clear();

        for (Order order : [SELECT Id, Address__c FROM Order WHERE Id IN :orderToCityMap.values()]) {
            auxiliaryMap.put(order.Id, order.Address__c);
        }

        joinMap(orderToCityMap, auxiliaryMap);
        auxiliaryMap.clear();

        for (Order order : [SELECT Id, AccountId FROM Order WHERE Id IN :orderToAccountMap.values()]) {
            auxiliaryMap.put(order.Id, order.AccountId);
        }

        joinMap(orderToAccountMap, auxiliaryMap);
        auxiliaryMap.clear();

        for (AccountAddress__c accountAddress : [SELECT Id, City__c FROM AccountAddress__c WHERE Id IN :orderToCityMap.values()]) {
            auxiliaryMap.put(accountAddress.Id, accountAddress.City__c);
        }

        joinMap(orderToCityMap, auxiliaryMap);

        for (City__c city : [SELECT Id, State__c, State__r.Country__c FROM City__c WHERE Id IN :orderToCityMap.values()]) {
            cityToStateMap.put(city.Id, city.State__c);
            cityToCountryMap.put(city.Id, city.State__r.Country__c);
        }

        for (Account account : [SELECT Id, AccountGroup__c FROM Account WHERE Id IN :orderToAccountMap.values()]) {
            accountToGroupMap.put(account.Id, account.AccountGroup__c);
        }

        List<Margin__c> margins = [SELECT Id, Product__c, Product_Hierarchy__c, Account__c, AccountGroup__c, City__c, State__c, Country__c, Value__c FROM Margin__c
            WHERE (Product__c IN :productIds OR Product_Hierarchy__c IN :productIds)
            AND (Account__c IN :orderToAccountMap.values() OR AccountGroup__c IN :accountToGroupMap.values())
            AND (City__c IN :orderToCityMap.values() OR State__c IN :cityToStateMap.values() OR Country__c IN :cityToCountryMap.values())
            AND Status__c = 'Approved'];
        Set<Id> productSet = new Set<Id>();
        Map<String, List<Margin__c>> productPlusAccountMap = new Map<String, List<Margin__c>>();
        Id key;
        Id accountKey;
        String productPlusAccountKey;

        for (Margin__c margin : margins) {
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
            productPlusAccountKey = key + '-' + accountKey;
            if (!productPlusAccountMap.containsKey(productPlusAccountKey)) {
                productPlusAccountMap.put(productPlusAccountKey, new List<Margin__c>());
            }
            productSet.add(key);
            productPlusAccountMap.get(productPlusAccountKey).add(margin);
        }

        Boolean ignoreCountry = false;

        for (OrderItem orderItem : recordList) {
            if (productSet.contains(orderItem.Product2Id)) {
                key = orderItem.Product2Id;
            } else {
                key = orderToHierarchyMap.get(orderItem.Id);
            }
            if (productPlusAccountMap.containsKey(key + '-' + orderToAccountMap.get(orderItem.Id))) {
                accountKey = orderToAccountMap.get(orderItem.Id);
            } else {
                accountKey = accountToGroupMap.get(orderToAccountMap.get(orderItem.Id));
            }
            productPlusAccountKey = key + '-' + accountKey;
            if (!productPlusAccountMap.containsKey(productPlusAccountKey)) {
                continue;
            }
            for (Margin__c margin : productPlusAccountMap.get(productPlusAccountKey)) {
                if (margin.City__c != null) {
                    if (margin.City__c == orderToCityMap.get(orderItem.Id)) {
                        orderItem.Margin_Percentage__c = margin.Value__c;
                        break;
                    }
                } else if (margin.State__c != null) {
                    if (margin.State__c == cityToStateMap.get(orderToCityMap.get(orderItem.Id))) {
                        orderItem.Margin_Percentage__c = margin.Value__c;
                        ignoreCountry = true;
                    }
                } else {
                    if ((margin.Country__c == cityToCountryMap.get(orderToCityMap.get(orderItem.Id))) && !ignoreCountry) {
                        orderItem.Margin_Percentage__c = margin.Value__c;
                    }
                }
            }
        }
    }

    public static void handleTrigger(List<OrderItem> newRecordList) {
        verifyActivation(newRecordList);
        searchTaxField(newRecordList);
        searchShippingFeeField(newRecordList);
        searchMarginField(newRecordList);
        setFullPrice(newRecordList);
        setDiscount(newRecordList);
    }
}
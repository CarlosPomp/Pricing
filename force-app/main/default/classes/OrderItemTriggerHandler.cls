public with sharing class OrderItemTriggerHandler {
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

    List<OrderItem> oldRecordList { get; set; }
	List<OrderItem> newRecordList { get; set; }

    public OrderItemTriggerHandler(List<OrderItem> oldRecordList, List<OrderItem> newRecordList) {
        this.oldRecordList = oldRecordList;
        this.newRecordList = newRecordList;
    }

    private void joinMap(Map<Id,Id> map1, Map<Id,Id> map2) {
        for (Id key: map1.keySet()) {  
            map1.put(key, map2.get(map1.get(key)));
        }
    }

    private void verifyActivation() {
        List<OrderItem> orders = [SELECT Id, Order.Status FROM OrderItem WHERE Id IN :this.newRecordList];
        for (OrderItem order : orders) {
            if (order.Order.Status != 'Draft' || order.Order.Status != 'In Progress') {
                order.addError('Cannot create order item on activated order');
            }
        }
    }

    private void SetFullPrice() {
        Set<Id> newIds = new Set<Id>();

        for (OrderItem order : this.newRecordList) {
            newIds.add(order.Id);
        }

        List<OrderItem> broaderRecordList = [SELECT Id, Product2.ProductionCost__c, FullPrice__c, FreightValue__c, TaxPercentage__c, Margin_Percentage__c 
            FROM OrderItem WHERE Id IN :newIds];

        for (OrderItem order : broaderRecordList) {
            if (order.TaxPercentage__c == null || order.Margin_Percentage__c == null || order.FullPrice__c == null) {
                order.addError('Selling of this product is not authorized due to lack of parameters, please contact your pricing team.');
            } else {
                Decimal fullPrice = order.Product2.ProductionCost__c + order.FreightValue__c;
                fullPrice += (fullPrice * order.TaxPercentage__c / 100);
                fullPrice += (fullPrice * order.Margin_Percentage__c / 100);
                order.FullPrice__c = fullPrice;
                order.FullPrice__c = order.FullPrice__c.setScale(2);
            }
        }
    }

    private void setDiscount() {
        for (OrderItem order : this.newRecordList) {
            order.Discount__c = 100*(order.FullPrice__c - order.UnitPrice)/order.FullPrice__c;
            order.Discount__c = order.Discount__c.setScale(2);
        }
    }

    private void SearchTaxField() {
        Set<Id> productIds = new Set<Id>();
        Map<Id,Id> orderToStateMap = new Map<Id,Id>();
        Map<Id,Id> auxiliaryMap = new Map<Id,Id>();

        for (OrderItem orderItem : this.newRecordList) {
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

        for (OrderItem orderItem : this.newRecordList) {
            for (Tax__c tax : productMap.get(orderItem.Product2Id)) {
                if (tax.State__c == orderToStateMap.get(orderItem.Id)) {
                    orderItem.TaxPercentage__c = tax.TaxPercentage__c;
                }
            }
        }
    }

    private void SearchShippingFeeField() {
        Set<Id> productIds = new Set<Id>();
        Map<Id,Id> cityToStateMap = new Map<Id,Id>();
        Map<Id,Id> cityToCountryMap = new Map<Id,Id>();
        Map<Id,Id> orderToHierarchyMap = new Map<Id,Id>();

        Map<Id,Id> orderToCityMap = new Map<Id,Id>();
        Map<Id,Id> auxiliaryMap = new Map<Id,Id>();

        for (OrderItem orderItem : this.newRecordList) {
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
        Map<Id, List<ShippingFee__c>> productHierarchyMap = new Map<Id, List<ShippingFee__c>>();

        for (ShippingFee__c fee : shippingFees) {
            if (fee.Product__c != null) {
                if (!productMap.containsKey(fee.Product__c)) {
                    productMap.put(fee.Product__c, new List<ShippingFee__c>());
                }
                productMap.get(fee.Product__c).add(fee);
            } else {
                if (!productHierarchyMap.containsKey(fee.ProductHierarchy__c)) {
                    productHierarchyMap.put(fee.ProductHierarchy__c, new List<ShippingFee__c>());
                }
                productHierarchyMap.get(fee.ProductHierarchy__c).add(fee);
            }
        }

        Boolean ignoreCountry = false;

        for (OrderItem orderItem : this.newRecordList) {
            if (productMap.containsKey(orderItem.Product2Id)) {
                for (ShippingFee__c fee : productMap.get(orderItem.Product2Id)) {
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
            if (productHierarchyMap.containsKey(orderItem.Product2Id)) {
                for (ShippingFee__c fee : productHierarchyMap.get(orderItem.Product2Id)) {
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
    }

    private void SearchMarginField() {
        Set<Id> productIds = new Set<Id>();
        Map<Id,Id> cityToStateMap = new Map<Id,Id>();
        Map<Id,Id> cityToCountryMap = new Map<Id,Id>();
        Map<Id,Id> accountToGroupMap = new Map<Id, Id>();
        Map<Id,Id> orderToHierarchyMap = new Map<Id,Id>();

        Map<Id,Id> orderToAccountMap = new Map<Id,Id>();
        Map<Id,Id> orderToCityMap = new Map<Id,Id>();
        Map<Id,Id> auxiliaryMap = new Map<Id,Id>();

        for (OrderItem orderItem : this.newRecordList) {
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

        for (Order order : [SELECT Id, AccountId FROM Order WHERE Id IN :orderToCityMap.values()]) {
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
        Map<Id, Map<Id, List<Margin__c>>> productMap = new Map<Id, Map<Id, List<Margin__c>>>();
        Map<Id, Map<Id, List<Margin__c>>> productHierarchyMap = new Map<Id, Map<Id, List<Margin__c>>>();

        for (Margin__c margin : margins) {
            if (margin.Product__c != null) {
                if (!productMap.containsKey(margin.Product__c)) {
                    productMap.put(margin.Product__c, new Map<Id, List<Margin__c>>());
                }
                if (margin.Account__c != null) {
                    if (!productMap.get(margin.Product__c).containsKey(margin.Account__c)) {
                        productMap.get(margin.Product__c).put(margin.Account__c, new List<Margin__c>());
                    }
                    productMap.get(margin.Product__c).get(margin.Account__c).add(margin);
                } else {
                    if (!productMap.get(margin.Product__c).containsKey(margin.AccountGroup__c)) {
                        productMap.get(margin.Product__c).put(margin.AccountGroup__c, new List<Margin__c>());
                    }
                    productMap.get(margin.Product__c).get(margin.AccountGroup__c).add(margin);
                }
            } else {
                if (!productHierarchyMap.containsKey(margin.Product_Hierarchy__c)) {
                    productHierarchyMap.put(margin.Product_Hierarchy__c, new Map<Id, List<Margin__c>>());
                }
                if (margin.Account__c != null) {
                    if (!productHierarchyMap.get(margin.Product__c).containsKey(margin.Account__c)) {
                        productHierarchyMap.get(margin.Product__c).put(margin.Account__c, new List<Margin__c>());
                    }
                    productHierarchyMap.get(margin.Product__c).get(margin.Account__c).add(margin);
                } else {
                    if (!productHierarchyMap.get(margin.Product__c).containsKey(margin.AccountGroup__c)) {
                        productHierarchyMap.get(margin.Product__c).put(margin.AccountGroup__c, new List<Margin__c>());
                    }
                    productHierarchyMap.get(margin.Product__c).get(margin.AccountGroup__c).add(margin);
                }
            }
        }

        Boolean ignoreCountry = false;

        for (OrderItem orderItem : this.newRecordList) {
            if (productMap.containsKey(orderItem.Product2Id)) {
                Id orderAccount = orderToAccountMap.get(orderItem.OrderId);
                if (!productMap.get(orderItem.Product2Id).containsKey(orderAccount)) {
                    orderAccount = accountToGroupMap.get(orderAccount);
                }
                for (Margin__c margin : productMap.get(orderItem.Product2Id).get(orderAccount)) {
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
            if (productHierarchyMap.containsKey(orderItem.Product2Id)) {
                Id orderAccount = orderToAccountMap.get(orderItem.OrderId);
                if (!productHierarchyMap.get(orderItem.Product2Id).containsKey(orderAccount)) {
                    orderAccount = accountToGroupMap.get(orderAccount);
                }
                for (Margin__c margin : productHierarchyMap.get(orderItem.Product2Id).get(orderAccount)) {
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
    }

    public void beforeInsert() {
        this.verifyActivation();
        this.SearchTaxField();
        this.SearchShippingFeeField();
        this.SearchMarginField();
        this.SetFullPrice();
        this.setDiscount();
    }

    public void beforeUpdate() {
        this.verifyActivation();
        this.SearchTaxField();
        this.SearchShippingFeeField();
        this.SearchMarginField();
        this.SetFullPrice();
        this.setDiscount();
    }
}
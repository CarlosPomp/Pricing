public with sharing class CalloutOrder {
	

	public static IntegrationUtils.CalloutResponse processIntegration(Id orderId){

		Order parentOrder = [SELECT Id, ExternalId__c, OrderNumber, Observation__c, Account.ExternalId__c,
							 Address__r.ExternalId__c, PayCondition__r.ExternalId__c, EffectiveDate,
							 FreightType__c, DistributionCenter__r.ExternalId__c, DeliveryDate__c, Status,
							 (SELECT Id, ExternalId__c, Product2.ExternalId__c, UnitPrice, ListPrice, Quantity FROM OrderItems) FROM Order WHERE Id = :orderId];
		
		List<Order> allOrders = new List<Order>{parentOrder};
		
		IntegrationUtils.CalloutResponse calloutResponse = sendOrder(allOrders);

		if (calloutResponse.success) {
			
			ResponseParameters resp = (ResponseParameters) calloutResponse.parsedResponse;
			
			Map<String, Order> orderMap = new Map<String, Order>();

			for (Order ord : allOrders) {
				orderMap.put(ord.OrderNumber, ord);
			}

			List<Order> orderList = new List<Order>();

			for (ResponseParametersWrapper respWrapper : resp.responses) {
				if (orderMap.containsKey(respWrapper.SalesforceCode)) {

					Order ord = orderMap.get(respWrapper.SalesforceCode);

					if (respWrapper.Error == 'TRUE') {
						//Error Treatments
					} else {
						//Success Treatments
					}
					
					orderList.add(ord);
				}
			}

			if (!orderList.isEmpty()) {
				update orderList;
			}
		}
		
		return calloutResponse;
	}
	public static IntegrationUtils.CalloutResponse sendOrder(List<Order> orders) {
			
		List<RequestParameters> request = new List<RequestParameters>();

		for (Order ord : orders) {
			request.add(new RequestParameters(ord));
		}

		Map<String, List<RequestParameters>> jsonMap = new Map<String, List<RequestParameters>>();
		jsonMap.put('request', request);

		String payload = JSON.serialize(jsonMap);
		System.debug('PAYLOAD ' + payload);

		//Metodo para busca de Access Token, depende de cada projeto, podendo estar presente dentro de uma custom settings ou relacionado com outra requisição.
		String accessToken = '00Daj00000Wkr25!AQEAQGEPmI3nOLlI0NVX9xvuesQ.uG15JbSU97pBmYx67DfP5olTYOoUyuddhSYmA88HWrtpcV5ybSD5QHBghoZNDbkNwDTg';
		
		//Path geralmente cadastrado dentro de ua customSettings
		String endpoint = 'https://empathetic-impala-m56ghx-dev-ed.trailblaze.my.salesforce.com/services/apexrest/upsertOrder/';
		Map<String, String> headersMap = new Map<String, String>();
		headersMap.put('Content-type', 'application/json');
		headersMap.put('Authorization', 'Bearer ' + accessToken);
		
		IntegrationUtils.RequestResponseObject responseObject = IntegrationUtils.executeCallout(endpoint, payload, headersMap);

		if (responseObject.success) {

			HttpResponse response = responseObject.response;
			try {

				List<ResponseParametersWrapper> responses = (List<ResponseParametersWrapper>) JSON.deserialize(response.getBody(), List<ResponseParametersWrapper>.class);
				return new IntegrationUtils.CalloutResponse(new ResponseParameters(responses));
			} catch (Exception e) {
				
				String defaultErrorMessage = 'Malformatted HTTP Response Exception: ' + e.getMessage();

				return new IntegrationUtils.CalloutResponse(defaultErrorMessage);
			}
		} else {
			return new IntegrationUtils.CalloutResponse(responseObject.exceptionObject.getMessage());
		}
	}

	public class RequestParameters {
		//Order Fields
		//Example
		public String orderCode;
        public String obs;
		public OrderItemParameters[] orderItems;
		public String accountCode;
		public Date effectiveDate;
		public String status;
		public String addressCode;
		public Date deliveryDate;
		public String freightType;
		public String paymentCode;
		public String distributionCenterCode;

		public RequestParameters(Order ord) {
			this.orderCode = ord.ExternalId__c;
			this.obs = 'oi';			
			this.orderItems = new List<OrderItemParameters>();
			this.accountCode = ord.Account.ExternalId__c;
			this.addressCode = ord.Address__r.ExternalId__c;
			this.paymentCode = ord.PayCondition__r.ExternalId__c;
			this.freightType = ord.FreightType__c;
			this.distributionCenterCode = ord.DistributionCenter__r.ExternalId__c;
			this.deliveryDate = ord.DeliveryDate__c;
			this.effectiveDate = ord.EffectiveDate;
			this.status = ord.Status;

			for (OrderItem ordIt : Ord.OrderItems) {
				orderItems.add(new OrderItemParameters(ordIt));
			}
		}
	}

	public class OrderItemParameters {
		//OrderItem Fields
		//Example
		public String itemCode;
		public String productCode;
		public Decimal quantity;
		public Decimal unitPrice;
		public Boolean totvsItem;
		public Decimal listPrice;

		public OrderItemParameters(OrderItem ordIt) {
			this.itemCode = ordIt.ExternalId__c;
			this.productCode = ordIt.Product2.ExternalId__c;
			this.quantity = ordIt.Quantity;
			this.unitPrice = ordIt.UnitPrice;
			this.listPrice = ordIt.ListPrice;
			this.totvsItem = false;
		}
	}

	public class ResponseParameters {
		public List<ResponseParametersWrapper> responses;

		public ResponseParameters(List<ResponseParametersWrapper> responses) {
			this.responses = responses;
		}
	}

	public class ResponseParametersWrapper {
		public String Status;
		public String Error;
		public String SalesforceCode;
		public String ERPCode;
	}
}
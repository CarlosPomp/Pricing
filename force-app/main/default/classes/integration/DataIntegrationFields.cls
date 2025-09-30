global with sharing class DataIntegrationFields {
	public interface FieldData {
		List<String> getRequiredFields();
		String getFieldKey();
		String getFieldId();
		String getExternalId();
		SObject serialize();
	}

	public interface FieldDataChild {
		List<String> getRequiredFields();
		String getFieldId();
		String getFieldExternal();
		String getParentKey();
		SObject serialize();
	}

	global class OrderINData implements FieldData { // extends OrderBase
		public String id;
		public String externalId;
		public String status;
		public Date effectiveDate;
		public String accountExternalId;
		public String addressExternalId;
		public String contactNameExternalId;
		public String contractExternalId;
		public Date deliveryDate;
		public String freightType;
		public String payConditionExternalId;
		public String distributionCenterExternalId;
		public List<DataIntegrationFields.OrderItemINData> orderItems;

		public List<OrderItemINData> orderItemList {get; set;}

		public Order serialize() {
			return new Order(
				Id				      = this.id,
				ExternalId__c	      = this.externalId,
				Status			      = this.status,
				EffectiveDate	      = this.effectiveDate,
				Account			      = new Account(ExternalId__c = this.accountExternalId),
				Address__r		      = new AccountAddress__c(ExternalId__c = this.addressExternalId),
				ContactName__r        = new Contact(ExternalId__c = this.contactNameExternalId),
				Contract		      = new Contract(ExternalId__c = this.contractExternalId),
				DeliveryDate__c	      = this.deliveryDate,
				FreightType__c	      = this.freightType,
				PayCondition__r	      = new PayCondition__c(ExternalId__c = this.payConditionExternalId),
				DistributionCenter__r = new DistributionCenter__c(ExternalId__c = this.distributionCenterExternalId)
			);
		}

		public List<String> getRequiredFields() {
			return new List<String>{
				'DeliveryDate',
				'ExternalId__c',
				'EffectiveDate',
				'FreightType__c',
				'Status'
			};
		}
		public List<String> getRequiredLookups() {
			return new List<String>{
				'AccountId',
				'Address__c',
				'ContactName__c',
				'ContractId',
				'DistributionCenter__c',
				'PayCondition__c'
			};
		}

		public String getFieldKey() {
			return 'ExternalId__c';
		}
		public String getFieldId() {
			return 'Id';
		}
		public String getExternalId() {
			return this.externalId;
		}
	}

	global class OrderItemINData implements FieldDataChild { // extends OrderItemBase
		public String id;
		public String externalId;
		public Decimal quantity;
		public Decimal unitPrice;
		public String orderExternalId;
		public String productExternalId;

		public OrderItem serialize() {
			OrderItem orderItem = new OrderItem(
				ExternalId__c	= this.externalId,
				Quantity		= this.quantity,
				UnitPrice		= this.unitPrice,
				Order			= new Order(ExternalId__c = this.orderExternalId),
				Product2 		= new Product2(ExternalId__c = this.productExternalId)
			);

			return orderItem;
		}

		public List<String> getRequiredFields() {
			return new List<String>{
				'UnitPrice',
				'Quantity',
				'ExternalId__c'
			};
		}
		public List<String> getRequiredLookups() {
			return new List<String>{
				'OrderId',
				'Product2Id'
			};
		}

		public String getFieldId() {
			return 'Id';
		}
		public String getFieldExternal() {
			return 'ExternalId__c';
		}
		public String getParentId() {
			return 'OrderId';
		}
		public String getParentKey() {
			return this.orderExternalId;
		}
	}

	global virtual class Response {
		public String salesforceId;
		public String externalId;
		public String sobjectType;
		public Boolean hasError;
		public String errorMessage;
		public Boolean status;

		public void success(String salesforceId, String externalId, String sobjectType){
			this.salesforceId	= salesforceId;
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= false;
		}

		public void error(String externalId, String errorMessage, String sobjectType){
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= true;
			this.errorMessage	= errorMessage;
		}

		public void error(String salesforceId, String externalId, String errorMessage, String sobjectType){
			this.salesforceId	= salesforceId;
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= true;
			this.errorMessage	= errorMessage;
		}
	}
	global class ResponseParent extends Response {
		public List<DataIntegrationFields.Response> items;
	}
}

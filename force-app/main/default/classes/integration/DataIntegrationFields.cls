global with sharing class DataIntegrationFields {
	public interface FieldData {
		List<String> getRequiredFields();
		String getFieldKey();
		String getFieldId();
		SObject serialize(Map<String,Id> lookups);
	}

	public interface FieldDataChild {
		List<String> getRequiredFields();
		String getFieldId();
		String getFieldExternal();
		String getParentKey();
		SObject serialize(Map<String,Id> lookups);
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

		public Order serialize(Map<String,Id> lookups) {
			return new Order(
				Id				      = this.id,
				ExternalId__c	      = this.externalId,
				Status			      = this.status,
				EffectiveDate	      = this.effectiveDate,
				Account			      = new Account(ExternalId__c = this.accountExternalId),
				Address__c		      = lookups.containsKey('Address'+this.addressExternalId) ? lookups.get('Address'+this.addressExternalId) : null,
				ContactName__c	      = lookups.containsKey('Contact'+this.contactNameExternalId) ? lookups.get('Contact'+this.contactNameExternalId) : null,
				ContractId		      = lookups.containsKey('Contract'+this.contractExternalId) ? lookups.get('Contract'+this.contractExternalId) : null,
				DeliveryDate__c	      = this.deliveryDate,
				FreightType__c	      = this.freightType,
				PayCondition__c	      = lookups.containsKey('PayCondition'+this.payConditionExternalId) ? lookups.get('PayCondition'+this.payConditionExternalId) : null,
				DistributionCenter__c = lookups.containsKey('DistributionCenter'+this.distributionCenterExternalId) ? lookups.get('DistributionCenter'+this.distributionCenterExternalId) : null
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

		public OrderItem serialize(Map<String,Id> lookups) {
			OrderItem orderItem = new OrderItem(
				ExternalId__c	= this.externalId,
				Quantity		= this.quantity,
				UnitPrice		= this.unitPrice,
				OrderId			= lookups.containsKey('Order'+this.orderExternalId) ? lookups.get('Order'+this.orderExternalId) : null,
				Product2Id		= lookups.containsKey('Product2'+this.productExternalId) ? lookups.get('Product2'+this.productExternalId) : null
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

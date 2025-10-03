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
		public String orderCode;
		public String status;
		public Date effectiveDate;
		public String accountCode;
		public String addressCode;
		public Date deliveryDate;
		public String freightType;
		public String paymentCode;
		public String distributionCenterCode;
		public String obs;

		public List<OrderItemINData> orderItems {get; set;}

		public Order serialize() {
			System.debug('OrderINData');
            if (this.status != 'Draft' && this.status != 'In Progress' && this.status != 'Approved' && this.status != 'Finished' && this.status != 'Waiting Approval') this.status = 'Draft';
			return new Order(
				Id				      = this.id,
				ExternalId__c	      = this.orderCode,
				Status			      = this.status,
				EffectiveDate	      = this.effectiveDate,
				Account			      = new Account(ExternalId__c = this.accountCode),
				Address__r		      = new AccountAddress__c(ExternalId__c = this.addressCode),
				DeliveryDate__c	      = this.deliveryDate,
				FreightType__c	      = this.freightType,
				PayCondition__r	      = new PayCondition__c(ExternalId__c = this.paymentCode),
				DistributionCenter__r = new DistributionCenter__c(ExternalId__c = this.distributionCenterCode),
				Observation__c		  = this.obs
			);
		}

		public List<String> getRequiredFields() {
			return new List<String>{
				'DeliveryDate__c',
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
			return this.orderCode;
		}
	}

	global class OrderItemINData implements FieldDataChild { // extends OrderItemBase
		public String id;
		public String itemCode;
		public Decimal quantity;
		public Decimal unitPrice;
		public Decimal listPrice;
		public Boolean totvsItem;
		public String orderCode;
		public String productCode;

		public OrderItem serialize() {
			OrderItem orderItem = new OrderItem(
				ExternalId__c	= this.itemCode,
				Quantity		= this.quantity,
				UnitPrice		= this.unitPrice,
				ListPrice		= this.listPrice,
				isOnTotvs__c	= this.totvsItem,
				Order			= new Order(ExternalId__c = this.orderCode),
				Product2 		= new Product2(ExternalId__c = this.productCode)
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
			return this.orderCode;
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
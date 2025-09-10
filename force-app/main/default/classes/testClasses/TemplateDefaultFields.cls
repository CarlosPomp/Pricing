public with sharing class TemplateDefaultFields {
	public interface FieldDefaults {
		Map<String, Object> getFieldDefaults(Decimal countSObjectCreated);
	}

	public class UserDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Username' => 'test' + Datetime.now().getTime() +'@test.com',
				'LastName' => 'taak',
				'Email' => 'test@taak.com',
				'Alias' => 'ttst',
				'CommunityNickname' => 'ttst',
				'TimeZoneSidKey' => 'America/Sao_Paulo',
				'LocaleSidKey' => 'pt_BR',
				'EmailEncodingKey' => 'ISO-8859-1',
				'LanguageLocaleKey' => 'pt_BR',
				'IsActive' => true
			};
		}
	}

	public class AccountDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Account - Teste ' + String.valueOf(countSObjectCreated),
                'CNPJ__c' => '1234567890' + String.valueOf(countSObjectCreated)
			};
		}
	}

    public class AccountAddressDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Address__c' => 'Address - Teste ' + String.valueOf(countSObjectCreated),
                'CEP__c' => '00000-000',
                'Code__c' => String.valueOf(countSObjectCreated),
                'Neighborhood__c' => 'Neighborhood - Teste ' + String.valueOf(countSObjectCreated)
			};
		}
    }

    public class AccountGroupDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name__c' => 'Account Group - Teste ' + String.valueOf(countSObjectCreated),
                'Code__c' => String.valueOf(countSObjectCreated)
			};
		}
    }

	public class ContactDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
                'Email' => 'contact' + String.valueOf(countSObjectCreated) + '@test.com',
                'FirstName' => 'Contact -',
				'LastName' => 'Teste ' + String.valueOf(countSObjectCreated),
                'MobilePhone' => '1234567890',
                'Phone' => '1234567890'
			};
		}
	}

	public class AssetDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Asset - Teste ' + String.valueOf(countSObjectCreated)
			};
		}
	}

	public class OrderDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
                'DeliveryDate__c' => Date.today(),
				'EffectiveDate' => Date.today().addDays(1),
                'FreightType__c' => 'CIF',
				'Status' => 'Draft'
			};
		}
	}

	public class OrderItemDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
                'Quantity' => 1,
                'UnitPrice' => 100
			};
		}
	}

	public class ProblemDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Subject' => 'Problem Test',
				'Urgency' => 'Low',
				'Impact' => 'Low',
				'Priority' => 'Low',
				'Status' => 'New'
			};
		}
	}

	public class Product2Defaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Product Test ' + String.valueOf(countSObjectCreated),
				'ExternalId' => 'Product Test ' + String.valueOf(countSObjectCreated),
				'IsActive' => true,
                'ProductionCost__c' => 100
			};
		}
	}

    public class ProductHierarchyDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name__c' => 'Product Hierarchy Test ' + String.valueOf(countSObjectCreated),
				'Code__c' => String.valueOf(countSObjectCreated)
			};
		}
    }

	public class PricebookEntryDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'UnitPrice' => 100,
				'IsActive' => true
			};
		}
	}

	public class TaskDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Priority' => 'Low',
				'Subject' => 'Task Test ' + String.valueOf(countSObjectCreated),
				'StartDate__c' => Date.today().addDays(1),
				'EndDate__c' => Date.today().addDays(5)
			};
		}
	}

	public class EventDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Subject' => 'Email',
				'StartDate__c' => Date.today().addDays(1),
				'EndDate__c' => Date.today().addDays(5)
			};
		}
	}

	public class EventTypeDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Event Type Test ' + String.valueOf(countSObjectCreated),
				'IsActive__c' => true
			};
		}
	}

	public class OpportunityDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Opportunity Test ' + String.valueOf(countSObjectCreated),
				'StageName' => 'Qualification',
				'CloseDate' => Date.today().addDays(1)
			};
		}
	}

	public class OpportunityLineItemDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{};
		}
	}

	public class LeadDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'LastName' => 'Lead Test ' + String.valueOf(countSObjectCreated),
				'Company' => 'Lead Company Test ' + String.valueOf(countSObjectCreated),
				'Status' => 'New'
			};
		}
	}

    public class PayConditionDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Pay Condition Test ' + String.valueOf(countSObjectCreated),
				'Code__c' => 'PC' + String.valueOf(countSObjectCreated)
			};
		}
    }

    public class DistributionCenterDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name__c' => 'Distribution Center Test ' + String.valueOf(countSObjectCreated),
				'Code__c' => 'DC' + String.valueOf(countSObjectCreated)
			};
		}
    }

    public class CityDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name__c' => 'City Test ' + String.valueOf(countSObjectCreated),
				'Code__c' => String.valueOf(countSObjectCreated)
			};
		}
    }

    public class StateDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name__c' => 'State Test ' + String.valueOf(countSObjectCreated),
				'Acronym__c' => String.valueOf(countSObjectCreated)
			};
		}
    }

    public class CountryDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name__c' => 'Country Test ' + String.valueOf(countSObjectCreated),
				'Acronym__c' => String.valueOf(countSObjectCreated)
			};
		}
    }

    public class ShippingFeeDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
                'Status__c' => 'Approved',
                'Value__c' => 10
            };
        }
    }

    public class TaxDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
                'Status__c' => 'Approved',
                'TaxPercentage__c' => 10
            };
        }
    }

    public class MarginDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
                'Status__c' => 'Approved',
                'Value__c' => 10
            };
        }
    }
}
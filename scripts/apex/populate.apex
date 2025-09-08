List<Tax__c> taxes = [SELECT Id FROM Tax__c];

delete taxes;

List<ShippingFee__c> fees = [SELECT Id FROM ShippingFee__c];

delete fees;

List<Margin__c> margins = [SELECT Id FROM Margin__c];

delete margins;

List<City__c> cities = [SELECT Id FROM City__c];

delete cities;

List<State__c> states = [SELECT Id FROM State__c];

delete states;

List<Country__c> countries = [SELECT Id FROM Country__c];

delete countries;
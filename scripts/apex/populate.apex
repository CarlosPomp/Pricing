Contact c1 = new Contact(Email = 'Test1@email.com', Phone = '1234567890', MobilePhone = '1234567890');
Contact c2 = new Contact(Phone = '22222222', MobilePhone = '22222222');
Contact c3 = new Contact(Email = 'Test3@email.com', MobilePhone = '33333333');
Contact c4 = new Contact(Email = 'Test4@email.com', Phone = '44444444');

Integer numContacts = [SELECT Id FROM Contact].size();

try {
    Database.insert(new List<Contact>{c1, c2, c3, c4}, false);
} catch (DmlException e) {
    System.debug('Erro ao inserir contatos: ' + e.getMessage());
}

System.debug('Contatos inseridos: ' + ([SELECT Id FROM Contact].size() - numContacts));
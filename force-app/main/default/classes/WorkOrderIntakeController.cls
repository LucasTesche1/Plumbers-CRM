public with sharing class WorkOrderIntakeController {
    @AuraEnabled
    public static void submitWorkOrder(
        String name, 
        String phone, 
        String email, 
        String address, 
        String description, 
        String preferredTime,
        Decimal estimatedCost,
        List<Id> fileIds)
        {

        //Checks if the contact being register, already exists and save your id.
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];
        Contact contact;

        if (!contacts.isEmpty()) {
            contact = contacts[0];
        } else {
            contact = new Contact(
                LastName = name,
                Email = email,
                Phone = phone
            );
            insert contact;
        }


        //Create work order
        Work_Order__c order = new Work_Order__c(
            Customer__c = contact.Id,
            Address__c = address,
            Description__c = description,
            Status__c = 'New',
            Preferred_Time__c = preferredTime,
            Estimated_Cost__c = estimatedCost
        );

        insert order;

        //Relate files
        if (fileIds != null && fileIds.size() > 0){
            List<ContentDocumentLink> links = new List<ContentDocumentLink>();
            for (Id docId : fileIds){
                links.add(new ContentDocumentLink(
                    ContentDocumentId = docId,
                    LinkedEntityId = order.Id,
                    ShareType = 'V'
                ));
            }
            insert links;
        }

    }   

    //Future feature: email sent logic
}
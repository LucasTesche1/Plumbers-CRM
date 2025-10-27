@IsTest
public class WorkOrderIntakeControllerTest {

    @TestSetup
    static void setupTestData() {

        Contact existingContact = new Contact(
            LastName = 'Existing',
            Email = 'existing@example.com',
            Phone = '1234567890'
        );
        insert existingContact;
    }

    @IsTest
    static void testSubmitWorkOrder_NewContact_NoFiles() {
        String name = 'John Doe';
        String phone = '9876543210';
        String email = 'john@example.com';
        String address = '123 Main St';
        String description = 'Fix the AC';
        String preferredTime = 'Morning';
        Decimal estimatedCost = 150;

        Test.startTest();
        WorkOrderIntakeController.submitWorkOrder(
            name, phone, email, address, description, preferredTime, estimatedCost, null
        );
        Test.stopTest();

        Contact createdContact = [SELECT Id, LastName, Email, Phone FROM Contact WHERE Email = :email LIMIT 1];
        System.assertEquals('John Doe', createdContact.LastName);
        System.assertEquals('9876543210', createdContact.Phone);

        Work_Order__c wo = [SELECT Id, Customer__c, Address__c, Description__c, Status__c, Preferred_Time__c, Estimated_Cost__c
                            FROM Work_Order__c WHERE Customer__c = :createdContact.Id LIMIT 1];
        System.assertEquals(address, wo.Address__c);
        System.assertEquals(description, wo.Description__c);
        System.assertEquals('New', wo.Status__c);
        System.assertEquals(preferredTime, wo.Preferred_Time__c);
        System.assertEquals(estimatedCost, wo.Estimated_Cost__c);
    }

    @IsTest
    static void testSubmitWorkOrder_ExistingContact_WithFiles() {
        Contact existingContact = [SELECT Id FROM Contact WHERE Email = 'existing@example.com' LIMIT 1];

        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test Content')
        );
        insert cv;

        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        Test.startTest();
        WorkOrderIntakeController.submitWorkOrder(
            'Ignored Name', 
            '0000000000', 
            existingContact.Email, 
            '456 Elm St', 
            'Fix the heater', 
            'Afternoon', 
            200, 
            new List<Id>{docId}
        );
        Test.stopTest();

        Integer contactCount = [SELECT COUNT() FROM Contact WHERE Email = :existingContact.Email];
        System.assertEquals(1, contactCount);

        Work_Order__c wo = [SELECT Id, Customer__c, Address__c, Description__c, Status__c, Preferred_Time__c, Estimated_Cost__c
                            FROM Work_Order__c WHERE Customer__c = :existingContact.Id ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals('456 Elm St', wo.Address__c);
        System.assertEquals('Fix the heater', wo.Description__c);
        System.assertEquals('New', wo.Status__c);
        System.assertEquals('Afternoon', wo.Preferred_Time__c);
        System.assertEquals(200, wo.Estimated_Cost__c);

        ContentDocumentLink link = [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType
                                    FROM ContentDocumentLink WHERE LinkedEntityId = :wo.Id LIMIT 1];
        System.assertEquals(docId, link.ContentDocumentId);
        System.assertEquals('V', link.ShareType);
    }

    @IsTest
    static void testSubmitWorkOrder_NullFileIds() {
        Test.startTest();
        WorkOrderIntakeController.submitWorkOrder(
            'Alice', '1112223333', 'alice@example.com', '789 Oak St', 
            'Check plumbing', 'Evening', 120, new List<Id>()
        );
        Test.stopTest();
    
        Work_Order__c wo = [SELECT Id FROM Work_Order__c WHERE Description__c = 'Check plumbing' LIMIT 1];
    
        List<ContentDocumentLink> links = [
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :wo.Id
        ];
        System.assertEquals(0, links.size(), 'No files should be linked when fileIds is empty');
    }
}
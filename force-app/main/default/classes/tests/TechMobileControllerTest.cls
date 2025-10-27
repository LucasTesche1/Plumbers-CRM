@IsTest
public class TechMobileControllerTest {

    @TestSetup
    static void setupTestData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser' + System.currentTimeMillis() + '@example.com'
        );
        insert testUser;

        System.runAs(testUser) {
            // Create related records
            Account acc = new Account(Name='Test Account');
            insert acc;

            // Assuming Assigned_Tech__r.User__c refers to a Contact or Custom User reference
            Contact tech = new Contact(LastName='Tech', AccountId=acc.Id);
            insert tech;

            // Work Orders assigned to the "tech"
            Work_Order__c wo = new Work_Order__c(
                Name = 'Test Work Order',
                Description__c = 'Test description',
                Status__c = 'Open',
                Assigned_Tech__c = tech.Id,
                Estimated_Cost__c = 100
            );
            insert wo;
        }
    }

    @IsTest
    static void testGetWorkOrders() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' LIMIT 1];
    
        System.runAs(testUser) {
            Test.startTest();
            List<Work_Order__c> workOrders = TechMobileController.getWorkOrders();
            Test.stopTest();
    
            System.assertNotEquals(0, workOrders.size(), 'Work orders should be returned');
            System.assertEquals('Test Work Order', workOrders[0].Name);
        }
    }

    @IsTest
    static void testAddMaterial() {
        Work_Order__c wo = [SELECT Id FROM Work_Order__c LIMIT 1];

        TechMobileController.MaterialInput input = new TechMobileController.MaterialInput();
        input.workOrderId = wo.Id;
        input.materialName = 'Test Material';
        input.quantity = 2;
        input.cost = 50;

        Test.startTest();
        TechMobileController.addMaterial(input);
        Test.stopTest();

        List<Material_Item__c> materials = [SELECT Id, Name, Quantity__c, Unit_Price__c FROM Material_Item__c WHERE Work_Order__c = :wo.Id];
        System.assertEquals(1, materials.size(), 'Material item should be inserted');
        System.assertEquals('Test Material', materials[0].Name);
        System.assertEquals(2, materials[0].Quantity__c);
        System.assertEquals(50, materials[0].Unit_Price__c);
    }

    @IsTest
    static void testFinalizeJob() {
        Work_Order__c wo = [SELECT Id, Estimated_Cost__c FROM Work_Order__c LIMIT 1];

        Test.startTest();
        Map<String, Object> result = TechMobileController.finalizeJob(wo.Id, 5, 'Service performed');
        Test.stopTest();

        System.assertEquals(true, result.get('success'));
        System.assertEquals(String.valueOf(wo.Id), result.get('workOrderId'));
        System.assertEquals(100 + 5 * 50, Double.valueOf(result.get('finalCost')));

        wo = [SELECT Status__c, Final_Cost__c FROM Work_Order__c WHERE Id = :wo.Id];
        System.assertEquals('Completed', wo.Status__c);
        System.assertEquals(100 + 5 * 50, wo.Final_Cost__c);
    }

    @IsTest
    static void testFinalizeJobMissingId() {
        Test.startTest();
        Map<String, Object> result = TechMobileController.finalizeJob(null, 5, 'Service performed');
        Test.stopTest();

        System.assertEquals(false, result.get('success'));
        System.assertEquals('Work order ID is missing.', result.get('message'));
    }
}
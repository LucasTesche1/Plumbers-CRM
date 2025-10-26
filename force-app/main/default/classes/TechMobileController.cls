public with sharing class TechMobileController {

    @AuraEnabled(cacheable=true)
    public static List<Work_Order__c> getWorkOrders() {
        Id userId = UserInfo.getUserId();

        if (!Schema.sObjectType.Work_Order__c.isAccessible()) {
            throw new SecurityException('User does not have access to Work Orders.');
        }

        List<String> requiredFields = new List<String>{
            'Id', 'Name', 'Description__c', 'Status__c', 'Final_Cost__c', 'Assigned_Tech__r.Name'
        };

        for (String fieldName : requiredFields) {
            if (!Schema.sObjectType.Work_Order__c.fields.getMap().containsKey(fieldName)) {
                continue;
            }
            if (!Schema.sObjectType.Work_Order__c.fields.getMap().get(fieldName).getDescribe().isAccessible()) {
                throw new SecurityException('User does not have access to field: ' + fieldName);
            }
        }

        return [
            SELECT Id, Name, Description__c, Status__c, Final_Cost__c, Assigned_Tech__r.Name
            FROM Work_Order__c
            WHERE Assigned_Tech__r.User__c = :userId
            ORDER BY CreatedDate DESC
        ];
    }

    public class MaterialInput {
        @AuraEnabled public Id workOrderId;
        @AuraEnabled public String materialName;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal cost;
    }

    @AuraEnabled
    public static void addMaterial(MaterialInput input) {
        Material_Item__c mat = new Material_Item__c(
            Work_Order__c = input.workOrderId,
            Name = input.materialName,
            Quantity__c = input.quantity,
            Unit_Price__c = input.cost
        );

        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.CREATABLE,
            new List<Material_Item__c>{ mat }
        );

        insert decision.getRecords();
    }

    @AuraEnabled
    public static Map<String, Object> finalizeJob(Id workOrderId, Decimal hoursWorked, String serviceDesc) {
        Map<String, Object> result = new Map<String, Object>{
            'success' => false,
            'message' => ''
        };
        
        try {
            if (workOrderId == null) {
                result.put('message', 'Work order ID is missing.');
                return result;
            }

            Work_Order__c wo = [
                SELECT Id, Estimated_Cost__c, Final_Cost__c
                FROM Work_Order__c
                WHERE Id = :workOrderId
                LIMIT 1
            ];

            Decimal estimated = wo.Estimated_Cost__c != null ? wo.Estimated_Cost__c : 0;
            Decimal finalCost = estimated + (hoursWorked != null ? hoursWorked * 50 : 0);

            wo.Final_Cost__c = finalCost;
            wo.Status__c = 'Completed';

            SObjectAccessDecision decision = Security.stripInaccessible(
                AccessType.UPDATABLE,
                new List<Work_Order__c>{ wo }
            );
            update decision.getRecords();

            // Retorne apenas tipos seguros
            result.put('success', true);
            result.put('workOrderId', String.valueOf(wo.Id));
            result.put('finalCost', Double.valueOf(finalCost));

        } catch (Exception e) {
            result.put('success', false);
            result.put('message', e.getMessage());
        }
        
        return result;
    }

}

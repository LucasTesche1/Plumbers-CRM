trigger WorkOrder_SendEmail_Trigger on Work_Order__c (after insert) {
    List<Id> newIds = new List<Id>();
    for (Work_Order__c w : Trigger.new) {
        newIds.add(w.Id);
    }
    SendEmailAlertAction.send(newIds);
}

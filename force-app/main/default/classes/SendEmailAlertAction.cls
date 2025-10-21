public with sharing class SendEmailAlertAction{
    @InvocableMethod(label='Enviar Email de Confirmação')
    public static void send(List<Id> workOrderIds){
        List<Work_Order__c> orders = [
            SELECT Id, Name, Customer__r.Email, Customer__r.Name, Estimated_Cost__c, Preferred_Time__c
            FROM Work_Order__c
            WHERE Id IN :workOrderIds
        ];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for(Work_Order__c order : orders){
            if(order.Customer__r != null && String.isNotBlank(order.Customer__r.Email)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {order.Customer__r.Email});
                mail.setSubject('Confirmação de Agendamento - Ordem de Serviço ' + order.Name);
                mail.setPlainTextBody(
                    'Hello ' + order.Customer__r.Name + ',\n\n' +
                    'Your work order has been succefully register!\n\n' +
                    '📋 Details:\n' +
                    '- Number: ' + order.Name + '\n' +
                    '- Preferred Time: ' + String.valueOf(order.Preferred_Time__c) + '\n' +
                    '- Estimated Cost: R$ ' + String.valueOf(order.Estimated_Cost__c) + '\n\n' +
                    'Thank you for chosing Plumbers CRM!\n\n' +
                    'Sincerely,\nPlumbers CRM Service.'                    
                );
                emails.add(mail);
            }
        }
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
}
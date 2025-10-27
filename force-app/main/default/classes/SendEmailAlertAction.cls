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
                mail.setSubject('Appointment Confirmation - Work Order ' + order.Name);
                String htmlBody = ''
                    + '<!DOCTYPE html>'
                    + '<html>'
                    + '<head>'
                    + '<meta charset="UTF-8"/>'
                    + '<style>'
                    + '  body { font-family: Arial, sans-serif; background-color: #f8f9fa; padding: 20px; }'
                    + '  .container { max-width: 600px; margin: auto; background: #ffffff; border-radius: 10px; padding: 25px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }'
                    + '  .header { text-align: center; color: #0047AB; font-size: 22px; margin-bottom: 20px; }'
                    + '  .details { font-size: 16px; color: #333; }'
                    + '  .details p { margin: 8px 0; }'
                    + '  .footer { margin-top: 30px; font-size: 14px; color: #777; text-align: center; }'
                    + '  .highlight { color: #0047AB; font-weight: bold; }'
                    + '</style>'
                    + '</head>'
                    + '<body>'
                    + '  <div class="container">'
                    + '    <div class="header">✅ Work Order Confirmation</div>'
                    + '    <div class="details">'
                    + '      <p>Hello <strong>' + order.Customer__r.Name + '</strong>,</p>'
                    + '      <p>Your request has been succefully register! Here it is your order details:</p>'
                    + '      <p><strong>Number:</strong> ' + order.Name + '</p>'
                    + '      <p><strong>Preferred Time:</strong> ' + String.valueOf(order.Preferred_Time__c) + '</p>'
                    + '      <p><strong>Estimated Cost:</strong> R$ ' + String.valueOf(order.Estimated_Cost__c) + '</p>'
                    + '      <p>Our team will contact you shortly to confirm the appointment.</p>'
                    + '    </div>'
                    + '    <div class="footer">'
                    + '      <p>Sincerely,</p>'
                    + '      <p class="highlight">PLUMBERS CRM Service Squad</p>'
                    + '    </div>'
                    + '  </div>'
                    + '</body>'
                    + '</html>';

                    mail.setHtmlBody(htmlBody);
                    emails.add(mail);
            }
        }
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
}
/**
 * @description       : 
 * @author            : Siddharth Patni
 * @group             : 
 * @last modified on  : 10-04-2021
 * @last modified by  : Siddharth Patni
**/
public with sharing class Utility {
    public static List<Id> addIdsLists( List<List<Id>> nestedList){
        List<Id> result = new List<Id>();
        for (List<Id> idList : nestedList) {
            result.addAll(idList);
        }
        return result;
    }
    public static void sendMail(String displayName, List<String> toAddresses, String subject, String body){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName(displayName);
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    public static void sendHTMLMail(String displayName, List<String> toAddresses, String subject, String body){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName(displayName);
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        //.setPlainTextBody(HTMLTags.removeTags(body));
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}

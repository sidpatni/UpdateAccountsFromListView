/**
 * @description       : Utility class 
 * @author            : Siddharth Patni
 * @group             : 
 * @last modified on  : 10-05-2021
 * @last modified by  : Siddharth Patni
**/
public with sharing class Utility {
    /**
    * @description : accepts nested list of Ids and return list containing all elements
    * @author Siddharth Patni | 10-04-2021 
    * @param nestedList 
    * @return List<Id> 
    **/
    public static List<Id> addIdsLists( List<List<Id>> nestedList){
        List<Id> result = new List<Id>();
        for (List<Id> idList : nestedList) {
            result.addAll(idList);
        }
        return result;
    }
    /**
    * @description : send mail with plain body as text
    * @author Siddharth Patni | 10-04-2021 
    * @param displayName Sender's Name
    * @param toAddresses List of Emails(String) to send email
    * @param subject subject for mail 
    * @param body body of mail in simple string
    **/
    public static void sendMail(String displayName, List<String> toAddresses, String subject, String body){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName(displayName);
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    /**
    * @description : send mail with HTML body as text
    * @author Siddharth Patni | 10-04-2021 
    * @param displayName Sender's Name
    * @param toAddresses List of Emails(String) to send email
    * @param subject subject for mail 
    * @param body HTML code of string type to send as body of email
    **/
    public static void sendHTMLMail(String displayName, List<String> toAddresses, String subject, String body){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName(displayName);
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    /**
    * @description return list of all mentioned user in ConnectApi.Comment
    * @author Siddharth Patni | 10-05-2021 
    * @param comment 
    * @return List<Id> 
    **/
    public static List<Id> getMentionedUsers(ConnectApi.Comment comment){
        List<Id> mentionedUsersId = new List<Id>();
        List<ConnectApi.MessageSegment> messageSegments = comment.Body.messageSegments;
        
        for (ConnectApi.MessageSegment messageSegment : messageSegments) {
            if (messageSegment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                mentionedUsersId.add(mentionSegment.record.id);
            }
        } 
        return mentionedUsersId;
    }
    /**
    * @description return list of all mentioned user in ConnectApi.FeedItem
    * @author Siddharth Patni | 10-05-2021 
    * @param comment 
    * @return List<Id> 
    **/
    public static List<Id> getMentionedUsers(ConnectApi.FeedItem feed){
        List<Id> mentionedUsersId = new List<Id>();
        List<ConnectApi.MessageSegment> messageSegments = feed.Body.messageSegments;
        for (ConnectApi.MessageSegment messageSegment : messageSegments) {
            if (messageSegment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                mentionedUsersId.add(mentionSegment.record.id);
            }
        } 
        return mentionedUsersId;
    }
    /**
    * @description returns list of email addresses of users
    * @author Siddharth Patni | 10-05-2021 
    * @param userIds 
    * @param users 
    * @return List<String> 
    **/
    public static List<String> getEmailAddresses(Set<Id> userIds,Map<Id,User> users){
        List<String> emailAddresses = new List<String>();
        for (Id userId : userIds){
            emailAddresses.add(users.get(userId).Email);
        }
        return emailAddresses;
    }
    /**
    * @description lists accounrs EntitySubscription
    * @author Siddharth Patni | 10-05-2021 
    * @param subscribersList 
    * @return Map<Id, List<Id>> 
    **/
    public static Map<Id,List<Id>> mapRecordToFollowers(List<EntitySubscription> subscribersList){
        Map<Id,List<Id>> recordFollowersMap = new Map<Id,List<Id>>();
        for (EntitySubscription esObj : subscribersList){
            List<Id> followersList;
            if ( recordFollowersMap.get(esObj.ParentId) == null ){
                followersList = new List<Id>();
            } else {
                followersList = recordFollowersMap.get(esObj.ParentId);
            }
            followersList.add(esObj.SubscriberId);
            recordFollowersMap.put(esObj.ParentId,followersList);
        }
        return recordFollowersMap;
    }
    
    /*@AuraEnabled
    public static Boolean deleteSimilarRecordsSetups(List<String> recordIds){
        try {
            List<SimilarRecordsSetup__c> deletableRecords = [SELECT Id FROM SimilarRecordsSetup__c WHERE Id IN :recordIds];
            System.debug(deletableRecords);
            delete deletableRecords;
            return true;
        } catch (Exception e) {
            return false;
        }
    }*/
    
    /**
    * @author Siddharth Patni | 10-26-2021 
    * @param objectApiName 
    * @param recordId 
    * @param commaSeparatedFields 
    * @return String : returns record in JSON string 
    **/
    @AuraEnabled
    public static String getRecord(String objectApiName,String recordId, String commaSeparatedFields){
        try {
            String query = 'SELECT '+ commaSeparatedFields + ' FROM ' + objectApiName + ' WHERE Id = \'' + recordId + '\' LIMIT 1';
            List<sObject> result = Database.query(query);
            return JSON.serialize(result[0]);
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}

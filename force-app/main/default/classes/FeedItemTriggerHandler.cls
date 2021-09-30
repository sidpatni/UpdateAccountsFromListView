/**
 * @description       : FeedItemTrigger's helper class. sends email to all followers except mentioned users
 * @author            : Siddharth Patni
 * @last modified on  : 09-30-2021
 * @last modified by  : Siddharth Patni
**/
public with sharing class FeedItemTriggerHandler {

    public static void sendEmail(List<FeedItem> feedItemList){

        // getting list of all followers
        List<EntitySubscription> subscribersList=[SELECT SubscriberId,id FROM EntitySubscription WHERE ParentId =: feedItemList[0].ParentId LIMIT 999];
        List<Id> subscribersIds=new List<Id>();

        if(subscribersList.size()>0){
            /* Getting List of Mentioned Users */
            List<ID> idsOfMentionedUsers = new List<ID>();
    
            ConnectApi.FeedElement feedItem = ConnectApi.ChatterFeeds.getFeedElement(null, feedItemList[0].id);
            List<ConnectApi.MessageSegment> messageSegments = feedItem.body.messageSegments;
            for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                if (messageSegment instanceof ConnectApi.MentionSegment) {
                    ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                    idsOfMentionedUsers.add(mentionSegment.record.id);
                }
            }

            // listing all subscriber's Id and removing all mentioned users from them
            for(EntitySubscription subscriber:subscribersList){
                if(!idsOfMentionedUsers.contains(subscriber.subscriberId)){
                    subscribersIds.add(subscriber.subscriberId);
                }
            }
            
            // fetch email addresses and stored them in list
            List<user> users=[ SELECT Email FROM User WHERE Id IN :subscribersIds];
            List<String> toAddresses=new List<String>();
            for(user userObj:users){
                toAddresses.add(userObj.email);
            }
            
            // send Email
            if(toAddresses.size()>0){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSenderDisplayName('Salesforce Support');
                mail.setToAddresses(toAddresses);
                mail.setSubject('new post on record you have followed');
                String temp=HTMLTags.removeTags(feedItemList[0].body);
                System.debug(temp);
                mail.setPlainTextBody(temp);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
}
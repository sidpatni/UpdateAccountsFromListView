/**
* @description       : FeedCommentTrigger's helper class sends email to all followers of object except mentioned users
* @author            : Siddharth Patni
* @last modified on  : 09-30-2021
* @last modified by  : Siddharth Patni
**/
public with sharing class FeedCommentTriggerHandler {
    
    public static void sendEmail( List<FeedComment> commentList ){
        //Getting list of all followers
        List<EntitySubscription> subscribersList = [ SELECT SubscriberId,Id FROM EntitySubscription WHERE ParentId =: commentList[0].ParentId LIMIT 999 ];
        List<Id> subscribersIds = new List<Id>();
        
        if (subscribersList.size() > 0){
            /* Get List of Mentioned Users */
            List<Id> mentionedUserIds = new List<Id>();
            
            ConnectApi.Comment comment = ConnectApi.ChatterFeeds.getComment(null, commentList[0].Id);
            List<ConnectApi.MessageSegment> messageSegments = comment.body.messageSegments;
            for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                if ( messageSegment instanceof ConnectApi.MentionSegment ) {
                    ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                    mentionedUserIds.add(mentionSegment.record.id);
                }
            }
            // listing id and then fetching email of all followers except mentioned users
            for ( EntitySubscription subscriber : subscribersList ){
                if ( ! mentionedUserIds.contains( subscriber.subscriberId ) ){
                    subscribersIds.add( subscriber.subscriberId );
                }
            }
            List<user> users = [SELECT Email FROM User WHERE Id IN :subscribersIds];
            List<String> toAddresses = new List<String>();
            
            // listing emails
            for ( user userObj : users ){
                toAddresses.add( userObj.email );
            }
            
            // sending email
            if(toAddresses.size()>0){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSenderDisplayName('Salesforce Support');
                mail.setToAddresses(toAddresses);
                mail.setSubject('New comment on post of record you have followed');
                mail.setPlainTextBody(HTMLTags.removeTags(commentList[0].commentBody));
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    } 
}

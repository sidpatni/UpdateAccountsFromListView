/**
* @description       : FeedCommentTrigger's helper class sends email to all followers of object except mentioned users
* @author            : Siddharth Patni
* @last modified on  : 10-04-2021
* @last modified by  : Siddharth Patni
**/
public with sharing class FeedCommentTriggerHandler {
    public static final String COMMUNITY_ID = null ;
    @TestVisible public static Integer accountCount ;
    @TestVisible public static Integer feedCount ;

    public static void handleEmail(Map<Id,FeedComment> feedCommentMap){
        
        List<Id> accountsId = new List<Id>();
        for ( feedComment comment : feedCommentMap.values() ) {
            //listing Records of account type
            if( ((String)comment.ParentId ).startsWith('001') ){
                accountsId.add(comment.ParentId);
            }
        }
        // getting list of all followers
        List<EntitySubscription> subscribersList = [SELECT SubscriberId,Id,ParentId
                                                    FROM EntitySubscription 
                                                    WHERE ParentId IN :accountsId 
                                                    LIMIT 999 ];
        /* mapping account to followers */
        Map<Id,List<Id>> accountFollowersMap = mapAccountToFollowers(subscribersList);
        
        Map<Id,User> users = new Map<Id,User>([SELECT Id,Name,Email FROM User]); 
        Map<Id,Account> accounts = new Map<Id,Account>([SELECT Id,Name FROM Account WHERE Id IN :new List<Id>(accountFollowersMap.keySet())]); 

        if (subscribersList.size() > 0){
           
            Map<Id,List<Id>> commentMentionMap = new Map<Id,List<Id>>();
            ConnectApi.BatchResult[] batchResults = ConnectApi.ChatterFeeds.getCommentBatch( COMMUNITY_ID, new List<Id> (feedCommentMap.keySet()));
            for (ConnectApi.BatchResult batchResult : batchResults) {
                if (batchResult.isSuccess() && batchResult.getResult() instanceof ConnectApi.Comment) {
                    ConnectApi.Comment feedComment = (ConnectApi.Comment) batchResult.getResult();
                    commentMentionMap.put(feedComment.Id,getMentionedUsers(feedComment));
                }
            }

            accountCount = accountFollowersMap.size();
            feedCount = commentMentionMap.size();

            for (FeedComment comment : feedCommentMap.values()) {
                Set<Id> followersSet = new Set<Id>(accountFollowersMap.get(comment.ParentId));
                // removing mentioned users
                followersSet.removeAll( commentMentionMap.get(comment.Id) );
                List<String> toAddresses = getEmailAddresses(followersSet,users);
                
                if (toAddresses.size() > 0){
                    String displayName = 'Salesforce Support';	
                    String subject = users.get(comment.InsertedById).Name + ' Commented on a post of account ' + accounts.get(comment.ParentId).Name;
                    String body = buildHtmlBody(accounts.get(comment.ParentId),users.get(comment.InsertedById),comment);
                    Utility.sendHTMLMail(displayName, toAddresses, subject, body); 
                }
            }
        }
    }
    public static Map<Id,List<Id>> mapAccountToFollowers(List<EntitySubscription> subscribersList){
        Map<Id,List<Id>> accountFollowersMap = new Map<Id,List<Id>>();
        for (EntitySubscription esObj : subscribersList){
            List<Id> followersList;
            if ( accountFollowersMap.get(esObj.ParentId) == null ){
                followersList = new List<Id>();
            } else {
                followersList = accountFollowersMap.get(esObj.ParentId);
            }
            followersList.add(esObj.SubscriberId);
            accountFollowersMap.put(esObj.ParentId,followersList);
        }
        return accountFollowersMap;
    }
    public static List<Id> getMentionedUsers(ConnectApi.Comment comment){
        List<Id> mentionedUsersId = new List<Id>();
        List<ConnectApi.MessageSegment> messageSegments = comment.Body.messageSegments;
        for (ConnectApi.MessageSegment messageSegment : messageSegments) {
            if (messageSegment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                mentionedUsersId.add(mentionSegment.record.Id);
            }
        }  
        return mentionedUsersId;
    }
    public static List<String> getEmailAddresses(Set<Id> userIds,Map<Id,User> users){
        List<String> emailAddresses = new List<String>();
        for(Id userId : userIds){
            emailAddresses.add(users.get(userId).Email);
        }
        return emailAddresses;
    }
    public static String buildHtmlBody(Account accountObj,User userObj,FeedComment commentObj){
        String body = 'Hi,<br><br>'
                    + 'There is a new comment on a post of account <a href="https://concretio-9b-dev-ed.lightning.force.com/lightning/r/Account/' + accountObj.Id + '/view">' + accountObj.Name 
                    + '</a> By <a href="https://concretio-9b-dev-ed.lightning.force.com/lightning/r/User/' + userObj.Id + '/view">' + userObj.Name 
                    + '</a><br><br>To view/reply please click on the link <a href="https://concretio-9b-dev-ed.lightning.force.com/' + commentObj.FeedItemId + '">Reply/View</a>' ;
        return body;
    }
}   
  
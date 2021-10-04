/**
 * @description       : FeedItemTrigger's helper class. sends email to all followers except mentioned users
 * @author            : Siddharth Patni
 * @last modified on  : 10-04-2021
 * @last modified by  : Siddharth Patni
**/
public with sharing class FeedItemTriggerHandler {
    public static final String COMMUNITY_ID = null ;
    @TestVisible public static Integer accountCount ;
    @TestVisible public static Integer feedCount ;

    public static void handleEmail(Map<Id,FeedItem> feedItemMap){
        List<Id> accountsId = new List<Id>();
        for ( FeedItem feed : feedItemMap.values() ) {
            //listing Records of account type and post of test or content type
            if( ((String)feed.ParentId ).startsWith('001') && (feed.type == 'TextPost' || feed.type == 'ContentPost') ){
                accountsId.add(feed.ParentId);
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
            /* Getting List of Mentioned Users */
            Map<Id,List<Id>> feedMentionMap = new Map<Id,List<Id>>();
            ConnectApi.BatchResult[] batchResults = ConnectApi.ChatterFeeds.getFeedElementBatch( COMMUNITY_ID, new List<Id> (feedItemMap.keySet()));
            for (ConnectApi.BatchResult batchResult : batchResults) {
                if (batchResult.isSuccess() && batchResult.getResult() instanceof ConnectApi.FeedItem) {
                    ConnectApi.FeedItem feedItem = (ConnectApi.FeedItem) batchResult.getResult();
                    feedMentionMap.put(feedItem.Id,getMentionedUsers(feedItem));
                }
            }

            accountCount = accountFollowersMap.size();
            feedCount = feedMentionMap.size();

            for (FeedItem feed : feedItemMap.values()) {
                if(accountFollowersMap.get(feed.ParentId) != null){
                    Set<Id> followersSet = new Set<Id>(accountFollowersMap.get(feed.ParentId));
                    // removing mentioned users
                    if(feedMentionMap.get(feed.id) != null){
                        followersSet.removeAll( feedMentionMap.get(feed.id) );
                    }
                    List<String> toAddresses = getEmailAddresses(followersSet,users);
                    
                    if (toAddresses.size() > 0){
                        String displayName = 'Salesforce Support';	
                        String subject = users.get(feed.InsertedById).Name+' made new post on account '+accounts.get(feed.ParentId).Name;
                        String body = buildHtmlBody(accounts.get(feed.ParentId),users.get(feed.InsertedById),feed);
                        Utility.sendHTMLMail(displayName, toAddresses, subject, body); 
                    }
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
    public static List<Id> getMentionedUsers(ConnectApi.FeedItem feedItem){
        List<Id> mentionedUsersId = new List<Id>();
        List<ConnectApi.MessageSegment> messageSegments = feedItem.body.messageSegments;
        for (ConnectApi.MessageSegment messageSegment : messageSegments) {
            if (messageSegment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                mentionedUsersId.add(mentionSegment.record.id);
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
    public static String buildHtmlBody(Account accountObj,User userObj,FeedItem feedObj){
        String body = 'Hi,<br><br>'
                    +'There is a new post on account <a href="https://concretio-9b-dev-ed.lightning.force.com/lightning/r/Account/'+accountObj.Id+'/view">'+accountObj.Name 
                    +'</a> By <a href="https://concretio-9b-dev-ed.lightning.force.com/lightning/r/User/'+userObj.Id+'/view">'+userObj.Name 
                    + '</a><br><br>To view/reply please click on the link <a href="https://concretio-9b-dev-ed.lightning.force.com/'+feedObj.Id+'">Reply/View</a>';
        return body;
    }
}
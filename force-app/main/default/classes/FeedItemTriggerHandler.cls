/**
 * @description       : FeedItemTrigger's helper class. sends email to all followers except mentioned users
 * @author            : Siddharth Patni
 * @last modified on  : 10-05-2021
 * @last modified by  : Siddharth Patni
**/
public with sharing class FeedItemTriggerHandler {
    public static final String COMMUNITY_ID = null ;
    public static final String DISPLAY_NAME = 'Salesforce Support' ;

    public static void handleAfterInsert(Map<Id,FeedItem> feedItemMap){
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
        Map<Id,List<Id>> accountFollowersMap = Utility.mapRecordToFollowers(subscribersList);
        
        Map<Id,User> users = new Map<Id,User>([SELECT Id,Name,Email FROM User]); 
        Map<Id,Account> accounts = new Map<Id,Account>([SELECT Id,Name FROM Account WHERE Id IN :new List<Id>(accountFollowersMap.keySet())]); 

        if (subscribersList.size() > 0){
            /* Getting List of Mentioned Users */
            Map<Id,List<Id>> feedMentionMap = new Map<Id,List<Id>>();
            ConnectApi.BatchResult[] batchResults = ConnectApi.ChatterFeeds.getFeedElementBatch( COMMUNITY_ID, new List<Id> (feedItemMap.keySet()));
            for (ConnectApi.BatchResult batchResult : batchResults) {
                if (batchResult.isSuccess() && batchResult.getResult() instanceof ConnectApi.FeedItem) {
                    ConnectApi.FeedItem feedItem = (ConnectApi.FeedItem) batchResult.getResult();
                    feedMentionMap.put(feedItem.Id,Utility.getMentionedUsers(feedItem));
                }
            }

            for (FeedItem feed : feedItemMap.values()) {
                if(accountFollowersMap.get(feed.ParentId) != null){
                    Set<Id> followersSet = new Set<Id>(accountFollowersMap.get(feed.ParentId));
                    // removing mentioned users
                    if(feedMentionMap.get(feed.id) != null){
                        followersSet.removeAll( feedMentionMap.get(feed.id) );
                    }
                    List<String> toAddresses = Utility.getEmailAddresses(followersSet,users);
                    
                    if (toAddresses.size() > 0){
                        String subject = users.get(feed.InsertedById).Name+' made new post on account '+accounts.get(feed.ParentId).Name;
                        String body = buildHtmlBody(accounts.get(feed.ParentId),users.get(feed.InsertedById),feed);
                        Utility.sendHTMLMail(DISPLAY_NAME, toAddresses, subject, body); 
                    }
                }
            }
        }
    }
   
    /**
    * @description builds html body having link to account, user and FeedItem
    * @author Siddharth Patni | 10-05-2021 
    * @param accountObj 
    * @param userObj 
    * @param feedObj 
    * @return String 
    **/
    public static String buildHtmlBody(Account accountObj,User userObj,FeedItem feedObj){
        String instanceName = System.Url.getSalesforceBaseUrl().toExternalForm();
        String body = 'Hi,<br><br>'
                    + 'There is a new post on account <a href="' + instanceName + '/lightning/r/Account/' + accountObj.Id + '/view">'+accountObj.Name 
                    + '</a> By <a href="' + instanceName + '/lightning/r/User/' + userObj.Id + '/view">' + userObj.Name 
                    + '</a><br><br>To view/reply please click on the link <a href="' + instanceName + '/'+feedObj.Id+'">Reply/View</a>';
        return body;
    }
}
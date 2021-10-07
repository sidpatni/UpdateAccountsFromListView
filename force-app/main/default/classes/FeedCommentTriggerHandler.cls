/**
* @description       : FeedCommentTrigger's helper class sends email to all followers of object except mentioned users
* @author            : Siddharth Patni
* @last modified on  : 10-05-2021
* @last modified by  : Siddharth Patni
**/
public with sharing class FeedCommentTriggerHandler {
    public static final String COMMUNITY_ID = null ;
    public static final String DISPLAY_NAME = 'Salesforce Support';	

    public static void handleAfterInsert(Map<Id,FeedComment> feedCommentMap){
        
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
        Map<Id,List<Id>> accountFollowersMap = Utility.mapRecordToFollowers(subscribersList);
        Map<Id,User> users = new Map<Id,User>([SELECT Id,Name,Email FROM User]); 
        Map<Id,Account> accounts = new Map<Id,Account>([SELECT Id,Name FROM Account WHERE Id IN :new List<Id>(accountFollowersMap.keySet())]); 

        if (subscribersList.size() > 0){
           
            Map<Id,List<Id>> commentMentionMap = new Map<Id,List<Id>>();
            ConnectApi.BatchResult[] batchResults = ConnectApi.ChatterFeeds.getCommentBatch( COMMUNITY_ID, new List<Id> (feedCommentMap.keySet()));
            for (ConnectApi.BatchResult batchResult : batchResults) {
                if (batchResult.isSuccess() && batchResult.getResult() instanceof ConnectApi.Comment) {
                    ConnectApi.Comment feedComment = (ConnectApi.Comment) batchResult.getResult();
                    commentMentionMap.put(feedComment.Id,Utility.getMentionedUsers(feedComment));
                }
            }

            for (FeedComment comment : feedCommentMap.values()) {
                Set<Id> followersSet = new Set<Id>(accountFollowersMap.get(comment.ParentId));
                // removing mentioned users
                followersSet.removeAll( commentMentionMap.get(comment.Id) );
                List<String> toAddresses = Utility.getEmailAddresses(followersSet,users);
                
                if (toAddresses.size() > 0){
                    String subject = users.get(comment.InsertedById).Name + ' Commented on a post of account ' + accounts.get(comment.ParentId).Name;
                    String body = buildHtmlBody(accounts.get(comment.ParentId),users.get(comment.InsertedById),comment);
                    Utility.sendHTMLMail(DISPLAY_NAME, toAddresses, subject, body); 
                }
            }
        }
    }
    
    /**
    * @description builds html body having link to account , user and FeedItem on which comment is made
    * @author Siddharth Patni | 10-05-2021 
    * @param accountObj 
    * @param userObj 
    * @param commentObj 
    * @return String 
    **/
    public static String buildHtmlBody(Account accountObj,User userObj,FeedComment commentObj){
        String instanceName = System.Url.getSalesforceBaseUrl().toExternalForm();
        String body = 'Hi,<br><br>'
                    + 'There is a new comment on a post of account <a href="' + instanceName + '/lightning/r/Account/'+accountObj.Id+'/view">' + accountObj.Name 
                    + '</a> By <a href="' + instanceName + '/lightning/r/User/' + userObj.Id + '/view">' + userObj.Name 
                    + '</a><br><br>To view/reply please click on the link <a href="' + instanceName + '/' + commentObj.FeedItemId + '">Reply/View</a>' ;
        return body;
    }
}   
  
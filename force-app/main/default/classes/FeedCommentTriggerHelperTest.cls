/**
 * @description       : 
 * @author            : Siddharth Patni
 * @group             : 
 * @last modified on  : 09-29-2021
 * @last modified by  : Siddharth Patni
**/
@isTest(SeeAllData=true)
public with sharing class FeedCommentTriggerHelperTest {
    
    @isTest static void testInsertFeedComment() {
        
        // creating test data
        List<User> users = CreateFeedTriggerTestData.createUsers();
        Account accountObj = CreateFeedTriggerTestData.createAccount();
        CreateFeedTriggerTestData.followAccounts(accountObj,users);
        FeedItem feed = new FeedItem (
            parentid = accountObj.id,
            type = 'ContentPost',
            Body = 'My Wi-Fi is not working, please help.'
        );  
        insert feed;
        
        // creating comment with mentioned user
        String communityId = null;
        String feedElementId = feed.id;

        ConnectApi.CommentInput commentInput = new ConnectApi.CommentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        textSegmentInput.text = 'Does anyone in this group have an idea or facing same issue ? ';
        messageBodyInput.messageSegments.add(textSegmentInput);

        mentionSegmentInput.id = users[0].Id;
        messageBodyInput.messageSegments.add(mentionSegmentInput);

        commentInput.body = messageBodyInput;

        Test.startTest();
        ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postCommentToFeedElement(communityId, feedElementId, commentInput, null);    
        Test.stopTest();      
    }
}

/**
 * @author            : Siddharth Patni
 * @last modified on  : 10-05-2021
 * @last modified by  : Siddharth Patni
**/
@isTest(SeeAllData=true)
public with sharing class FeedCommentTriggerHandlerTest {
    
    @isTest static void feedCommentWithMention() {
        // creating test data
        List<User> users = CreateFeedTriggerTestData.createUsers(2);
        Account accountObj = CreateFeedTriggerTestData.createAccounts(1)[0];
        CreateFeedTriggerTestData.followAccount(accountObj,users[0]);
        CreateFeedTriggerTestData.followAccount(accountObj,users[1]);


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
    @isTest static void feedCommentWithoutMention() {
        
        User usr = CreateFeedTriggerTestData.createUsers(1)[0];
        Account accountObj = CreateFeedTriggerTestData.createAccounts(1)[0];
        CreateFeedTriggerTestData.followAccount(accountObj,usr);
        FeedItem fi1 = new FeedItem (
                ParentId = accountObj.Id,
                body = 'post 1 on account 1'
            );
        FeedItem fi2 = new FeedItem (
            ParentId = accountObj.Id,
            body = 'post 2 on account 1'
        );
        insert new List<FeedItem>{fi1,fi2};
        List<FeedComment> comments = new List<FeedComment>();
        for (Integer i = 0; i < 5; i++) {
            FeedComment comment = new FeedComment();
            comment.FeedItemId = i < 3 ?  fi1.Id :  fi2.Id ;
            comment.CommentBody = 'test comment ' + i ;
            comments.add(comment);
        }
        insert comments;
    }
}

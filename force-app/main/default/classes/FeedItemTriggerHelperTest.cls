/**
 * @description       : Test Class
 * @author            : Siddharth Patni
 * @last modified on  : 09-29-2021
 * @last modified by  : Siddharth Patni
**/
@isTest(SeeAllData=true)
public class FeedItemTriggerHelperTest {
    
    @isTest static void testInsertFeedItem() {
        // creating test data
        List<User> users = CreateFeedTriggerTestData.createUsers();
        Account accountObj = CreateFeedTriggerTestData.createAccount();
        CreateFeedTriggerTestData.followAccounts(accountObj,users);

        
        /* Create a FeedItem for testing */
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        mentionSegmentInput.id = users[0].id;
        messageBodyInput.messageSegments.add(mentionSegmentInput);

        textSegmentInput.text = 'My laptop is not working, Could you take a look?';
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = accountObj.id;

        Test.startTest();
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        Test.stopTest();      
    }
}

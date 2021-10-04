/**
 * @description       : Test Class
 * @author            : Siddharth Patni
 * @last modified on  : 10-04-2021
 * @last modified by  : Siddharth Patni
**/
@isTest(SeeAllData=true)
public class FeedItemTriggerHandlerTest {
    
    @isTest static void bulkFeedItemWithMentioned() {
        // creating test data
        List<User> users = CreateFeedTriggerTestData.createUsers(5);
        List<Account> accounts = CreateFeedTriggerTestData.createAccounts(5);
        CreateFeedTriggerTestData.followAccounts(accounts,users);
        
        /* Create a FeedItems for testing */
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

        for (Integer i = 0; i < 5; i++) {

            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

            mentionSegmentInput.Id = users[i].Id;
            messageBodyInput.messageSegments.add(mentionSegmentInput);

            textSegmentInput.text = 'My laptop is not working, Could you take a look?' + i ;
            messageBodyInput.messageSegments.add(textSegmentInput);

            feedItemInput.body = messageBodyInput;
            feedItemInput.subjectId = accounts[i].Id;

            batchInputs.add(new ConnectApi.BatchInput(feedItemInput));
        }

        Test.startTest();
        ConnectApi.BatchResult[] feedElement = ConnectApi.ChatterFeeds.postFeedElementBatch(null, batchInputs);
        Test.stopTest();  

        System.assertEquals(FeedItemTriggerHandler.accountCount , 4, 'test failed ');
        System.assertEquals(FeedItemTriggerHandler.feedCount , 5, 'test failed');
    }
    
    @isTest static void bulkFeedItemWithoutMentioned(){
        List<User> users = CreateFeedTriggerTestData.createUsers(2);
        List<Account> accounts = CreateFeedTriggerTestData.createAccounts(2);
        CreateFeedTriggerTestData.followAccount(accounts[0],users[0]);
        CreateFeedTriggerTestData.followAccount(accounts[1],users[1]);


        Test.startTest();
            FeedItem fi1 = new FeedItem (
                ParentId = accounts[0].Id,
                Body = 'post 1 on account 1'
            );
            FeedItem fi2 = new FeedItem (
                ParentId = accounts[1].Id,
                Body = 'post 2 on account 2'
            );
            FeedItem fi3 = new FeedItem (
                ParentId = accounts[0].Id,
                Body = 'post 2 on account 1'
            );
            insert  new List<FeedItem>{fi1,fi2,fi3};
        Test.stopTest();    
        System.assertEquals(FeedItemTriggerHandler.accountCount , 2, 'test failed check parentID');
        System.assertEquals(FeedItemTriggerHandler.feedCount , 3, 'test failed check feeds');
    }
}

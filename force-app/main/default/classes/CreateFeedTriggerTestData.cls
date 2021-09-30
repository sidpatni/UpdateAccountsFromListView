/**
 * @description       : Create Test Data for Feed Trigger test
 * @author            : Siddharth Patni
 * @last modified on  : 09-30-2021
 * @last modified by  : Siddharth Patni
**/
@isTest
public class CreateFeedTriggerTestData {
    public static List<User> createUsers(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr1 = new User( LastName = 'Sahil',
                          FirstName='JASON',
                          Alias = 'jliv',
                          Email = 's.manglani@concret.io',
                          Username = 'koonal.liveston@sdfc.com',
                          ProfileId = profileId.id,
                          TimeZoneSidKey = 'GMT',
                          LanguageLocaleKey = 'en_US',
                          EmailEncodingKey = 'UTF-8',
                          LocaleSidKey = 'en_US'
                          );
       
       User usr2 = new User(LastName = 'Kunal',
                          FirstName='JASON',
                          Alias = 'jliv',
                          Email = 'sidpatni@concret.io',
                          Username = 'kunal.liveston@sdfc.com',
                          ProfileId = profileId.id,
                          TimeZoneSidKey = 'GMT',
                          LanguageLocaleKey = 'en_US',
                          EmailEncodingKey = 'UTF-8',
                          LocaleSidKey = 'en_US'
                          );
        List<User> users = new List<User>{usr1,usr2};
        insert users;
        return users;
    }
    public static Account createAccount(){
        Account accountObj = new Account (Name = 'Rohit');
        insert accountObj;
        return accountObj;
    }
       
    public static void followAccounts(Account acc,List<User> userIds){
       EntitySubscription es1 = new EntitySubscription();
       es1.ParentId = acc.Id;
       es1.SubscriberId = userIds[0].Id;

       EntitySubscription es2 = new EntitySubscription();
       es2.ParentId = acc.Id;
       es2.SubscriberId = userIds[1].Id;
       List<EntitySubscription> esList= new List<EntitySubscription>{es1,es2};
       insert esList;
    }
}

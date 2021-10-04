/**
 * @description       : Create Test Data for Feed Trigger test
 * @author            : Siddharth Patni
 * @last modified on  : 10-04-2021
 * @last modified by  : Siddharth Patni
**/
@isTest
public class CreateFeedTriggerTestData {
    public static List<User> createUsers(Integer count){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        List<User> users = new List<User>();
        for (Integer i = 0; i < count; i++) {
            User usr = new User( FirstName = 'Test',
                            LastName = 'User' + i,
                            Alias = 'jliv'+i,
                            Email = 'sidpatni@concret.io',
                            Username = 'TestUserUniqueUsername00'+i+'@feed.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                            );
            users.add(usr);
        }
        insert users;
        return users;
    }   
    public static List<Account> createAccounts(Integer count){
        List<Account> accounts = new List<Account> ();
        for (Integer i = 0; i < count; i++) {
            Account accountObj = new Account();
            accountObj.Name = 'Test Account ' + i ;
            accounts.add(accountObj);
        }
        insert accounts;
        return accounts;
    }
       
    public static void followAccounts( List<Account> accounts, List<User> users){
        System.debug(accounts);
        System.debug(users);
        List<EntitySubscription> esList = new List<EntitySubscription>();
        for (Integer i = 0; i < accounts.size(); i++) {
            for (Integer j = 0; j < i; j++) {
                EntitySubscription es = new EntitySubscription();
                es.ParentId = accounts[i].Id;
                es.SubscriberId = users[j].Id;
                System.debug(es);
                esList.add(es);
            }
        }
        insert esList;
    }
    public static void followAccount( Account acc, User usr){
        EntitySubscription es1 = new EntitySubscription();
        es1.ParentId = acc.Id;
        es1.SubscriberId = usr.Id;
        insert es1;
    }
}

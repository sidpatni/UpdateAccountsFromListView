/**
 * @description       : 
 * @author            : Siddharth Patni
 * @group             : 
 * @last modified on  : 10-04-2021
 * @last modified by  : Siddharth Patni
**/
@isTest
public with sharing class UtilityTest {
    @isTest
    private static void testAllMethods() {
        Test.startTest();
            List<List<Id>> nestedList = new List<List<Id>>();
            for (Integer i = 0; i < 5; i++) {
                List<Id> ids = new List<Id>{'0015g00000SIKufAAH','0015g00000TDRXUAA5','0015g00000TDRXVAA5','0015g00000TDRXeAAP','0015g00000TDRXfAAP'};
                nestedList.add(ids);
            }
            List<Id> result = Utility.addIdsLists(nestedList);
            List<String> toAddresses = new List<String>{'sidjain@concret.io','akashjain@gmail.com'};
            Utility.sendMail('Support',toAddresses,'new mail', 'This is a test mail');
            Utility.sendHTMLMail('Support',toAddresses,'new mail', '<b>This is a test mail</b>');
            
        Test.stopTest();
        System.assertEquals(result.size(),25,'test method failed');
    }
}

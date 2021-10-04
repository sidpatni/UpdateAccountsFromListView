/**
 * @description       : Send email to all followers of record whenever new post is made
 * @author            : Siddharth Patni
 * @last modified on  : 09-30-2021
 * @last modified by  : Siddharth Patni
**/
trigger FeedItemTrigger on FeedItem (after insert) {
    FeedItemTriggerHandler.handleEmail(new Map<Id,FeedItem> (Trigger.new));
}
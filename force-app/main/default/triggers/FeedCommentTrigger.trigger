/**
 * @description       : Send email to all followers of record whenever new comment is posted
 * @author            : Siddharth Patni
 * @last modified on  : 10-04-2021
 * @last modified by  : Siddharth Patni
**/
trigger FeedCommentTrigger on FeedComment (after insert) {
    FeedCommentTriggerHandler.handleAfterInsert(new Map<Id,FeedComment> (Trigger.new));
}
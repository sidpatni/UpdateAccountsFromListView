/**
 * @description       : Send email to all followers of record whenever new comment is posted
 * @author            : Siddharth Patni
 * @last modified on  : 09-29-2021
 * @last modified by  : Siddharth Patni
**/
trigger FeedCommentTrigger on FeedComment (after insert) {
    FeedCommentTriggerHelper.sendEmail(Trigger.new);
}
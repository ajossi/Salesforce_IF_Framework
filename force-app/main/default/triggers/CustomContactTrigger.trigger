/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 05-08-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
trigger CustomContactTrigger on CustomContact__c (before insert, after insert, before update, after update, before delete, after delete) {
    try{
        new CustomContactTriggerHandler().run();
    }catch(Exception e){
        System.debug(e.getMessage());
    } 
}
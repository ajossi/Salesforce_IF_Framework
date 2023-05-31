/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 05-09-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
trigger AccountTrigger on Account (before insert, after insert, before update, after update, before delete, after delete) {
    try{
        new AccountTriggerHandler().run();
    }catch(Exception e){
        System.debug(e.getMessage());
    } 
}
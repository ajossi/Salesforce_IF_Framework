/**
 * 
 * @author 조형준
 * @since 2022. 12. 30
 * @description BatchGroupManagementController Test Class
 * @group Trigger
 * 
 */
@isTest
public with sharing class BatchGroupManagementController_Test {
    @TestSetup
    static void makeData(){
        IF_TestDataFactory fac = new IF_TestDataFactory();
        // fac.createAlertManager();
        fac.createBatchManager();

        BatchGroup__c bg = new BatchGroup__c(
            Name = 'Test Group'
            ,GroupName__c = 'Test Group'
            ,Schedule__c = true
            ,Interval__c = 5
        );
        Insert bg;

        List<BatchManager__c> bmList = [SELECT Id
                                                ,Name
                                        FROM BatchManager__c
                                        WHERE Name LIKE '%Test%'
                                        ];
        
        BatchSequenceManager__c bsm = new BatchSequenceManager__c(
            BatchGroup__c = bg.Id
            ,BatchManager__c = bmList[0].Id
            ,Sequence__c = 1
        );
        Insert bsm;
    }

    @isTest
    static void test1(){
        Test.StartTest();
        BatchGroupManagementController.getGroupData();
        BatchGroupManagementController.getSequenceData();
        BatchGroupManagementController.getTableData();
        BatchGroupManagementController.scheduledBatch('Test Group');
        BatchGroupManagementController.abortSchedule('Test Group');
        BatchGroupManagementController.executeBatch('TestBatch');
        BatchGroupManagementController.getScheduleData();
        Test.StopTest();
    }
}
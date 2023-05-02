@isTest
public class MasterBatchScheduler_Test {
    @TestSetup
    static void makeData(){
        BatchManager__c batchManager = new BatchManager__c(
            Name = 'TestBatch'
            , Active__c = true
            , ScopeSize__c = 200
            , Params__c = 'test'
        );

        Insert batchManager;

        BatchManager__c batchManager2 = new BatchManager__c(
            Name = 'TestBatch2'
            , Active__c = true
            , ScopeSize__c = 200
            , Params__c = 'test'
        );

        Insert batchManager2;

        BatchManager__c batchManager3 = new BatchManager__c(
            Name = 'TestQueueable'
            , Active__c = true
            , Params__c = 'test'
        );

        Insert batchManager3;

        BatchGroup__c batchGroup = new BatchGroup__c(
            Name = 'Test Group'
            , Schedule__c = false
            , GroupName__c = 'Test Group'
        );

        Insert batchGroup;

        BatchGroup__c batchGroup2 = new BatchGroup__c(
            Name = 'Test Group2'
            , Schedule__c = true
            , GroupName__c = 'Test Group2'
            , Interval__c = 5
        );

        Insert batchGroup2;

        BatchGroup__c batchGroup3 = new BatchGroup__c(
            Name = 'Test Group3'
            , Schedule__c = true
            , GroupName__c = 'Test Group3'
            , cronText__c = '0 0 5 * * ?'
        );

        Insert batchGroup3;

        BatchSequenceManager__c sequenceManager = new BatchSequenceManager__c(
            Name = 'TestBatch'
            , Sequence__c = 1
            , BatchManager__c = batchManager.Id
            , BatchGroup__c = batchGroup.Id
        );

        Insert sequenceManager;

        BatchSequenceManager__c sequenceManager2 = new BatchSequenceManager__c(
            Name = 'TestBatch2'
            , Sequence__c = 2
            , BatchManager__c = batchManager2.Id
            , BatchGroup__c = batchGroup.Id
        );

        Insert sequenceManager2;

        BatchSequenceManager__c sequenceManager3 = new BatchSequenceManager__c(
            Name = 'TestBatch2'
            , Sequence__c = 1
            , BatchManager__c = batchManager2.Id
            , BatchGroup__c = batchGroup2.Id
        );

        Insert sequenceManager3;

        BatchSequenceManager__c sequenceManager4 = new BatchSequenceManager__c(
            Name = 'TestQueueable'
            , Sequence__c = 1
            , BatchManager__c = batchManager3.Id
            , BatchGroup__c = batchGroup3.Id
        );

        Insert sequenceManager4;
    }

    @isTest
    static void test1(){
        Test.StartTest();
        List<BatchGroup__c> groupList = [SELECT Id ,GroupName__c ,CronText__c ,Schedule__c ,Interval__c FROM BatchGroup__c WHERE Name = 'Test Group2'];
        new MasterBatchScheduler('Test Group2').createScheduleJob();
        new MasterBatchScheduler('Test Group3').createScheduleJob();
        new MasterBatchScheduler('Test Group3').abortJob();
        new MasterBatchScheduler(groupList).createScheduleJob();
        Test.StopTest();
    }
}
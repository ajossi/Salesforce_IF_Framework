/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 05-02-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
@isTest
public class BatchManager_Test {
    @TestSetup
    static void makeData(){
        Account account = new Account(
            Name = 'TEST'
        );
        Insert account;

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
        List<BatchSequenceManager__c> sequenceList = [SELECT Id, BatchManager__r.Name, BatchManager__r.ScopeSize__c, BatchGroup__r.Name FROM BatchSequenceManager__c WHERE BatchGroup__r.Name = 'Test Group' ORDER BY Sequence__c ];
        List<BatchSequenceManager__c> sequenceList2 = [SELECT Id, BatchManager__r.Name, BatchManager__r.ScopeSize__c, BatchGroup__r.Name FROM BatchSequenceManager__c WHERE BatchGroup__r.Name = 'Test Group2' ORDER BY Sequence__c ];
        List<BatchSequenceManager__c> sequenceList3 = [SELECT Id, BatchManager__r.Name, BatchManager__r.ScopeSize__c, BatchGroup__r.Name FROM BatchSequenceManager__c WHERE BatchGroup__r.Name = 'Test Group3' ORDER BY Sequence__c ];
        new BatchManager('TestBatch', true).execute();
        new BatchManager('TestBatch', 200, false).execute();
        new BatchManager('TestBatch', 200, sequenceList).execute();
        new BatchManager('Test Group', sequenceList).execute();
        new BatchManager('Test Group2', sequenceList2).execute();
        new BatchManager('Test Group3', sequenceList3).execute();
        Test.StopTest();
    }
}
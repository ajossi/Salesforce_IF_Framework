@isTest
public class MasterBatch_Test {
    @TestSetup
    static void setup(){
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

        BatchGroup__c batchGroup = new BatchGroup__c(
            Name = 'Test Group'
            , Schedule__c = false
            , GroupName__c = 'Test Group'
        );

        Insert batchGroup;

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
    }

    @isTest
    static void test1(){
        Test.StartTest();
        new BatchManager('TestBatch', true).execute();
        Test.StopTest();
    }

    @isTest
    static void test2(){
        Test.StartTest();
        TestBatch batch = new TestBatch();
        Database.executeBatch(batch);
        Test.StopTest();
    }

    @isTest
    static void test3(){
        Test.StartTest();
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'TEST'];
        account.Name = 'exception';

        Update account;

        TestBatch batch = new TestBatch();
        Database.executeBatch(batch);
        Test.StopTest();
    }
/*
    @isTest
    static void test4(){
        Test.StartTest();
        TestBatch2 batch = new TestBatch2();
        batch.queryStatement = 'Exception Query';
        Database.executeBatch(batch);
        Test.StopTest();
    }*/

    @isTest
    static void test5(){
        Test.StartTest();
        List<BatchSequenceManager__c> sequenceList = [SELECT Id FROM BatchSequenceManager__c];
        Delete sequenceList;
        TestBatch batch = new TestBatch();

        IF_Order__c ifObj = new IF_Order__c(
            IFExternalKey__c = 'test'
        );
        List<IF_Order__c> ifObjList = new List<IF_Order__c>();
        ifObjList.add(ifObj);

        Database.UpsertResult[] urList = Database.Upsert(ifObjList, IF_Order__c.IFExternalKey__c, false);
        Database.SaveResult[] srList = Database.Update(ifObjList, false);

        batch.scheduleExecute();
        batch.saveDMLLog(urList);
        batch.saveDMLLog(srList);

        Database.executeBatch(batch);
        Test.StopTest();
    }
    
    class TestBatch extends MasterBatch{
        public override String startFunction(){
            this.queryStatement = 'SELECT Id'
                + ' FROM Account'
                + ' WHERE Name = \'TEST\''
                + ' ORDER BY LastModifiedDate DESC'
                + ' LIMIT 1';

            return this.queryStatement;
        }

        public override void executeFunction(sObject[] scope){
            List<Account> accountList = (List<Account>)scope;

            System.assertEquals(accountList[0].Name, 'TEST');
        }
    }

    class TestBatch2 extends MasterBatch{
        public override String startFunction(){
            this.queryStatement = 'Exception Query';

            return this.queryStatement;
        }

        public override void executeFunction(sObject[] scope){
            
        }
    }
    
}
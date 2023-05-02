/**
 * 
 * @author 조형준
 * @since 2022. 8. 4
 * @group Common
 */
public abstract without sharing class MasterBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    public List<BatchSequenceManager__c> batchSequenceManagerList{get;set;}
    @testVisible protected String originalTransactionId{get;set;}
    @testVisible protected String queryStatement{get;set;}
    public String scheduleName{get;set;}
    public String batchName{get;set;}
    public Object params{get;set;} //필요한 데이터가 있을 경우 해당 변수에 담아서 사용
    public Integer dmlSuccessCnt = 0;
    public Integer dmlFailCnt = 0;
    
    public transient Database.UpsertResult[] upsertResult{get;set;}
    public transient Database.SaveResult[] saveResult{get;set;}

    /**
     * 
     * @param context 
     * @return  `abstract Database.QueryLocator`
     */    
    public Database.QueryLocator start(Database.BatchableContext context){
        Database.QueryLocator result;

        try{
            System.debug('::::Batch Start::::');
            this.originalTransactionId = Logger.getTransactionId();

            Logger.info('Starting Batch');
            Logger.info('Batch Name : ' + this.batchName);
            Logger.info(this.batchName + ' / Batch Start Time : ' + System.now());
            queryStatement = startFunction();
            Logger.debug('Query Statement == ' + queryStatement);

            result = Database.getQueryLocator(queryStatement);
        }catch(Exception e){
            Logger.error('Error Message == ' + e.getMessage());
            Logger.error('Error Line == ' + e.getStackTraceString());
            Logger.saveLog();
        }finally{
            Logger.saveLog();
        }
        return result;
    }
    /**
     * 
     * @param context 
     * @param scope 
     */    
    public void execute(Database.BatchableContext context, sObject[] scope){
        //Savepoint sp = Database.setSavepoint();
        try{
            if(scope.size() > 0){
                System.debug('::::Batch Execute::::');
                Logger.setParentLogTransactionId(this.originalTransactionId);

                //초기화
                this.upsertResult = new Database.UpsertResult[]{};
                this.saveResult = new Database.SaveResult[]{};
            
                Logger.info('Batch Name : ' + this.batchName);
                Logger.Info('scope Size : ' + scope.size());
                executeFunction(scope); //기능 개발
                if(this.upsertResult != null && this.upsertResult.size() > 0) {
                    saveDMLLog(this.upsertResult);
                }
                if(this.saveResult != null && this.saveResult.size() > 0) {
                    saveDMLLog(this.saveResult);
                }
            }
        }
        catch(Exception e){
            if(String.isNotBlank(this.scheduleName))scheduleExecute();//에러 발생 시 스케줄 재등록

            //롤백은 개별적으로 관리
            //Database.rollback(sp);

            Logger.error('Error Message == ' + e.getMessage());
            Logger.error('Error Line == ' + e.getStackTraceString());
            Logger.saveLog();
        }finally{
            Logger.saveLog();
        }
    }
    /**
     * 
     * @param context 
     * @Description : Log, Sequence, Schedule 등 배치 공통 기능
     */    
    public void finish(Database.BatchableContext context){
        try{
            System.debug('::::Batch Finish::::');
            Logger.setParentLogTransactionId(this.originalTransactionId);
            Logger.info('Finishing Batch');
            Logger.info('Batch Name : ' + this.batchName);
            Logger.info(this.batchName + ' / Batch End Time : ' + System.now());
            Logger.debug(this.batchName + ' DML Success Cnt : ' + this.dmlSuccessCnt);
            Logger.debug(this.batchName + ' DML Fail Cnt : ' + this.dmlFailCnt);

            finishFunction();

            //배치 시퀸스 목록을 제거 및 체크하여 시퀸스가 남아있을 경우 다음 배치 실행
            if(this.batchSequenceManagerList != null && !this.batchSequenceManagerList.isEmpty()){
                this.batchSequenceManagerList.remove(0);

                if(this.batchSequenceManagerList.size() == 0 && this.scheduleName != null){
                    //배치 시퀸스 종료시 스케줄 여부 체크하여 스케줄 등록
                    scheduleExecute();
                }
                else{
                    for(BatchSequenceManager__c obj : this.batchSequenceManagerList){
                        Logger.info('Batch Sequence Manager List', obj);
                    }
                }
            }
            if(this.batchSequenceManagerList != null && !this.batchSequenceManagerList.isEmpty()){
                if(this.params != null){
                    new BatchManager(batchSequenceManagerList, params).execute();
                }
                else{
                    new BatchManager(batchSequenceManagerList).execute();
                } 
            }
        }
        catch(Exception e){
            Logger.error('Error Message == ' + e.getMessage());
            Logger.error('Error Line == ' + e.getStackTraceString());

            scheduleExecute();//에러 발생 시 스케줄 재등록
        }
        finally{
            Logger.saveLog();
        }
    }
    /**
     * 
     * @description start에 작성할 개발코드를 아래 가상 메소드를 선언하여 작성
     */    
    protected virtual String startFunction(){
        return queryStatement;
    }
    /**
     * 
     * @description execute에 작성할 개발코드를 아래 가상 메소드를 선언하여 작성
     */    
    protected virtual void executeFunction(sObject[] scope){}

    /**
     * 
     * @description finish에 작성할 개발코드를 아래 가상 메소드를 선언하여 작성
     */    
    protected virtual void finishFunction(){}

    public void scheduleExecute(){
        new MasterBatchScheduler(this.scheduleName).createScheduleJob();
        Logger.info('Create Schedule Job : ' + this.scheduleName);
    }

    /**
     * 
     * @param objList DML Object List
     * @description DML Log
     */    
    public void saveDMLLog(Database.UpsertResult[] dmlLogList){
        if(dmlLogList != null && dmlLogList.size() > 0){
            for (Database.UpsertResult ur : dmlLogList) {
                if(!ur.isSuccess()){
                    this.dmlFailCnt++;
                    Logger.Error('ERROR : ' + ur.getErrors(), ur);
                }else{
                    this.dmlSuccessCnt++;
                }
            }
        }
    }

    /**
     * 
     * @param objList DML Object List
     * @description DML Log
     */    
    public void saveDMLLog(Database.SaveResult[] dmlLogList){
        if(dmlLogList != null && dmlLogList.size() > 0){
            for (Database.SaveResult sr : dmlLogList) {
                if(!sr.isSuccess()){
                    this.dmlFailCnt++;
                    Logger.Error('ERROR : ' + sr.getErrors(), sr);
                }else{
                    this.dmlSuccessCnt++;
                }
            }
        }
    }
}
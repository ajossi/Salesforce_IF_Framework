/**
 * 
 * @author 조형준
 * @since 2022. 8. 4
 */
public abstract without sharing class MasterQueueable implements Queueable , Database.AllowsCallouts{
    public List<BatchSequenceManager__c> batchSequenceManagerList{get;set;}
    protected String originalTransactionId{get;set;}
    protected List<Object> objList = new List<Object>(); //로그에 기록할 객체목록
    public String scheduleName{get;set;}
    public Object params{get;set;} //필요한 데이터가 있을 경우 해당 변수에 담아서 사용
    public Boolean isTest = false;
    public String batchName{get;set;}
    /**										
     * @Description: execute				
     * @Param:                  						       	
     *	sc : QueueableContext				
    */	
    public void execute(QueueableContext sc) {
        this.originalTransactionId = Logger.getTransactionId();
        try{
            if(isTest) throw new AuraHandledException('Test Exception');
            function();
            finish();
        }catch(Exception e){
            System.debug('Error Message == ' + e.getMessage());
            System.debug('Error Line == ' + e.getStackTraceString());

            Logger.error('Error Message == ' + e.getMessage());
            Logger.error('Error Line == ' + e.getStackTraceString());

            Logger.saveLog();
        }
    }
    /**
     * @description execute에 개발할 코드 여기에 작성
     */    
    public virtual void function(){
    }
    public void finish(){
        //Logger.setParentLogTransactionId(this.originalTransactionId);
        Logger.info('Finishing Batch');
        //배치 시퀸스 목록을 제거 및 체크하여 시퀸스가 남아있을 경우 다음 배치 실행
        if(this.batchSequenceManagerList != null && !this.batchSequenceManagerList.isEmpty()){
            this.batchSequenceManagerList.remove(0);
            
            if(this.batchSequenceManagerList.size() == 0 && this.scheduleName != null){
                //배치 시퀸스 종료시 스케줄 여부 체크하여 스케줄 등록
                new MasterBatchScheduler(this.scheduleName).createScheduleJob();
                Logger.info('Create Schedule Job : ' + this.scheduleName);
            }
            else{
                for(BatchSequenceManager__c obj : this.batchSequenceManagerList){
                    Logger.info('Batch Sequence Manager List', obj);
                }
            }
        } 
        if(this.batchSequenceManagerList != null && !this.batchSequenceManagerList.isEmpty()){
            new BatchManager(batchSequenceManagerList).execute();
        }

        for(Object obj : objList){
            Logger.debug('DML Object : ' + obj);
        }

        Logger.debug('Params : ' + this.Params);
        Logger.saveLog();
    }
}
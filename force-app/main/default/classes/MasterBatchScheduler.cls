/**
 * 
 * @author 조형준
 * @since 2022. 8. 4
 * @description : 공통 배치 스케줄 관리 클래스
 */
public without sharing  class MasterBatchScheduler implements Schedulable {
    //public String batchName{get;set;}
    //public Integer scopeSize{get;set;}
    public String scheduleName{get;set;}
    public String cronText{get;set;}
    public Integer Interval{get;set;}

    public List<BatchGroup__c> batchGroupList{get;set;}
    public List<BatchSequenceManager__c> batchSequenceManagerList{get;set;}
    /**
     * 
     * @param scheduleName : 등록 스케줄명
     */    
    public MasterBatchScheduler(String scheduleName){
        this.scheduleName = scheduleName;
    }
    /**
     * 
     * @param batchGroupList : 배치 그룹 목록
     */    
    public MasterBatchScheduler(List<BatchGroup__c> batchGroupList){
        this.batchGroupList = batchGroupList;
        this.scheduleName = batchGroupList[0].GroupName__c;
    }
    /**
     * 
     * @param SC 
     * @description : 스케줄에 해당하는 배치 등록
     */    
    public void execute(SchedulableContext SC){
        try{
            if(this.batchGroupList == null) this.batchGroupList = getBatchGroupList();
            if(this.batchSequenceManagerList == null) this.batchSequenceManagerList = getBatchSequenceManagerList();

            new BatchManager(scheduleName, batchSequenceManagerList).execute();
        }catch(Exception e){
            new MasterBatchScheduler(this.scheduleName).createScheduleJob();

            System.debug('Error Message == ' + e.getMessage());
            System.debug('Error Line == ' + e.getStackTraceString());
            Logger.error('Error Message == ' + e.getMessage());
            Logger.error('Error Line == ' + e.getStackTraceString());
            Logger.saveLog();
        }
        
    }
    /**
     * 
     * @description : 스케줄 등록
     */    
    public void createScheduleJob(){
        try{
            List<CronTrigger> cronTr = new List<CronTrigger>();
            if(this.batchGroupList == null) this.batchGroupList = getBatchGroupList();
            if(this.batchSequenceManagerList == null) this.batchSequenceManagerList = getBatchSequenceManagerList();

            cronTr = [SELECT Id
                            ,CronExpression
                            ,CronJobDetail.Name
                        FROM CronTrigger 
                        WHERE CronJobDetail.Name =:scheduleName LIMIT 1];
            if(this.interval != null){
               if(cronTr != null && !cronTr.isEmpty()) System.abortJob(cronTr[0].Id);

                Datetime dt     = Datetime.now().addMinutes(this.interval);
                String cronExp  = dt.format('s mm HH') + ' * * ?';

                System.schedule(this.scheduleName, cronExp, new MasterBatchScheduler(scheduleName));
            }
            else{
                System.debug('cronText');
                if(cronTr.size() == 0){
                    System.debug('createScheduleJob : ' + this.scheduleName);
                    System.schedule(this.scheduleName, this.cronText, new MasterBatchScheduler(scheduleName));
                }
            }
        }catch(Exception e){
            System.debug('Error Message == ' + e.getMessage());
            System.debug('Error Line == ' + e.getStackTraceString());
            Logger.error('Error Message == ' + e.getMessage());
            Logger.error('Error Line == ' + e.getStackTraceString());
            Logger.saveLog();
        }
    }
    /**
     * 
     * @return  `List<BatchGroup__c>` : 배치 그룹 목록
     * @description : 스케줄 등록에 사용될 정보 조회
     */    
    public List<BatchGroup__c> getBatchGroupList(){
        List<BatchGroup__c> result = new List<BatchGroup__c>();

        result = [SELECT Id
                            ,GroupName__c
                            ,CronText__c
                            ,Schedule__c
                            ,Interval__c
                        FROM BatchGroup__c
                        WHERE GroupName__c = :scheduleName
                        AND Schedule__c = true];

        if(!result.isEmpty()){
            this.scheduleName = result[0].GroupName__c;
            this.cronText = result[0].CronText__c;
            this.interval = Integer.valueOf(result[0].Interval__c);
        }

        return result;
    }
    /**
     * 
     * @return  `List<BatchSequenceManager__c>` : 배치 순서 목록
     * @description : 스케줄 등록에 사용될 배치정보 조회
     */    
    public List<BatchSequenceManager__c> getBatchSequenceManagerList(){
        List<BatchSequenceManager__c> result = new List<BatchSequenceManager__c>();

        result = [SELECT Id
                            ,Name
                            ,Sequence__c
                            ,BatchGroup__c
                            ,BatchGroup__r.GroupName__c
                            ,BatchGroup__r.Schedule__c
                            ,BatchManager__c
                            ,BatchManager__r.Name
                            ,BatchManager__r.Active__c
                            ,BatchManager__r.ScopeSize__c
                            ,BatchManager__r.Params__c
                        FROM BatchSequenceManager__c
                        WHERE BatchGroup__c = :this.BatchGroupList[0].Id
                        AND BatchManager__r.Active__c = true
                        ORDER BY Sequence__c
                        ];

        return result;
    }

    public void abortJob(){
        List<CronTrigger> cronTr = [SELECT Id
                                                ,CronExpression
                                                ,CronJobDetail.Name
                                        FROM CronTrigger 
                                        WHERE CronJobDetail.Name =:scheduleName LIMIT 1];

        System.abortJob(cronTr[0].Id);
    }
}
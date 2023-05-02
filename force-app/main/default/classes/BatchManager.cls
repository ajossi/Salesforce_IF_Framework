/**
 * 
 * @author 조형준
 * @since 2022. 8. 4
 */
public without sharing class BatchManager {
    public String batchName{get;set;}
    public Integer scopeSize{get;set;}
    public String scheduleName{get;set;}
    public Object params{get;set;}
    public Boolean isGroup{get;set;}//default : true

    public List<BatchSequenceManager__c> batchSequenceManagerList{get;set;}
    public BatchManager__c batchManager{get;set;}
    /**
     * 
     * @param batchName : 실행할 배치 클래스 명
     */    
    public BatchManager(String batchName, Boolean isGroup) {
        this.batchName = batchName;
        this.isGroup = isGroup;
    }
    /**
     * 
     * @param batchName 실행할 배치 클래스 명
     * @param isGroup 실행할 배치의 Grouping 여부
     * @param params 배치 Parameter
     */    
    public BatchManager(String batchName, Boolean isGroup, Object params) {
        this.batchName = batchName;
        this.isGroup = isGroup;
        this.params = params;
    }
    /**
     * 
     * @param batchName : 실행할 배치 클래스 명
     * @param scopeSize : 실행할 배치의 Scope Size
     */     
    public BatchManager(String batchName, Integer scopeSize, Boolean isGroup) {
        this.batchName = batchName;
        this.scopeSize = scopeSize;
        this.isGroup = isGroup;
    }
    /**
     * 
     * @param batchName : 실행할 배치 클래스 명
     * @param scopeSize : 실행할 배치의 Scope Size
     * @param batchSequenceManagerList : 실행할 배치 순서 목록
     */    
    public BatchManager(String batchName, Integer scopeSize, List<BatchSequenceManager__c> batchSequenceManagerList) {
        this.batchName = batchName;
        this.scopeSize = scopeSize;
        this.batchSequenceManagerList = batchSequenceManagerList;
        this.isGroup = true;
    }

    public BatchManager(List<BatchSequenceManager__c> batchSequenceManagerList) {
        this.batchName = batchSequenceManagerList[0].BatchManager__r.Name;
        this.scopeSize = Integer.valueOf(batchSequenceManagerList[0].BatchManager__r.scopeSize__c);
        this.batchSequenceManagerList = batchSequenceManagerList;
        this.isGroup = true;
    }

    public BatchManager(List<BatchSequenceManager__c> batchSequenceManagerList, Object params) {
        this.batchName = batchSequenceManagerList[0].BatchManager__r.Name;
        this.scopeSize = Integer.valueOf(batchSequenceManagerList[0].BatchManager__r.scopeSize__c);
        this.batchSequenceManagerList = batchSequenceManagerList;
        this.isGroup = true;
        this.params = params;
    }

    public BatchManager(String scheduleName, List<BatchSequenceManager__c> batchSequenceManagerList) {
        this.batchName = batchSequenceManagerList[0].BatchManager__r.Name;
        this.scopeSize = Integer.valueOf(batchSequenceManagerList[0].BatchManager__r.scopeSize__c);
        this.batchSequenceManagerList = batchSequenceManagerList;
        this.scheduleName = scheduleName;
        this.isGroup = true;
    }
    /**
     * 
     * @description : 전달된 배치명의 Type을 체크하여 Batch 혹은 Queueable로 실행
     */    
    public void execute(){
        Type childType = Type.forName(batchName);
        Type parentType = MasterBatch.class;
        System.debug('this.batchName : ' + this.batchName);
        System.debug('this.isGroup : ' + this.isGroup);

        try{
            if(this.isGroup){
                if(this.batchSequenceManagerList == null) {
                    this.batchSequenceManagerList = new List<BatchSequenceManager__c>();
                    this.batchSequenceManagerList = getBatchSequenceManagerList();
                }
                if(this.batchSequenceManagerList.size() > 0){
                    System.debug('batchSequenceManagerList : ' + this.batchSequenceManagerList);    
                    this.batchName = this.batchSequenceManagerList[0].BatchManager__r.Name;
                    if(this.scopeSize == null)this.scopeSize = Integer.valueOf(this.batchSequenceManagerList[0].BatchManager__r?.ScopeSize__c);
                    if(this.batchSequenceManagerList[0].BatchManager__r?.params__c != null) this.params = (Object)this.batchSequenceManagerList[0].BatchManager__r?.params__c;
                    if(this.batchSequenceManagerList[0].BatchGroup__r.Schedule__c) this.scheduleName = this.batchSequenceManagerList[0].BatchGroup__r.GroupName__c;
                }
                System.debug('Is Group');
            } else {
                    this.batchSequenceManagerList = new List<BatchSequenceManager__c>();
                    this.batchManager = new BatchManager__c();
                    this.batchManager = getBatchManager();
                    this.batchName = batchManager.Name;
                    if(this.scopeSize == null) this.scopeSize = Integer.valueOf(batchManager?.ScopeSize__c);
                    if(this.params == null && batchManager?.params__c != null) this.params = (Object)batchManager?.params__c;
                    // if(batchManager?.params__c != null) this.params = (Object)batchManager?.params__c;
                    System.debug('Is Not Group');
            }

            Logger.debug('batchName : ' + this.batchName);
            Logger.debug('isGroup : ' + this.isGroup);
            Logger.debug('scopeSize : ' + this.scopeSize);
            Logger.debug('params : ' + this.params);
            Logger.debug('scheduleName : ' + this.scheduleName);
            Logger.debug('batchSequenceManagerList : ' + this.batchSequenceManagerList);

            if(this.batchSequenceManagerList.size() > 0 || this.batchManager != null){
                if(parentType.isAssignableFrom(childType)){
                    MasterBatch batchJob = (MasterBatch)childType.newInstance();
                    batchJob.batchSequenceManagerList = this.batchSequenceManagerList;
                    batchJob.scheduleName = this.scheduleName;
                    batchJob.batchName = this.batchName;
                    if(this.params != null) batchJob.params = this.params;
                    if(this.scheduleName != null) batchJob.scheduleName = this.scheduleName;
                    Database.executeBatch(batchJob, scopeSize);
                }
                else {
                    MasterQueueable batchJob = (MasterQueueable)childType.newInstance();
                    batchJob.batchSequenceManagerList = this.batchSequenceManagerList;
                    batchJob.scheduleName = this.scheduleName;
                    batchJob.batchName = this.batchName;
                    if(this.params != null) batchJob.params = this.params;
                    if(this.scheduleName != null) batchJob.scheduleName = this.scheduleName;
                    System.enqueueJob(batchJob);
                }
            }else{
                Logger.Debug('No has batch Sequence');
            }
        }catch(Exception e){
            System.debug(e.getStackTraceString());
            Logger.error('error == ' + e.getMessage());
            Logger.error('line == ' + e.getStackTraceString());
        }finally{
            Logger.saveLog();
        }
    }

    public List<BatchSequenceManager__c> getBatchSequenceManagerList(){
        List<BatchSequenceManager__c> result = new List<BatchSequenceManager__c>();

        List<BatchSequenceManager__c> batchSequence = [SELECT Id
                                                            , BatchGroup__c
                                                        FROM BatchSequenceManager__c
                                                        WHERE BatchManager__r.Name = :this.batchName
                                                        AND BatchManager__r.Active__c = true
                                                        ORDER BY Sequence__c
                                                        ];

        if(batchSequence.size() > 0){
            result = [SELECT Id
                                , Name
                                , BatchGroup__c
                                , BatchGroup__r.GroupName__c
                                , BatchGroup__r.Schedule__c
                                , BatchManager__c
                                , BatchManager__r.Name
                                , Sequence__c
                                , BatchManager__r.params__c
                                , BatchManager__r.scopeSize__c
                            FROM BatchSequenceManager__c
                            WHERE BatchGroup__c = :batchSequence[0].BatchGroup__c
                            AND BatchManager__r.Active__c = true
                            ORDER BY Sequence__c
                            ];
                            System.debug('result : ' + result);
        }

        //Batch Name으로 index를 체크하여 이전 목록은 제거
        List<String> tempList = new List<String>();
        for(BatchSequenceManager__c obj : result){
            tempList.add(obj.BatchManager__r.Name);
        }

        if(tempList.indexOf(this.batchName) > -1){
            for(Integer i=0;i<tempList.indexOf(this.batchName);i++){
                result.remove(0);
            }
        }
        System.debug('result : ' + result);
        return result;
    }

    public BatchManager__c getBatchManager(){
        BatchManager__c result = new BatchManager__c();
        result = [SELECT Id
                        , Name
                        , ScopeSize__c
                        , Active__c
                        , Params__c
                    FROM BatchManager__c
                    WHERE Name = :this.batchName
                    AND Active__c = true
                    LIMIT 1];
        
        return result;
    }
}
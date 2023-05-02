/**
 * 
 * @author 조형준
 * @since 2022. 08. 24
 */
public with sharing class BatchGroupManagementController {
    @AuraEnabled(cacheable=false)
    public static List<comboboxWrapper> getGroupData(){
        List<comboboxWrapper> result = new List<comboboxWrapper>();
        try {
            List<BatchGroup__c> groupList = [SELECT Id
                                                    , GroupName__c 
                                                FROM BatchGroup__c 
                                                ORDER BY GroupName__c];
            for(BatchGroup__c obj : groupList){
                result.add(new comboboxWrapper(obj));
            }
            result.add(new comboboxWrapper('none', 'none'));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static sequenceWrapper getSequenceData(){
        sequenceWrapper result = new sequenceWrapper();
        Map<String, List<comboboxWrapper>> sequenceMap = new Map<String, List<comboboxWrapper>>();
        Set<String> setBatchManagerId = new Set<String>();
        try {
            Map<String, String> executeCodeMap = new Map<String, String>();

            for(BatchSequenceManager__c obj : [SELECT Id
                                                    , Name
                                                    , BatchGroup__c
                                                    , Sequence__c
                                                    , BatchManager__c
                                                    , BatchManager__r.ExecuteCode__c
                                                FROM BatchSequenceManager__c
                                                ORDER BY BatchGroup__c, Sequence__c]){
                List<comboboxWrapper> tempList = new List<comboboxWrapper>();
                
                if(sequenceMap.containsKey(obj.BatchGroup__c)) tempList = sequenceMap.get(obj.BatchGroup__c);

                tempList.add(new comboboxWrapper(obj));
                sequenceMap.put(obj.BatchGroup__c, tempList);
                executeCodeMap.put(obj.Name, obj.BatchManager__r.ExecuteCode__c);

                setBatchManagerId.add(obj.BatchManager__c);
            }

            List<comboboxWrapper> noneBatchList = new List<comboboxWrapper>();
            for(BatchManager__c obj : [SELECT Id
                                            , Name
                                            , ExecuteCode__c
                                        FROM BatchManager__c
                                        WHERE Name != null
                                        AND (NOT Id IN :setBatchManagerId)
                                        ORDER BY Name]){
                noneBatchList.add(new comboboxWrapper(obj.Name, obj.Id));
                executeCodeMap.put(obj.Name, obj.ExecuteCode__c);
            }
            sequenceMap.put('none', noneBatchList);

            result.sequenceMap = sequenceMap;
            result.executeCodeMap = executeCodeMap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    @AuraEnabled(cacheable=false) // @wire >> true
    public static Map<String, List<dataTableWrapper>> getTableData(){
        Map<String, List<dataTableWrapper>> result = new Map<String, List<dataTableWrapper>>();

        try{
            List<BatchSequenceManager__c> batchSequenceList = [
            SELECT Id
                , Name
                , Sequence__c
                , BatchGroup__c
                , BatchGroup__r.GroupName__c
                , BatchGroup__r.CronText__c
                , BatchGroup__r.Description__c
                , BatchGroup__r.Schedule__c
                , BatchGroup__r.Interval__c
                , BatchManager__c
                , BatchManager__r.Name
                , BatchManager__r.Description__c
                , BatchManager__r.Active__c
                , BatchManager__r.ScopeSize__c
                //, BatchManager__r.params__c
            FROM BatchSequenceManager__c
            ORDER BY BatchGroup__r.GroupName__c ASC, Sequence__c ASC
            ];

            for(BatchSequenceManager__c obj : batchSequenceList){
                List<dataTableWrapper> tempList = new List<dataTableWrapper>();
                Integer index = batchSequenceList.indexOf(obj);

                if(result.containsKey(obj.BatchGroup__c)) tempList = result.get(obj.BatchGroup__c);
                tempList.add(new dataTableWrapper(obj, index));

                result.put(obj.BatchGroup__c, tempList);
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static void scheduledBatch(String scheduleName){
        try {
            MasterBatchScheduler schedule = new MasterBatchScheduler(scheduleName);
            schedule.createScheduleJob();

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void abortSchedule(String scheduleName){
        try {
            MasterBatchScheduler schedule = new MasterBatchScheduler(scheduleName);
            schedule.abortJob();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String executeBatch(String code){
        try
        {
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + getUserSessionId());
            req.setHeader('Content-Type', 'application/json');
            
            req.setEndpoint(
                Url.getOrgDomainUrl().toExternalForm()
            +   '/services/data/v55.0/tooling/executeAnonymous/?anonymousBody='
            +   EncodingUtil.urlEncode(code, 'UTF-8')
            );
            req.setMethod('GET');

            Http h = new Http();
            HttpResponse res = new HttpResponse();
            if(!Test.isRunningTest()) res = h.send(req);

            return res.getBody();
        }
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage() + ' / ' + e.getLineNumber());
        }
    }

    /**
     * 참고 : https://salesforce.stackexchange.com/questions/223809/salesforce-lightning-how-can-i-get-session-id-of-current-user-in-salesforce-lig
     */
    public static String getUserSessionId(){
        String sessionId = '';
       // Refer to the Page
       PageReference reportPage = Page.DS_GetUserSession;
       // Get the content of the VF page
       String vfContent = '';
       if(!Test.isRunningTest()) 
       { 
        vfContent = reportPage.getContent().toString();
       }
       else
       {
        vfContent = 'Start_Of_Session_Id12345End_Of_Session_Id';
       }
       
       // Find the position of Start_Of_Session_Id and End_Of_Session_Id
       Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
       endP = vfContent.indexOf('End_Of_Session_Id');
       // Get the Session Id
       sessionId = vfContent.substring(startP, endP);
       System.debug('sessionId '+sessionId);
       // Return Session Id
       return sessionId;
    }

    @AuraEnabled(cacheable=false)
    public static List<comboboxWrapper> getScheduleData(){
        List<comboboxWrapper> result = new List<comboboxWrapper>();
        try {
            List<BatchGroup__c> groupList = [SELECT Id
                                                    , GroupName__c 
                                                FROM BatchGroup__c 
                                                WHERE Schedule__c = true
                                                ORDER BY GroupName__c];
            for(BatchGroup__c obj : groupList){
                result.add(new comboboxWrapper(obj));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    public class dataTableWrapper{
        @AuraEnabled public Id batchSequenceId{get;set;}
        @AuraEnabled public Id batchGroupId{get;set;}
        @AuraEnabled public String batchGroupUrl{get;set;}
        @AuraEnabled public String groupName{get;set;}
        @AuraEnabled public Boolean scheduled{get;set;}
        @AuraEnabled public String cronText{get;set;}
        @AuraEnabled public Decimal interval{get;set;}
        @AuraEnabled public String description{get;set;}
        @AuraEnabled public Decimal sequence{get;set;}
        @AuraEnabled public Id batchManagerId{get;set;}
        @AuraEnabled public String batchManagerUrl{get;set;}
        @AuraEnabled public String batchManagerName{get;set;}
        @AuraEnabled public Boolean active{get;set;}
        @AuraEnabled public Decimal scopeSize{get;set;}
        @AuraEnabled public String editId{get;set;}
        @AuraEnabled public String btnId{get;set;}

        public dataTableWrapper(BatchSequenceManager__c obj, integer index){
            this.batchSequenceId = obj.Id;
            this.batchGroupId = obj.BatchGroup__c;
            this.batchGroupUrl = System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + obj.BatchGroup__c;
            this.groupName = obj.BatchGroup__r.GroupName__c;
            this.scheduled = obj.BatchGroup__r.Schedule__c;
            this.cronText = obj.BatchGroup__r.CronText__c;
            this.interval = obj.BatchGroup__r.Interval__c;
            this.description = obj.BatchGroup__r.Description__c;
            this.sequence = obj.Sequence__c;
            this.batchManagerId = obj.BatchManager__c;
            this.batchManagerUrl = System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + obj.BatchManager__c;
            this.batchManagerName = obj.BatchManager__r.Name;
            this.active = obj.BatchManager__r.Active__c;
            this.scopeSize = obj.BatchManager__r.ScopeSize__c;
            this.editId = 'edit' + index;
            this.btnId = 'btn' + index;
        }
    }

    public class sequenceWrapper{
        @AuraEnabled public Map<String, List<comboboxWrapper>> sequenceMap{get;set;}
        @AuraEnabled public Map<String, String> executeCodeMap{get;set;}
    }

    public class comboboxWrapper{
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String value{get;set;}
        

        public comboboxWrapper(BatchGroup__c obj){
            this.label = obj.GroupName__c;
            this.value = obj.Id;
        }

        public comboboxWrapper(BatchSequenceManager__c obj){
            this.label = obj.Name;
            this.value = obj.Id;
        }

        public comboboxWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}
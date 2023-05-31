/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 05-31-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
public with sharing class API_ManagementController {
    //Get API Routing Records Method
    @AuraEnabled(cacheable=false)
    public static List<API_Routing__mdt> getApiRecords(String recordId){
        String objectName = 'API_Routing__mdt';

        List<Schema.DescribeFieldResult> fieldAPIList = getFieldAPIDescribe(objectName);
        List<API_Routing__mdt> apiList = new List<API_Routing__mdt>();

        String querySelect = 'SELECT ';
        String queryFrom = ' FROM ' + objectName;
        String queryWhere = ' WHERE Id = ';

        for(Schema.DescribeFieldResult field : fieldAPIList){
            querySelect += field.getName() + ',';
        }

        querySelect = querySelect.removeEnd(',');

        if(String.isNotBlank(recordId)){
            queryWhere += '\'' + recordId + '\'';
            apiList = Database.query(querySelect + queryFrom + queryWhere);
        }else{
            apiList = Database.query(querySelect + queryFrom);
        }

        return apiList;
    }

    //Insert Or Update API Routing Record
    @AuraEnabled(cacheable=false)
    public static void insertUpdateApiRecord(Map<String, Object> inputValues){
        try{
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            // customMetadata.fullName = inputValues.containsKey('Id') ? (String)inputValues.get('Id') : 'API_Routing.' + (String)inputValues.get('interfaceId__c');
            customMetadata.fullName = 'API_Routing.' + (String)inputValues.get('interfaceId__c');
            customMetadata.label = (String)inputValues.get('interfaceId__c');

            for(String str : inputValues.keySet()){
                Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                customField.field = str;
                System.debug('str: ' + str);
                System.debug('inputValues.get(str): ' + inputValues.get(str));
                if(str.equals('isActive__c')){
                    customField.value = (Boolean)inputValues.get(str);
                }else if(str.equals('timeout')){
                    customField.value = (Integer)inputValues.get(str);
                }else{
                    customField.value = (String)inputValues.get(str);
                }

                customMetadata.values.add(customField);
            }

            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);

            // Setup deploy callback, MyDeployCallback implements
            // the Metadata.DeployCallback interface (code for
            // this class not shown in this example)
            CustomMetadataCallback callback = new CustomMetadataCallback();

            // Enqueue custom metadata deployment
            // jobId is the deployment ID
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }catch(Exception e){
            System.debug(e.getStackTraceString());
        }
    }

    public class CustomMetadataCallback implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result,
                                 Metadata.DeployCallbackContext context) {
            if (result.status == Metadata.DeployStatus.Succeeded) {
                System.debug('success: '+ result);
            } else {
                // Deployment was not successful
                System.debug('fail: '+ result);
            }
        }
    }

    public static String getSessionId(String username, String password) {
        String sessionId;
        
        // Salesforce SOAP API를 사용하여 세션 ID 얻기
        try {
            // Salesforce 로그인 정보 설정
            String loginEndpoint = 'https://login.salesforce.com/services/Soap/u/53.0';
            String loginNamespace = 'urn:partner.soap.sforce.com';
            String loginRequest = ''
                + '<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">'
                + '    <env:Header/>'
                + '    <env:Body>'
                + '        <n1:login xmlns:n1="' + loginNamespace + '">'
                + '            <n1:username>' + username + '</n1:username>'
                + '            <n1:password>' + password + '</n1:password>'
                + '        </n1:login>'
                + '    </env:Body>'
                + '</env:Envelope>';

            // Salesforce SOAP API 호출
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(loginEndpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'text/xml');
            request.setHeader('SOAPAction', '""');
            request.setBody(loginRequest);
            HttpResponse response = http.send(request);
            System.debug('getSessionId response : ' + Json.serializePretty(response.getBody()));

            // 세션 ID 추출
            Dom.Document loginResponse = new Dom.Document();
            loginResponse.load(response.getBody());
            String sessionIdElementName = 'sessionId';
            String sessionIdNamespace = 'urn:partner.soap.sforce.com';
            String sessionIdPath = 'Envelope/Body/loginResponse/result/' + sessionIdElementName;
            sessionId = loginResponse.getRootElement()
                .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('loginResponse', loginNamespace)
                .getChildElement('result', loginNamespace)
                .getChildElement(sessionIdElementName, sessionIdNamespace)
                .getText();
        } catch (Exception e) {
            System.debug('Error getting session ID: ' + e.getMessage());
            return null;
        }
        
        return sessionId;
    }

    @AuraEnabled(cacheable=false)
    public static List<logTableWrapper> getLogRecords(String interfaceId) {
        Set<String> setClassName = new Set<String>();
        Set<String> setLogId = new Set<String>();
        List<API_Routing__mdt> apiRoutingList = new List<API_Routing__mdt>();
        List<LogEntryTag__c> logEntryTagList = new List<LogEntryTag__c>();
        List<Log__c> logList = new List<Log__c>();
        List<logTableWrapper> result = new List<logTableWrapper>();

        try {
            apiRoutingList = [SELECT Id
                                    , serviceClass__c 
                            FROM API_Routing__mdt
                            WHERE InterfaceId__c = :interfaceId
                            ];

            for(API_Routing__mdt mdt : apiRoutingList){
                setClassName.add(mdt.serviceClass__c);
            }

            logEntryTagList = [SELECT LogEntry__r.Log__c
                                FROM LogEntryTag__c
                                WHERE Tag__r.Name IN :setClassName
                                ORDER BY LogEntry__r.Log__r.CreatedDate DESC
            ];

            System.debug('apiRoutingList : ' + apiRoutingList);
            System.debug('logEntryTagList : ' + logEntryTagList);

            for(LogEntryTag__c obj : logEntryTagList){
                setLogId.add(obj.LogEntry__r.Log__c);
            }

            logList = [SELECT Name
                            , Owner.Name
                            , TransactionId__c
                            , TotalLogEntries__c
                            , TotalERRORLogEntries__c
                            , Priority__c
                            , StartTime__c 
                        FROM Log__c
                        WHERE Id IN :setLogId
                        ORDER BY Name DESC
                        ];

            for(Log__c obj : logList){
                result.add(new logTableWrapper(obj));
            }

        } catch (Exception e) {
            System.debug('error: ' + e.getMessage());
        }

        return result;
    }

    @AuraEnabled(cacheable=false)
    public static List<String> getDirectionValues() {
        List<String> picklistValues = new List<String>();
        
        // Get the describe result
        Schema.DescribeFieldResult fieldResult =
            API_Routing__mdt.Direction__c.getDescribe();
        
        // Get the picklist values
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        // Loop through the list and add the label to the picklistValues list
        for (Schema.PicklistEntry picklistValue : ple) {
            picklistValues.add(picklistValue.getLabel());
        }
        
        return picklistValues;
    }

    @AuraEnabled(cacheable=false)
    public static String executeCode(String serviceClass, Object requestBody){
        String result = '';
        try
        {
            httpResponse response = new httpResponse();

            API_Request request = new API_Request(serviceClass, requestBody);
            API_Sender sender = new API_Sender();
            response = sender.handleRequest(request);

            result = response.getBody();
        }
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage() + ' / ' + e.getLineNumber());
        }

        return result;
    }

    //Object의 필드 API 정보를 가져오는 메소드
    public static List<Schema.DescribeFieldResult> getFieldAPIDescribe(String objectName){
        List<Schema.DescribeFieldResult> result = new List<Schema.DescribeFieldResult>();
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        for (String fieldName : fieldsMap.keySet()) {
            Schema.SObjectField field = fieldsMap.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            
            result.add(fieldDescribe);
        }

        return result;
    }
    
    //@AuraEnabled(cacheable=false)
    //public static String executeCode(String code){
    //    try
    //    {
    //        HttpRequest req = new HttpRequest();
    //        req.setHeader('Authorization', 'Bearer ' + getUserSessionId());
    //        req.setHeader('Content-Type', 'application/json');
    //        
    //        req.setEndpoint(
    //            Url.getOrgDomainUrl().toExternalForm()
    //        +   '/services/data/v55.0/tooling/executeAnonymous/?anonymousBody='
    //        +   EncodingUtil.urlEncode(code, 'UTF-8')
    //        );
    //        req.setMethod('GET');
//
    //        Http h = new Http();
    //        HttpResponse res = new HttpResponse();
    //        if(!Test.isRunningTest()) res = h.send(req);
//
    //        return res.getBody();
    //    }
    //    catch (Exception e)
    //    {
    //        throw new AuraHandledException(e.getMessage() + ' / ' + e.getLineNumber());
    //    }
    //}

    /**
     * 참고 : https://salesforce.stackexchange.com/questions/223809/salesforce-lightning-how-can-i-get-session-id-of-current-user-in-salesforce-lig
     */
    public static String getUserSessionId(){
        String sessionId = '';
       // Refer to the Page
       PageReference reportPage = Page.GetUserSession;
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

    public class logTableWrapper{
        @AuraEnabled public String id                       {get;set;}
        @AuraEnabled public String url                       {get;set;}
        @AuraEnabled public String name                     {get;set;}
        @AuraEnabled public String username                 {get;set;}
        @AuraEnabled public String transactionId            {get;set;}
        @AuraEnabled public Decimal totalLogEntries          {get;set;}
        @AuraEnabled public Decimal totalERRORLogEntries     {get;set;}
        @AuraEnabled public String priority                 {get;set;}
        @AuraEnabled public Datetime startTime              {get;set;}

        public logTableWrapper(Log__c obj){
            this.Id = obj.Id;
            this.url = System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + obj.id;
            this.Name = obj.Name;
            this.Username = obj.Owner.Name;
            this.TransactionId = obj.TransactionId__c;
            this.TotalLogEntries = obj.TotalLogEntries__c;
            this.TotalERRORLogEntries = obj.TotalERRORLogEntries__c;
            this.Priority = obj.Priority__c;
            this.StartTime = obj.StartTime__c;
        }
    }
}
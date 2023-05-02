/**
 * 
 * @author 조형준
 * @since 22. 08. 30
 */
public without sharing class InterfaceRouteManagementController {
    @AuraEnabled(cacheable=true)
    public static resultInitWrapper getInitData(){
        resultInitWrapper result = new resultInitWrapper();
        try {
            List<LegacySystem__c> legacySystemList = [SELECT Id
                                                            , Name 
                                                        FROM LegacySystem__c
                                                        ORDER BY Name ASC];

            List<InterfaceRouteManager__c> interfaceRouteList = [SELECT Id
                                                                        , TargetSystem__c
                                                                        , ServiceName__c 
                                                                        , InterfaceId__c
                                                                        , ExampleParam__c 
                                                                    FROM InterfaceRouteManager__c
                                                                    ORDER BY TargetSystem__c ASC, ServiceName__c ASC];
            
            Map<String, List<interfaceOptions>> interfaceRouteMap = new Map<String, List<interfaceOptions>>();
            Map<String, String> exampleParamMap = new Map<String, String>();
            for(InterfaceRouteManager__c obj : interfaceRouteList){
                List<interfaceOptions> tempList = new List<interfaceOptions>();

                if(interfaceRouteMap.get(obj.TargetSystem__c) != null) tempList = interfaceRouteMap.get(obj.TargetSystem__c);
                tempList.add(new interfaceOptions(obj));

                interfaceRouteMap.put(obj.TargetSystem__c, tempList);
                exampleParamMap.put(obj.ServiceName__c, obj.ExampleParam__c);
            }

            result.legacySystemList = legacySystemList;
            result.interfaceRouteMap = interfaceRouteMap;
            result.exampleParamMap = exampleParamMap;

            //앱 정보 확인 테스트 추가
            UserAppInfo userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];
            AppDefinition appDefinition = [SELECT DeveloperName FROM AppDefinition WHERE DurableId = :userAppInfo.AppDefinitionId LIMIT 1];
            result.appName = appDefinition.DeveloperName;

            System.debug('result : ' + result);
        } catch (Exception e) {
            Logger.error(e.getStackTraceString());
            Logger.error(e.getMessage());
            Logger.saveLog();
        }
        return result;
    }

    @AuraEnabled(cacheable=false)
    public static string callout(String serviceName, Object params){
        String result;
        try {
            ApiCommonRequest apiRequest = new ApiCommonRequest(serviceName, params);
            System.debug('apiRequest.request ==== ' + apiRequest.request);
            ApiCommonResponse apiResponse = ApiUtilities.doRequest(apiRequest);
            result = apiResponse.toString();
        } catch (Exception e) {
            Logger.error(e.getStackTraceString());
            Logger.error(e.getMessage());
            Logger.saveLog();
        }
        return result;
    }

    public class resultInitWrapper{
        @AuraEnabled public List<LegacySystem__c> legacySystemList{get;set;}
        @AuraEnabled public Map<String, List<interfaceOptions>> interfaceRouteMap{get;set;}
        @AuraEnabled public Map<String, String> exampleParamMap{get;set;}
        @AuraEnabled public String appName{get;set;}
    }

    public class interfaceOptions{
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String value{get;set;}

        public interfaceOptions(InterfaceRouteManager__c obj){
            this.label = obj.ServiceName__c + ' / ' + obj.InterfaceId__c;
            this.value = obj.ServiceName__c;
        }
    }
}
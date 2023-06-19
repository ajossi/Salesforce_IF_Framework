/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 06-19-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
public without sharing class API_ServiceFactory {
    
    @testVisible 
    private static List<API_Routing__mdt> route = new List<API_Routing__mdt>();

    @testVisible
    private static Map<String, API_Routing__mdt> routeMap{
        get{
            Map<String, API_Routing__mdt> tempMap = new Map<String, API_Routing__mdt>();

            route = API_ManagementController.getApiRecords('');
            System.debug('route : ' + route);

            for(API_Routing__mdt mdt : route){
                if(mdt.isActive__c)tempMap.put(mdt.HttpMethod__c + mdt.URI__c, mdt);

                System.debug('mdt.HttpMethod__c : ' + mdt.HttpMethod__c);
                System.debug('mdt.URI__c : ' + mdt.URI__c);
            }
            return tempMap;
        }
        set;
    }
    
    // 수신용 서비스 생성 메소드
    public static API_Routing__mdt createService(RestRequest request) {  
        API_Routing__mdt result;

        System.debug('request.httpMethod : ' + request.httpMethod);
        System.debug('request.requestURI : ' + request.requestURI);
        if(routeMap.containsKey(request.httpMethod + request.requestURI)){
            result = routeMap.get(request.httpMethod + request.requestURI);
        } else {
            throw new API_Exceptions.API_Exception('No API route found');
        }

        return result;
    }

    // 호출용 서비스 생성 메소드
    public static API_Request createService(API_Request request) {  
        API_Request result = new API_Request();        
        // 요청 서비스 유무 확인 및 HttpRequest 값 세팅(Body 제외).
        // 요청 파라미터의 가공은 API_Service에서.
        for(API_Routing__mdt route : route) {
            if (route.ServiceClass__c == request.serviceClass) {
                result.serviceClass = route.serviceClass__c;
                result.httpMethod = route.HttpMethod__c;
                result.uri = route.URI__c;
                result.interfaceId = route.interfaceId__c;
                result.requestBody = request.requestBody;
                result.mappingDefinition = route.MappingDefinition__c;

                if(route.Timeout__c != null) result.timeout = Integer.valueOf(route.Timeout__c);

                return result;
            }
        }

        throw new API_Exceptions.API_Exception('No API route found');
    }
}
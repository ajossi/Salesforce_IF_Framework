/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 04-21-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
public without sharing class API_ServiceFactory {
    
    @testVisible 
    private static List<API_Routing__mdt> apiRoutings{
        get{ 
            if(apiRoutings == NULL){ 
                apiRoutings = [SELECT URI__c, ServiceClass__c, HttpMethod__c 
                               FROM API_Routing__mdt 
                               WHERE isActive__c = true]; 
            } 
            return apiRoutings; 
		} 
		set; 
	} 
    
    // 수신용 서비스 생성 메소드
    public static API_Service createService(RestRequest request) {          
        // Check for all active routings if the URL exsists
        for(API_Routing__mdt route : apiRoutings) {
            if (route.HttpMethod__c == request.httpMethod &&
                route.URI__c == request.requestURI) {
                return (API_Service) Type.forName(route.ServiceClass__c).newInstance();
            }
        } 

        throw new API_Exceptions.API_Exception('No API route found');
    }

    // 호출용 서비스 생성 메소드
    public static API_Request createService(API_Request request) {  
        API_Request result = new API_Request();        
        // 요청 서비스 유무 확인 및 HttpRequest 값 세팅(Body 제외).
        // 요청 파라미터의 가공은 API_Service에서.
        for(API_Routing__mdt route : apiRoutings) {
            if (route.ServiceClass__c == request.serviceClass) {
                result.serviceClass = route.serviceClass__c;
                result.httpMethod = route.HttpMethod__c;
                result.uri = route.URI__c;
                result.serviceClass = route.serviceClass__c;
                result.interfaceId = route.interfaceId__c;
                result.requestBody = request.requestBody;

                if(route.timeout__c != null) result.timeout = Integer.valueOf(route.timeout__c);

                return result;
            }
        }

        throw new API_Exceptions.API_Exception('No API route found');
    }
}
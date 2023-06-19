/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 06-18-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
@RestResource(urlMapping = '/api/*')
global without sharing class API_Receiver {
    @testVisible
    private static API_Routing__mdt route{
        get{
            if(route == null){
                route = API_ServiceFactory.createService(RestContext.request);
            }
            return route; 
        }
        set;
    }
    //request 정보를 통해 api 서비스 탐색 및 세팅
    @testVisible 
    private static API_Service apiService{ 
        get{ 
            if(apiService == NULL && String.isNotBlank(route.serviceClass__c)){ 
				apiService = (API_Service)Type.forName(route.ServiceClass__c).newInstance();
                apiService.routing = route;
            } 
            return apiService; 
		} 
		set; 
	}    
    
    @HttpGet
    global static void handleGet() {
        handleRequest();
    }

    @HttpPut
    global static void handlePut() {
        handleRequest();
    }    

    @HttpPost
    global static void handlePost() {
        handleRequest();
    }
    
    @HttpDelete
    global static void handleDelete() {
        handleRequest();
    }
    //API 요청 처리
    private static void handleRequest() {
        try {
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;

            //Service Class exists
            if(apiService != null){
                response = apiService.execute(request, response);
                RestContext.response = response;

                response.statusCode = 200;
            } else if(route != null && String.isBlank(route.serviceClass__c)){
                List<sObject> objList = new Mapper().jsonToObject(route.MappingDefinition__c, (Object)request.requestBody.toString());

                Insert objList;

                response.statusCode = 200;
                response.responseBody = Blob.valueOf(JSON.serialize(new API_Response(objList)));
            }

            //Logging
            Logger.debug('API Inbound Start').addTag(route.InterfaceId__c);
            Logger.debug('REQUEST : ' + request.requestBody.toString()); 
            Logger.debug('RESPONSE : ' + response.responseBody.toString());
        } 
        catch (Exception apiException) {
            API_Response errorResponse = new API_Response();
            errorResponse.createUnhandledExcepionResponse(apiException.getMessage());
            
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errorResponse));

            Logger.debug(RestContext.response.responseBody.toString()); 
            Logger.error('ERROR STACK : ' + apiException.getStackTraceString()); 
            Logger.error('ERROR MESSAGE : ' + apiException.getMessage()); 
        }
        finally{
            Logger.debug('API Receive END');
            Logger.saveLog();
        }
    }

    public class Mapper extends API_Mapper{}
}
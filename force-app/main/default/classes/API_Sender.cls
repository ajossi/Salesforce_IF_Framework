/**
 * @description       : 공통 Callout 클래스
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 05-31-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
public without sharing class API_Sender {
    @TestVisible
    public Boolean testCalloutExceptionFlag = false;

    public httpResponse handleRequest(API_Request request){
        httpResponse response = new httpResponse();
        try{
            if(testCalloutExceptionFlag) throw new CalloutException();
            if(String.isNotBlank(request.serviceClass)) request = (API_Request) API_ServiceFactory.createService(request);
            API_Service apiService = (API_Service) Type.forName(request.ServiceClass).newInstance();

            response = apiService.execute(request);

            Logger.debug('API Outbound Start').addTag(request.serviceClass);
            Logger.debug('REQUEST : ' + JSON.serialize(request));
            Logger.debug('RESPONSE BODY : ' + response.getBody());
            Logger.debug('RESPONSE STATUS CODE : ' + response.getStatusCode());

            if(response.getStatusCode() >= 200 && response.getStatusCode() < 300){
                Logger.debug('RESPONSE STATUS : ' + response.getStatus()); 
            } else {
                Logger.error('RESPONSE STATUS : ' + response.getStatus());  
            }
        }catch(CalloutException e){
            response.setStatusCode(500);
            response.setStatus(e.getStackTraceString());

            Logger.debug('RESPONSE BODY : ' + response.getBody());
            Logger.error('RESPONSE STATUS : ' + response.getStatus()); 
            Logger.debug('RESPONSE STATUS CODE : ' + response.getStatusCode());
        }finally{
            Logger.debug('API Sender END');
            Logger.saveLog();
        }
        
        return response;
    }
}
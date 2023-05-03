/**
 * @description       : 공통 Callout 클래스
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 04-13-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
public without sharing class API_Sender {
    public static httpResponse handleRequest(API_Request request){
        httpResponse response = new httpResponse();

        if(String.isNotBlank(request.serviceClass)) request = (API_Request) API_ServiceFactory.createService(request);
        API_Service apiService = (API_Service) Type.forName(request.ServiceClass).newInstance();

        response = apiService.execute(request);
        return response;
    }
}
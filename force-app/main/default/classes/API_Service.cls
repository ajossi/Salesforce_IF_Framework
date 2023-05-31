/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 05-31-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
public abstract without sharing class API_Service {
    //수신용
    // RestResponse execute(RestRequest request, RestResponse response);
    public virtual RestResponse execute(RestRequest request, RestResponse response){
        return new RestResponse();
    }
    //호출용
    // httpResponse execute(API_Request request);
    public virtual httpResponse execute(API_Request request){
        return new httpResponse();
    }

    //callout 메소드 API_Rqeust에 알맞게 값 세팅하여 사용
    public httpResponse callout(API_Request request){
        httpResponse calloutResponse = new httpResponse();
        
        try{
            Http calloutHttp = new Http();
            HttpRequest calloutRequest = new HttpRequest();
            
            calloutRequest.setMethod(request.httpMethod);
            calloutRequest.setTimeout(request.timeout);
            // if(!request.httpMethod.equals('GET')) calloutRequest.setBody(JSON.serializePretty(request.requestBody));
            if(!request.httpMethod.equals('GET')) calloutRequest.setBody((String)request.requestBody);
            System.debug(calloutRequest.getBody());

            if(request.headers != null && !request.headers.isEmpty()){
                for(String str : request.headers.keySet()){
                    calloutRequest.setHeader(str,request.headers.get(str));
                }
            }

            calloutRequest.setEndpoint(request.uri);
            calloutResponse = calloutHttp.send(calloutRequest);
        } catch(Exception e){
            Logger.debug('REQUEST : ' + JSON.serializePretty(request));
            Logger.error('CALLOUT ERROR MESSAGE : ' + e.getMessage());
            Logger.error('CALLOUT ERROR STACK TRACE : ' + e.getStackTraceString());

            calloutResponse.setBody(e.getMessage());
        }
        return calloutResponse;
    }
}
/**
 * 
 * @author 조형준
 * @since 2022. 8. 12
 * @description
 * POST : create/insert
 * PUT : update entity 전체
 * PATCH : update 단일 컬럼
 * DELETE : delete
 * GET : select
 */
@RestResource(urlMapping='/api/*')
global without sharing class ApiRestGateway {
    @HttpPut
    global static void doPut(){
        try{
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;

            System.debug('Http Put!!');
            
            commonRestApi(request, response);
        }catch(Exception e){
            System.debug(e.getStackTraceString());
        }
    }
    @HttpPatch
    global static void doPatch(){
        try{
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;

            System.debug('Http Patch!!');
            
            commonRestApi(request, response);
        }catch(Exception e){
            System.debug(e.getStackTraceString());
        }
    }
    @HttpPost
    global static void doPost(){
        try{
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;

            System.debug('Http Post!!');
            
            commonRestApi(request, response);
        }catch(Exception e){
            System.debug(e.getStackTraceString());
        }
    }
    @HttpDelete
    global static void doDelete(){
        try{
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;

            System.debug('Http Delete!!');
            
            commonRestApi(request, response);
        }catch(Exception e){
            System.debug(e.getStackTraceString());
        }
    }
    @HttpGet
    global static void doGet(){
        try{
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;

            System.debug('Http Get!!');
            
            commonRestApi(request, response);
        }catch(Exception e){
            System.debug(e.getStackTraceString());
        }
    }
    /**
     * 
     * @param request Inbound Request
     * @param response Inbound Response
     */    
    public static void commonRestApi(RestRequest request, RestResponse response){
        String requestBody = request.requestBody.toString();
        String responseBody = '';
        ApiCommonRequest apiRequest = null;
        ApiCommonResponse apiResponse = null;

        try{
            System.debug(request);
            System.debug(request.requestBody.toString());
            apiRequest = new ApiCommonRequest(request);
            System.debug(requestBody);
            System.debug(apiRequest);
            apiResponse = ApiUtilities.doRequest(apiRequest);
            apiResponse.responseDate = System.now();

            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(apiResponse));

        }catch(Exception e){
            System.debug(e.getStackTraceString());
            apiResponse.setResponse('404', e.getStackTraceString() + ' / ' + e.getMessage(), 'Fail');
        }finally{
            ApiUtilities.saveLog(apiRequest, apiResponse);
        }
    }
}
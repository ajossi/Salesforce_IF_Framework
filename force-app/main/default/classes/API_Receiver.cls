/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 05-30-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
@RestResource(urlMapping = '/api/*')
global without sharing class API_Receiver {
    
    // Based on the request URL, get the routing record
    // From the routing record inject the class that will be used for process the message
    @testVisible 
    private static API_Service apiService{ 
        get{ 
            if(apiService == NULL){ 
                System.debug('RestContext.request : ' + RestContext.request);
				apiService = (API_Service) API_ServiceFactory.createService(RestContext.request);
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
    
	// Process the rerquest
    private static void handleRequest() {
        try {
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;

            response = apiService.execute(request, response);
            RestContext.response = response;
            
            String className = String.valueOf(apiService);
            Logger.debug('API Inbound Start').addTag(className.subString(0, className.indexOf(':')));
            Logger.debug('REQUEST : ' + request.requestBody.toString()); 

            response.statusCode = 200;
            Logger.debug('RESPONSE : ' + response.responseBody.toString());
        } 
        catch (Exception apiException) {
            // Create the response JSON
            API_Response errorResponse = new API_Response();
            errorResponse.createUnhandledExcepionResponse(apiException.getMessage());
            
            // An error occured
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
}
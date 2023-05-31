/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 05-30-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
@IsTest
public class API_Receiver_Test {
    
    @IsTest
    public static void testHandleGet() {
        // RestRequest 및 RestResponse 객체 생성
        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        request.requestURI = '/api/dkbmc/TEST01';
        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        // API_Receiver의 handleGet 메서드 호출
        Test.startTest();
        API_Receiver.handleGet();
        Test.stopTest();
    }
    
    @IsTest
    public static void testHandlePut() {
        // RestRequest 및 RestResponse 객체 생성
        RestRequest request = new RestRequest();
        request.httpMethod = 'PUT';
        request.requestURI = '/api/dkbmc/TEST01';
        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        // API_Receiver의 handlePut 메서드 호출
        Test.startTest();
        API_Receiver.handlePut();
        Test.stopTest();
    }
    
    @IsTest
    public static void testHandlePost() {
        // RestRequest 및 RestResponse 객체 생성
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/api/dkbmc/TEST01';
        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        // API_Receiver의 handlePost 메서드 호출
        Test.startTest();
        API_Receiver.handlePost();
        Test.stopTest();
    }
    
    @IsTest
    public static void testHandleDelete() {
        // RestRequest 및 RestResponse 객체 생성
        RestRequest request = new RestRequest();
        request.httpMethod = 'DELETE';
        request.requestURI = '/api/dkbmc/TEST01';
        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;
        
        // API_Receiver의 handleDelete 메서드 호출
        Test.startTest();
        API_Receiver.handleDelete();
        Test.stopTest();
    }
}

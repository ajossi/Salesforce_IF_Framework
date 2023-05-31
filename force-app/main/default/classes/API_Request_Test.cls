/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 05-30-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
@IsTest
public class API_Request_Test {
    
    @IsTest
    public static void testConstructor() {
        // 테스트용 데이터
        String serviceClass = 'TestService';
        String requestBody = 'TestRequestBody';
        
        // API_Request 객체 생성
        API_Request request = new API_Request(serviceClass, requestBody);
        
        // 생성자에 의해 속성이 올바르게 설정되었는지 확인
        System.assertEquals(serviceClass, request.serviceClass);
        System.assertEquals(requestBody, request.requestBody);
        System.assertEquals(120000, request.timeout);
        
        Map<String, String> expectedHeaders = new Map<String, String>();
        expectedHeaders.put('Content-Type', 'application/json;charset=UTF-8');
        System.assertEquals(expectedHeaders, request.headers);
    }
    
    @IsTest
    public static void testDefaultConstructor() {
        // API_Request의 기본 생성자 테스트
        
        // API_Request 객체 생성
        API_Request request = new API_Request();
        
        // 기본 생성자에 의해 속성이 올바르게 초기화되었는지 확인
        System.assertEquals(null, request.serviceClass);
        System.assertEquals(null, request.requestBody);
        System.assertEquals(120000, request.timeout);
        
        Map<String, String> expectedHeaders = new Map<String, String>();
        expectedHeaders.put('Content-Type', 'application/json;charset=UTF-8');
        System.assertEquals(expectedHeaders, request.headers);
    }
}

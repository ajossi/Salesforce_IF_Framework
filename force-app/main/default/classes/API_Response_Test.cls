/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 05-30-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
@IsTest
public class API_Response_Test {
    
    @IsTest
    public static void testDefaultConstructor() {
        // API_Response의 기본 생성자 테스트
        
        // API_Response 객체 생성
        API_Response response = new API_Response();
        
        // 기본 생성자에 의해 속성이 올바르게 초기화되었는지 확인
        System.assertEquals(true, response.success);
        System.assertEquals('SUCCESS', response.status);
        System.assertEquals('', response.message);
        System.assertEquals(0, response.resultSize);
        System.assertEquals(0, response.errorSize);
        System.assertEquals(new List<Object>(), response.results);
        System.assertEquals(new List<Object>(), response.errors);
    }
    
    @IsTest
    public static void testResultsConstructor() {
        // 테스트용 데이터
        List<Object> results = new List<Object>{ 'TestData1', 'TestData2' };
        
        // API_Response 객체 생성
        API_Response response = new API_Response(results);
        
        // 결과 생성자에 의해 속성이 올바르게 설정되었는지 확인
        System.assertEquals(true, response.success);
        System.assertEquals('SUCCESS', response.status);
        System.assertEquals('', response.message);
        System.assertEquals(results.size(), response.resultSize);
        System.assertEquals(0, response.errorSize);
        System.assertEquals(results, response.results);
        System.assertEquals(new List<Object>(), response.errors);
    }
    
    @IsTest
    public static void testUnhandledExceptionResponse() {
        // 테스트용 데이터
        String errorMessage = 'An error occurred';
        List<Object> results = new List<Object>{ 'TestResult' };
        List<Object> errors = new List<Object>{ 'TestError1', 'TestError2' };
        
        // API_Response 객체 생성
        API_Response response = new API_Response();
        
        // createUnhandledExcepionResponse 메서드 호출
        response.createUnhandledExcepionResponse(errorMessage, results, errors);
        
        // createUnhandledExcepionResponse 메서드에 의해 속성이 올바르게 설정되었는지 확인
        System.assertEquals(false, response.success);
        System.assertEquals('ERROR', response.status);
        System.assertEquals(errorMessage, response.message);
        System.assertEquals(results.size(), response.resultSize);
        System.assertEquals(errors.size(), response.errorSize);
        System.assertEquals(results, response.results);
        System.assertEquals(errors, response.errors);
    }
}

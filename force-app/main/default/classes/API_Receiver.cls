/**
 * @description       : API 공통 수신 클래스
 * @author            : 조형준
 * @group             : 
 * @last modified on  : 04-21-2023
 * @last modified by  : hj.jo@dkbmc.com
**/

// /api/* 하위 URL로 들어오는 모든 API호출을 수신
@RestResource(urlMapping = '/api/*')
global without sharing class API_Receiver {
    //요청 값을 기준으로 서비스 검색
    @testVisible 
    private static ApiService apiService{ 
        get{
            if(apiService == NULL){ 
				apiService = (ApiService) API_ServiceFactory.createService(RestContext.request);
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
    
	// 요청 처리 영역
    private static void handleRequest() {
        try {
            RestContext.response = apiService.execute(RestContext.request, RestContext.response); 
        } 
        catch (Exception apiException) {
            // 반환할 응답 생성
            // LimitException : 시스템 리소스에 대한 사용 제한 limit 초과 시 발생.
            // NullPointerException : 필수 매개 변수를 설정하지 않았을 경우 발생.
            // QueryException : 쿼리문이 잘못되었을 경우 발생.
            // CalloutException : 외부 API 호출에 문제가 있는 경우 발생.
            // JSONException : JSON 형식이 잘못되었을 경우 발생.
            // DmlException : DML 작업에 실패한 경우 발생.
            // TypeException : 잘못된 데이터 형식으로 캐스팅 또는 참조 시 발생.
            
            API_Response errorResponse = new API_Response();
            errorResponse.createUnhandledExcpetionResponse(apiException.getMessage());
            
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
        }
    }
}
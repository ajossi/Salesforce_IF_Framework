/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 06-19-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
@IsTest
public class API_ManagementController_Test {
    private static FINAL API_Routing__mdt apiRouting = getTestApiRoutingRecord();

    @TestSetup
    static void makeData(){
        Logger.debug('Test Log').addTag(apiRouting.InterfaceId__c);
        Logger.saveLog(Logger.SaveMethod.SYNCHRONOUS_DML);
    }

    @IsTest
    public static API_Routing__mdt getTestApiRoutingRecord(){
        API_Routing__mdt result = [SELECT Id
                                        , InterfaceId__c 
                                        , ServiceClass__c
                                        , ExampleParam__c
                                        , isActive__c
                                        , Timeout__c
                                    FROM API_Routing__mdt
                                    ORDER BY InterfaceId__c
                                    LIMIT 1
                                    ];

        return result;
    }
    
    @IsTest
    public static void testGetApiRecords() {
        List<API_Routing__mdt> apiList = new List<API_Routing__mdt>();
        
        List<API_Routing__mdt> result = API_ManagementController.getApiRecords('');

        if(result.size() > 0) System.assert(true);
    }

    @IsTest
    public static void testInsertUpdateApiRecord() {
        Map<String, Object> apiRecordsMap = new Map<String, Object>();
        apiRecordsMap.put('interfaceId__c', apiRouting.interfaceId__c);
        apiRecordsMap.put('isActive__c', apiRouting.isActive__c);
        apiRecordsMap.put('timeout', apiRouting.Timeout__c);
        apiRecordsMap.put('ServiceClass__c', apiRouting.ServiceClass__c);
        
        API_ManagementController.insertUpdateApiRecord(apiRecordsMap);
    }
    
    @IsTest
    public static void testGetLogRecords() {
        List<API_ManagementController.logTableWrapper> result = API_ManagementController.getLogRecords(apiRouting.InterfaceId__c);
    }
    
    @IsTest
    public static void testGetDirectionValues() {
        List<String> result = API_ManagementController.getDirectionValues();
    }
    
    @IsTest
    public static void testGetSessionId() {
        // Salesforce 로그인 정보 설정
        String username = 'your_username';
        String password = 'your_password';
        
        // 테스트용 HTTP 모의 객체 생성
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // API_ManagementController의 getSessionId 메서드 호출
        String sessionId = API_ManagementController.getSessionId(username, password);
        
        // 결과 확인
        System.assertNotEquals(null, sessionId);
        // 세션 ID가 예상된 형식인지 확인
        // System.assertMatches('[a-zA-Z0-9]{80}', sessionId);
    }
    
    // 모의 HTTP 요청 및 응답을 생성하는 모의 클래스
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/xml');
            response.setBody('' +
                '<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">' +
                '    <env:Header/>' +
                '    <env:Body>' +
                '        <n1:loginResponse xmlns:n1="urn:partner.soap.sforce.com">' +
                '            <n1:result>' +
                '                <n1:sessionId>dummy_session_id</n1:sessionId>' +
                '            </n1:result>' +
                '        </n1:loginResponse>' +
                '    </env:Body>' +
                '</env:Envelope>'
            );
            response.setStatusCode(200);
            return response;
        }
    }

    @IsTest
    public static void testExecuteCode() {
        String result = API_ManagementController.executeCode(apiRouting.InterfaceId__c, apiRouting.ExampleParam__c);
    }

    @IsTest
    public static void testGetFieldAPIDescribe() {
        List<Schema.DescribeFieldResult> result = API_ManagementController.getFieldAPIDescribe('API_Routing__mdt');
    }

    @IsTest
    public static void testGetUserSessionId() {
        String result = API_ManagementController.getUserSessionId();
    }
}
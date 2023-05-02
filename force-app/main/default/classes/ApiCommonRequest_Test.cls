/**
 * @group test
 * @author 조형준
 * @since 2022. 09. 07
 */
@isTest
public class ApiCommonRequest_Test {
    @isTest
    static void test1(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/rest/product'; //Request URL
        req.httpMethod = 'PUT';

        String param = '{"request":{"Name" : "TEST"}}';

        req.requestBody = Blob.valueOf(param);

        RestContext.request = req;
        RestContext.response = res;

        Test.StartTest();
        ApiCommonRequest apiRequest = new ApiCommonRequest(req);
        apiRequest.interfaceId = 'test';
        apiRequest.serviceName = 'test';
        Test.StopTest();
    }

    @isTest
    static void test2(){
        Test.StartTest();
        ApiCommonRequest apiRequest = new ApiCommonRequest();
        apiRequest = new ApiCommonRequest('test', 'test');
        apiRequest = new ApiCommonRequest('test', 'test', true);
        apiRequest = new ApiCommonRequest('test', 'test', false);
        apiRequest = new ApiCommonRequest('test', true);
        apiRequest = new ApiCommonRequest('test', false);
        Test.StopTest();
    }

    @isTest
    static void test3(){
        Test.StartTest();
        ApiCommonRequest apiRequest = new ApiCommonRequest('test');
        Test.StopTest();
    }
}
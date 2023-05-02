/**
 * @group test
 * @author 조형준
 * @since 2022. 09. 07
 */
@isTest
public class ApiCommonResponse_Test {
    @isTest
    static void test1(){
        Test.StartTest();
        ApiCommonResponse apiResponse = new ApiCommonResponse();
        httpResponse res = new httpResponse();
        res.setBody(Json.serialize(new Map<String, String>{'response' => 'test'}));

        Object param = 'param';

        apiResponse.setResponse(param);
        apiResponse.setResponse('test', 'test', 'test');
        apiResponse.setResponse('test', 'test', 'test', param);
        apiResponse.setResponse(res);
        apiResponse.setResponse(res, true);
        apiResponse.totalCount = '1';
        apiResponse.returnType = 'JSON';
        apiResponse.responseDate = System.now();
        apiResponse.interfaceId = 'test';
        apiResponse.currentPage = '1';
        apiResponse.totalPage = '1';
        apiResponse.request = new ApiCommonRequest();

        Test.StopTest();
    }
}
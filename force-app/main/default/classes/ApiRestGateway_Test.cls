/**
 * 
 * @author 조형준
 * @since 2022. 09. 07
 */
@isTest
public class ApiRestGateway_Test {
    @TestSetup
    static void makeData(){
        IF_TestDataFactory factory = new IF_TestDataFactory();
        factory.createIfRoute();
    }

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

        Test.startTest();
        
        ApiRestGateway.doPut();

        Test.stopTest();

        //System.assertEquals('expected value', actual, 'Value is incorrect');
    }

    @isTest
    static void test2(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/rest/product'; //Request URL
        req.httpMethod = 'PATCH';

        String param = '{"request":{"Name" : "TEST"}}';

        req.requestBody = Blob.valueOf(param);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        
        ApiRestGateway.doPatch();

        Test.stopTest();

        //System.assertEquals('expected value', actual, 'Value is incorrect');
    }

    @isTest
    static void test3(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/rest/product'; //Request URL
        req.httpMethod = 'DELETE';

        String param = '{"request":{"Name" : "TEST"}}';

        req.requestBody = Blob.valueOf(param);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        
        ApiRestGateway.doDelete();

        Test.stopTest();

        //System.assertEquals('expected value', actual, 'Value is incorrect');
    }

    @isTest
    static void test4(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/rest/product'; //Request URL
        req.httpMethod = 'GET';

        String param = '{"request":{"Name" : "TEST"}}';

        req.requestBody = Blob.valueOf(param);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        
        ApiRestGateway.doGet();

        Test.stopTest();

        //System.assertEquals('expected value', actual, 'Value is incorrect');
    }

    @isTest
    static void test5(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/rest/product'; //Request URL
        req.httpMethod = 'POST';

        String param = '{"request":{"Name" : "TEST"}}';

        req.requestBody = Blob.valueOf(param);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        
        ApiRestGateway.doPost();

        Test.stopTest();

        //System.assertEquals('expected value', actual, 'Value is incorrect');
    }
}
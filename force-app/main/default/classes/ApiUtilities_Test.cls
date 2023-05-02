/**
 * 
 * @author 조형준
 * @since 2022. 09. 07
 * @group test
 */
@isTest
public class ApiUtilities_Test {
    @TestSetup
    static void makeData(){
        IF_TestDataFactory fac = new IF_TestDataFactory();
        fac.createIfRoute();
        //fac.createAlertManager();

        Product2 prod = new Product2(
            Name = 'test'
            ,MDMCode__c = 'test'
            ,IFExternalKey__c = 'test'
        );
        Insert prod;

        Account acc = new Account(
            Name = 'test'
            ,IFExternalKey__c = '1111111'
            ,MDMCode__c = '1111111'
            ,SalesEmployeeNumber__c = '000000'
            ,SalesOrganization__c = '100000'
            ,AccGroup__c = '1000'
        );
        Insert acc;

        Order__c order = new Order__c(
            IFExternalKey__c = 'test'
            ,Name = 'test'
            ,OrderStartDate__c = Date.today()
            ,Account__c = acc.Id
            ,Type__c = 'Domestic'
            ,OrderOwnerCode__c = '000000'
            ,RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Domestic').getRecordTypeId()
            ,OwnerId = UserInfo.getUserId()
            ,OrderOwnerUser__c = UserInfo.getUserId()
        );
        Insert order;

        OrderItem__c obj = new OrderItem__c(
            IFExternalKey__c = 'test'
            ,Product__c = prod.Id
            ,Order__c = order.Id
        );
        Insert obj;

        OrderItem__c obj2 = new OrderItem__c(
            IFExternalKey__c = 'test2'
            ,MDM_ProductCode__c = 'test2'
            ,MDM_ProductName__c = 'test2'
            ,Order__c = order.Id
        );
        Insert obj2;

        Delivery__c delivery = new Delivery__c(
            IFExternalKey__c = 'test'
            ,Name = 'test'
            ,Account__c = acc.Id
            ,DeliveryToAccount__c = acc.Id
            ,DeliveryOwnerUser__c = UserInfo.getUserId()
        );
        Insert delivery;

        DeliveryItem__c di = new DeliveryItem__c(
            IFExternalKey__c = 'test'
            ,Delivery__c = delivery.Id
            ,Product__c = prod.Id
            ,OrderItem__c = obj.Id
            ,Order__c = order.Id
        );
        Insert di;

        DeliveryItem__c di2 = new DeliveryItem__c(
            IFExternalKey__c = 'test2'
            ,Delivery__c = delivery.Id
            ,Product__c = prod.Id
            ,OrderItem__c = obj2.Id
            ,Order__c = order.Id
        );
        Insert di2;
        
        TransportDoc__c transport = new TransportDoc__c(
            IFExternalKey__c = 'test'
            ,Name = 'test'
            ,TMS_DONo__c = 'test'
            ,Account__c = acc.Id
            ,TransportOwnerUser__c = UserInfo.getUserId()
        );
        Insert transport;

        TransportItem__c ti = new TransportItem__c(
            IFExternalKey__c = 'test'
            ,TMS_DONo__c = 'test'
            ,Delivery__c = delivery.Id
            ,TransportDoc__c = transport.Id
        );
        Insert ti;
    }

    @isTest
    static void test1(){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account acc = new Account(
            Name = 'test'
            ,MDMCode__c = 'test'
            ,IFExternalKey__c = 'test'
        );
        Insert acc;

        ApiCommonRequest apiRequest = new ApiCommonRequest('mdmAccountSearch', 'test');
        ApiCommonResponse apiResponse = ApiUtilities.doRequest(apiRequest);

        Test.StopTest();
    }

    @isTest
    static void test2(){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        ApiCommonRequest apiRequest = new ApiCommonRequest('mdmAccountSearch', 'test');
        ApiCommonResponse apiResponse = ApiUtilities.doRequest(apiRequest);
        
        Test.StopTest();
    }

    @isTest
    static void test3(){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());

        ApiCommonRequest apiRequest = new ApiCommonRequest('transportDocBulkSearch', new List<String>{'test', 'test2'});
        ApiCommonResponse apiResponse = ApiUtilities.doRequest(apiRequest);

        Test.StopTest();
    }

    @isTest
    static void test4(){
        Test.StartTest();
        ApiUtilities util = new ApiUtilities();
        
        util.StringToDate('20220101');
        util.StringToTime('1101');
        util.StringToTime('110101');
        util.changeLength('111111', 5, '0');
        util.changeLength('111111', 8, '0');
        util.changeLength('111111', 6, '0');
        Test.StopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('callout:MDM/api/soap/mdm/sf-0084/test', req.getEndpoint());
            System.assertEquals('GET', req.getMethod());

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            String param = '{"response" : [{"mdmCode" : "test"'
                          + ',"mdmName" : "test"'
                          + ',"representativeName" : "test"'
                          + ',"mobile1" : "test"'
                          + ',"mobile2" : "test"'
                          + ',"zipCode" : "test"'
                          + ',"address" : "test"'
                          + ',"addressDetail" : "test"'
                          + ',"salesOrganization" : "test"'
                          + ',"salesOrganizationName" : "test"'
                          + ',"division" : "test"'
                          + ',"divisionName" : "test"'
                          + ',"branchTeam" : "test"'
                          + ',"branchTeamName" : "test"'
                          + ',"salesEmployeeNumber" : "test"'
                          + ',"salesEmployeeName" : "test"'
                          + ',"registrationNumber" : "test"'
                          + ',"billingHold" : "test"'
                          + ',"orderHold" : "test"'
                          + ',"deliveryHold" : "test"'
                          + ',"distributionChannel" : "test"'
                          + ',"country" : "test"'
                          + ',"currency_x" : "test"'
                          + ',"deliveryCondition" : "test"'
                          + ',"accAssignmentGroup" : "test"'
                          + ',"distributionLarge" : "test"'
                          + ',"distributionLargeName" : "test"'
                          + ',"distributionMiddle" : "test"'
                          + ',"distributionMiddleName" : "test"'
                          + ',"distributionSmall" : "test"'
                          + ',"distributionSmallName" : "test"'
                          + ',"lv1Hierarchy" : "test"'
                          + ',"lv1HierarchyName" : "test"'
                          + ',"lv2Hierarchy" : "test"'
                          + ',"lv2HierarchyName" : "test"'
                          + ',"lv3Hierarchy" : "test"'
                          + ',"lv3HierarchyName" : "test"'
                          + ',"ediLinkInfo" : "test"'
                          + ',"priceListType" : "test"'
                          + ',"priceListTypeName" : "test"'
                          + ',"generalPlant" : "test"'
                          + ',"refrigerationPlant" : "test"'
                          + ',"freezePlant" : "test"'
                          + ',"billingAddress" : "test"'
                          + ',"billingAddressName" : "test"'
                          + ',"paymentAddress" : "test"'
                          + ',"paymentAddressName" : "test"}]}';

            res.setBody(param);
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockHttpResponseGenerator2 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('callout:TMS/api/rest/tm/sf-0119', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            String param = '{"response" : [{"shipNo" : "test"'
                          + ',"deliNo" : "test"'
                          + ',"ifDeliNo" : "test"'
                          + ',"drvNm" : "test"'
                          + ',"drvCellNo" : "test"'
                          + ',"startTm" : ""'
                          + ',"status" : "1"'
                          + '}]}';

            res.setBody(param);
            res.setStatusCode(200);
            return res;
        }
    }
}
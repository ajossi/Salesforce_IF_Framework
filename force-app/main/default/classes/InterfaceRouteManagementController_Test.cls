@isTest
public class InterfaceRouteManagementController_Test {
    @TestSetup
    static void makeData(){
        IF_TestDataFactory fac = new IF_TestDataFactory();
        fac.createIfRoute();
    }

    @isTest
    static void test1(){
        Test.StartTest();
        InterfaceRouteManagementController.getInitData();
        InterfaceRouteManagementController.callout('accountSearch', 'test');
    }
}
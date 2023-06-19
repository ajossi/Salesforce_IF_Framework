/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 06-19-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
@IsTest
public class API_Service_Test {
    private static FINAL List<API_Routing__mdt> routeList = API_ManagementController.getApiRecords('');
    private static API_Routing__mdt route;
    private static API_Request apiRequest;

    @TestSetup
    static void makeData(){
        route = new API_Routing__mdt();
        apiRequest = new API_Request();

        for(API_Routing__mdt mdt : routeList){
            System.debug('mdt.InterfaceId__c : ' + mdt.InterfaceId__c);
            System.debug('mdt.Direction__c : ' + mdt.Direction__c);
            if(mdt.Direction__c == 'Outbound'){
                route = mdt;
                break;
            } 
        }
        apiRequest = new API_Request(route.InterfaceId__c, route.ExampleParam__c);
    }
    
    @IsTest
    public static void testHandleRequest() {
        Test.startTest();
        makeData();
        API_Sender apiSender = new API_Sender();
        HttpResponse response = apiSender.handleRequest(apiRequest);
        Test.stopTest();
    }
}

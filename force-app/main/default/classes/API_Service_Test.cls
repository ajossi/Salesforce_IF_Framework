/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 05-31-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
@IsTest
public class API_Service_Test {
    private static FINAL API_Routing__mdt apiRouting = getTestApiRoutingRecord();
    public static FINAL API_Request apiRequest = new API_Request(apiRouting.serviceClass__c, apiRouting.ExampleParam__c);

    @TestSetup
    static void makeData(){
    }

    @IsTest
    public static API_Routing__mdt getTestApiRoutingRecord(){
        API_Routing__mdt result = [SELECT Id
                                        , InterfaceId__c 
                                        , ServiceClass__c
                                        , ExampleParam__c
                                        , isActive__c
                                        , timeout__c
                                    FROM API_Routing__mdt
                                    ORDER BY InterfaceId__c
                                    LIMIT 1
                                    ];

        return result;
    }
    
    @IsTest
    public static void testHandleRequest() {
        Test.startTest();
        API_Sender apiSender = new API_Sender();
        HttpResponse response = apiSender.handleRequest(apiRequest);
        Test.stopTest();
    }
}

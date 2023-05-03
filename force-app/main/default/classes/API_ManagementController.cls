/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 04-13-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
public with sharing class API_ManagementController {
    @AuraEnabled(cacheable=false)
    public static List<API_Routing__mdt> getAPIData(){
        List<API_Routing__mdt> apiList = [SELECT Id
                                                , Label
                                                , URI__c
                                                , HttpMethod__c
                                                , InterfaceID__c
                                                , isActive__c
                                                , Description__c
                                                , ExampleParam__c
                                                , ServiceClass__c
                                                , LegacySystem__c 
                                            FROM API_Routing__mdt
                                            ];
        return apiList;
    }
}
/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 04-21-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
public without sharing class API_Request {
    @AuraEnabled public String uri{get;set;} //uri Address
    @AuraEnabled public String httpMethod{get;set;} //Rest Api Method
    @AuraEnabled public Map<String,String> headers{get;set;} //Api headers
    @AuraEnabled public String serviceClass{get;set;}
    @AuraEnabled public Integer timeout = 120000; //기본 값 2분

    //body
    @AuraEnabled public Object requestBody{get;set;} //Request Body
    @AuraEnabled public String interfaceId{get;set;} //Interface ID

    @AuraEnabled public Datetime requestDate = System.now(); //Request Date

    public API_Request() {}

    public API_Request(String serviceClass, Object requestBody) {
        this.serviceClass = serviceClass;
        this.requestBody = requestBody;
    }
}
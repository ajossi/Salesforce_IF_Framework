/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 06-19-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
@isTest
private class API_Mapper_Test{
    @isTest
    static void testJsonToObject() {
        // 준비: 테스트 데이터 생성
        String mappingDefinition = '{'
                                 + '    "Account" : {'
                                 + '        "NAME" : {"value" : "Name", "type" : "String"}'
                                 + '        , "MDMCODE" : {"value" : "AccountNumber", "type" : "String"}'
                                 + '        , "PHONE" : {"value" : "phone", "type" : "String"}'
                                 + '        , "USEYN" : {"value" : "isActive__c", "type" : "Boolean"}'
                                 + '        ,"CREATEDDATE" : {"value" : "ifDate__c", "type" : "Date"}'
                                 + '        ,"CREATEDDATETIME" : {"value" : "ifDatetime__c", "type" : "Datetime"}'
                                 + '        ,"COLOR" : {"value" : "ifMultiPicklist__c", "type" : "Picklist"}'
                                 + '        ,"TIME" : {"value" : "ifTime__c", "type" : "Time"}'
                                 + '    }'
                                 + '    ,"Contact" : {'
                                 + '        "NAME" : {"value" : "LastName", "type" : "String"}'
                                 + '    }'
                                 + '}';

        String jsonObject = '{'
                          + '    "Account" : ['
                          + '        {'
                          + '            "NAME" : "TEST"'
                          + '            ,"MDMCODE" : "TEST"'
                          + '            ,"PHONE" : "01012345678"'
                          + '            ,"USEYN" : "Y"'
                          + '            ,"CREATEDDATETIME" : "2023-06-13T11:01:24"'
                          + '            ,"CREATEDDATE" : "2023-06-13"'
                          + '            ,"COLOR" : "Red;Yellow;Blue"'
                          + '            ,"TIME" : "18:30"'
                          + '            ,"Contact" : ['
                          + '                {'
                          + '                    "NAME" : "TEST"'
                          + '                }'
                          + '            ]'
                          + '        },'
                          + '        {'
                          + '            "NAME" : "TEST2"'
                          + '            ,"MDMCODE" : "TEST2"'
                          + '            ,"PHONE" : "01012345678"'
                          + '            ,"USEYN" : "Y"'
                          + '            ,"CREATEDDATETIME" : "2023-06-13T11:01:24"'
                          + '            ,"CREATEDDATE" : "2023-06-13"'
                          + '            ,"COLOR" : "Red;Yellow;Blue"'
                          + '            ,"TIME" : "18:30"'
                          + '        }'
                          + '    ]'
                          + '}';

        // 실행
        List<sObject> result = new Mapper().jsonToObject(mappingDefinition, jsonObject);


    }

    public class Mapper extends API_Mapper{}
}

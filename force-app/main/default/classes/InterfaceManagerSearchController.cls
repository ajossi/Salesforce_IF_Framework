/**
 * @description       : 
 * @author            : gunwoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 05-17-2023
 * @last modified by  : gunwoo.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   05-17-2023   gunwoo.lee@dkbmc.com   Initial Version
**/

public with sharing class InterfaceManagerSearchController {

    @AuraEnabled
    public static Map<String, Object> searchData(String recordId) {
        
        Map<String, Object> responseMap;
        Map<String, Object> returnMap = new Map<String, Object>();

        try {

            //Mapping Type List
            Map<String, String> mmMap = new Map<String, String>();
            List<MappingManager__c> mmList = [SELECT SalesforceField__c, DataType__c FROM MappingManager__c WHERE InterfaceManager__c = :recordId];
            for (MappingManager__c mm : mmList) {
                mmMap.put(mm.SalesforceField__c, mm.DataType__c);
            }

            List<InterfaceManager__c> ifList = [SELECT Name FROM InterfaceManager__c WHERE Id = :recordId];
            String objectName = ifList[0].Name;

            if (objectName == 'Account') {
                responseMap = sendIf('IF_HR_SF_0001');
            } else if (objectName == 'Product') {
                responseMap = sendIf('IF_HR_SF_0001');
            }

            if (responseMap.get('StatusCode') == 200) {
                InterfaceManager__c ifObj = [SELECT ID, RequestDate__c, ResponseMessage__c FROM InterfaceManager__c WHERE Id = :recordId LIMIT 1];

                ifObj.RequestDate__c = System.today();
                ifObj.ResponseMessage__c = String.valueOf(responseMap.get('Log'));

                update ifObj;

                if (String.isNotEmpty(String.valueOf(responseMap.get('Response')))) {
                    
                    String responseBody = String.valueOf(responseMap.get('Response'));

                    List<Object> responseList =(List<Object>)System.JSON.deserializeUntyped(responseBody);
                    //total Number
                    //Integer totalCount = (Integer)responseObject.get('total_count');

                    Map<String, Object> fieldMap = (Map<String, Object>)responseList[0];

                    List<sobject> sobjectList = new List<sobject>();

                    //수신받은 List
                    for(Object temp : responseList){
                        Map<String, Object> tempObj = (Map<String, Object>)temp;

                        
                        sobject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
                        for (String mappingField : tempObj.keySet()) {
                            if (fieldMap.containsKey(mappingField)) {

                                switch on (mmMap.get(mappingField)) {
                                    when 'String' {
                                        sObj.put(mappingField, String.valueOf(tempObj.get(mappingField)));
                                    }

                                    when 'Integer' {
                                        sObj.put(mappingField, Integer.valueOf(tempObj.get(mappingField)));
                                    }
                                }
                            }
                        }
                        sobjectList.add(sObj);
                    }

                    insert sobjectList;
                }
                returnMap = new Map<String, Object>{
                    'STATUS' => 'S',
                    'RESULT' => 'SUCCESS'
                };
            } else {
                returnMap = new Map<String, Object>{
                    'STATUS' => 'w',
                    'MESSAGE' => 'No Response Data'
                };
            }
        } catch (Exception e) {
            returnMap = new Map<String, Object>{
                'STATUS' => 'E',
                'MESSAGE' => e.getMessage()
            };
        }

        return returnMap;
    }

    public static Map<String, Object> sendIf(String interfaceId) {
        
        // API_Request request = new API_Request(interfaceId, '');
        // httpResponse response = API_Sender.handleRequest(request);

        Map<String, Object> returnMap = new Map<String, Object>();
        try {
            String       calloutLog = '';
            HttpRequest  request    = new HttpRequest();
            HttpResponse response   = new HttpResponse();
            Http         http       = new Http();
    
            // Content-type : 전송 인코딩 방식
            request.setHeader( 'Content-Type', 'application/json');
            // X-Tenant-Id : 본인 Organization Name으로 설정필요.
            request.setHeader( 'X-Tenant-Id', 'abb');
            // Method 방식
            request.setMethod('GET');
            // 호출  url 생성
            String url = 'https://ifc-service.dkbmc.com/api/sf/ifm/' + interfaceId;
            request.setEndpoint( EncodingUtil.urlDecode(url, 'UTF-8').trim());
            // 요청 파라미터             
            request.setTimeout(120000);
    
            System.debug('request : ' +request);
            System.debug('request : ' +request.getHeader('X-Tenant-Id'));
            response    = http.send( request);
            system.debug('response : '+response);
            system.debug('response : '+response.getBody());

            returnMap.put('Response', String.valueOf( response.getBody()));
            returnMap.put('StatusCode' , response.getStatusCode());
            returnMap.put('HttpResponse', response);
            
            if( response.getStatusCode() >= 300) {
                returnMap.put( 'IF_MSG', '데이터 전송이 원할하지 않습니다. 관리자에게 문의하세요');
            } else {
                returnMap.put( 'IF_MSG' , '');
            }
             calloutLog  = '{"Request" : "'+ String.valueOf( request) + '", "Body" : ' + String.valueOf( request.getBody()) + '}';
             calloutLog += '"Response" : "'+ String.valueOf( response) + '", "Body" : ' + String.valueOf( response.getBody()) + '}';

             returnMap.put('Log', calloutLog);

        } catch (Exception e) {
            returnMap.put('ExceptionMsg', e.getMessage());
            returnMap.put('StatusCode'  , 500);
            returnMap.put('Message'     , e.getMessage());
            returnMap.put('Exception'   , e);
        }

        return returnMap;
    }

    
}
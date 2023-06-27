/**
 * @description       : 수신용 인터페이스 서비스 개발 예시 입니다.
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 06-27-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
/*

InterfaceId : TEST03

*/
public with sharing class API_TEST03_Receiver extends API_Service{
    public API_TEST03_Receiver() {}
    
    //수신, 송신 여부에 따라 해당하는 메소드 오버라이드 하여 개발.
    public override RestResponse execute(RestRequest request, RestResponse response){
        RestResponse result = response;

        try{
            List<sObject> objList = new MapperClass().jsonToObject(this.routing.MappingDefinition__c, (Object)request.requestBody.toString());
            System.debug('objList : ' + objList);
            //데이터 DML 처리
            Insert objList;

            //전달할 Response 정보
            result.responseBody = Blob.valueOf(JSON.serialize(new API_Response(objList)));
        }catch(Exception e){
            API_Response errorResponse = new API_Response();
            errorResponse.createUnhandledExcepionResponse(e.getMessage());
            System.debug(e.getStackTraceString());
            
            // An error occured
            result.statusCode = 500;
            result.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
        }

        return result;
    }
    //Boolean에 대한 타입 조건을 Y, F로 재정의
    public class MapperClass extends API_Mapper{
        public override Object typeBoolean(Object value){
            Object result = value.equals('Y') ? true : false;
            return result;
        }
    }
}
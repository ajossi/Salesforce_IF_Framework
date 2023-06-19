/**
 * @description       : 수신용 인터페이스 서비스 개발 예시 입니다.
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 06-13-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
/*
Body 예시

[
    {
        "NAME" : "TEST"
        ,"MDMCODE" : "TEST"
        ,"PHONE" : "01012345678"
    }
]

*/
public with sharing class API_TEST01_Receiver extends API_Service{
    public API_TEST01_Receiver() {}
    
    //수신, 송신 여부에 따라 해당하는 메소드 오버라이드 하여 개발.
    public override RestResponse execute(RestRequest request, RestResponse response){
        RestResponse result = response;

        try{
            //Request Body를 매핑 클래스 형태에 맞게 변환.
            List<mapperClass> mapperList = (List<mapperClass>)JSON.deserialize(request.requestBody.toString(), List<mapperClass>.class);
            //데이터를 적재할 Object List
            List<Account> objList = new List<Account>();

            //데이터 매핑 작업
            for(mapperClass ifObj : mapperList){
                objList.add(ifObj.convert());
            }

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

    //매핑 클래스
    public class mapperClass {
        public String NAME              {get;set;}
        public String MDMCODE           {get;set;}
        public String PHONE             {get;set;}
        public String USEYN             {get;set;}
        public String CREATEDDATETIME   {get;set;}
        public String CREATEDDATE       {get;set;}
        public String COLOR             {get;set;}
        public String CREATEDTIME       {get;set;}

        public Account convert(){
            Account obj = new Account();

            obj.Name = this.NAME;
            obj.AccountNumber = this.MDMCODE;
            obj.Phone = this.PHONE;
            obj.isActive__c = Boolean.valueOf(this.USEYN);
            obj.ifDatetime__c = (DateTime)JSON.deserialize(JSON.serialize(this.CREATEDDATETIME), DateTime.class);
            obj.ifDate__c = (Date)JSON.deserialize(JSON.serialize(this.CREATEDDATE), Date.class);
            obj.ifMultiPicklist__c = this.COLOR;
            obj.ifTime__c = (Time)JSON.deserialize(JSON.serialize(this.CREATEDTIME), Time.class);

            return obj;
        }
    }
}
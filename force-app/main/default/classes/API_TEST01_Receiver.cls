/**
 * @description       : 수신용 인터페이스 서비스 개발 예시 입니다.
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 05-31-2023
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
            System.debug(request.requestBody.toString());
            List<mapperClass> mapperList = (List<mapperClass>)JSON.deserialize(request.requestBody.toString(), List<mapperClass>.class);
            List<Account> objList = new List<Account>();

            for(mapperClass ifObj : mapperList){
                objList.add(ifObj.convert());
            }

            Insert objList;

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
        public String NAME      {get;set;}
        public String MDMCODE   {get;set;}
        public String PHONE     {get;set;}

        public Account convert(){
            Account obj = new Account();

            obj.Name = this.NAME;
            obj.AccountNumber = this.MDMCODE;
            obj.Phone = this.PHONE;

            return obj;
        }
    }
}
/**
 * 
 * @author 조형준
 * @since 2022. 8. 17
 * @description Api 공통 서비스 요청 클래스
 */
global without sharing class ApiCommonRequest {
  @AuraEnabled public String uri{get;set;} //uri Address
  @AuraEnabled public String method{get;set;} //Rest Api Method
  @AuraEnabled public Map<String,String> headers{get;set;} //Api headers
  @AuraEnabled public Boolean externalApi = false;
  @AuraEnabled public String ifTerm{get;set;} //year, month, day, time

   //body
   @AuraEnabled public Object request{get;set;} //Request Body
   @AuraEnabled public String interfaceId{get;set;} //Interface ID
   @AuraEnabled public String serviceName{get;set;} //Service Name(화면 약속)
   @AuraEnabled public String api{get;set;} //통신 방식
   @AuraEnabled public Boolean isSync = true;
   @AuraEnabled public String currentPage{get;set;}
   @AuraEnabled public String totalPage{get;set;}
   @AuraEnabled public String totalCount{get;set;}

   @AuraEnabled public Datetime requestDate{get;set;} //Request Date
   
   /**
     * @description 생성자
     */
   public ApiCommonRequest(){
   }
   public ApiCommonRequest(RestRequest request){
     String body = request.requestBody.toString();
     System.debug('RestRequest Body : ' + body);
         if(String.isNotBlank(body)) {
             Map<String, Object> apiRequest = (Map<String, Object>)Json.deserializeUntyped(body);
             this.request = apiRequest.get('request') != null ? apiRequest.get('request') : '';
             this.uri = request.requestURI;
             this.method = request.httpMethod;
             this.headers = request.headers;
             this.interfaceId = apiRequest.get('interfaceId') != null ? (String)apiRequest.get('interfaceId') : '';
             this.api = apiRequest.get('api') != null ? (String)apiRequest.get('api') : '';
             this.currentPage = apiRequest.get('currentPage') != null ? String.valueOf(apiRequest.get('currentPage')) : '';
             this.totalPage = apiRequest.get('totalPage') != null ? String.valueOf(apiRequest.get('totalPage')) : '';
             //this.ifTerm = apiRequest.get('ifTerm') != null ? (String)(String.valueOf(apiRequest.get('ifTerm')), String.class) : '';
             this.ifTerm = apiRequest.get('ifTerm') != null ? String.valueOf(apiRequest.get('ifTerm')) : '';
             System.debug('ifTerm : ' + this.ifTerm);
         }     
         this.requestDate = System.now();
     }
     public ApiCommonRequest(String serviceName, Object param){
         this.request = param;
         this.serviceName = serviceName;

         this.uri = '';
         this.method = '';
         this.headers = new Map<String,String>();
         this.interfaceId = '';
         this.api = '';

         this.requestDate = System.now();
     }

     public ApiCommonRequest(String serviceName, Object param, Boolean externalApi){
         this.request = param;
         this.serviceName = serviceName;
       
         this.uri = '';
         this.method = '';
         this.headers = new Map<String,String>();
         this.interfaceId = '';
         this.api = '';
         this.externalApi = externalApi;

         this.requestDate = System.now();
   }

     public ApiCommonRequest(String serviceName){
         this.serviceName = serviceName;

         this.request = '';
         this.uri = '';
         this.method = '';
         this.headers = new Map<String,String>();
         this.interfaceId = '';
         this.api = '';

         this.requestDate = System.now();
   }

     public ApiCommonRequest(String serviceName, Boolean externalApi){
         this.serviceName = serviceName;

         this.request = '';
         this.uri = '';
         this.method = '';
         this.headers = new Map<String,String>();
         this.interfaceId = '';
         this.api = '';
         this.externalApi = externalApi;

         this.requestDate = System.now();
   }
}
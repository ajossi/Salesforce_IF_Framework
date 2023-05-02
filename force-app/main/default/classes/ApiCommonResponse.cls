/**
 * 
 * @author 조형준
 * @since 2022. 8. 17
 * @description Api 공통 서비스 응답 클래스
 */
  global without sharing  class ApiCommonResponse {

    public @AuraEnabled String code{get;set;} //Api Status Code
    public @AuraEnabled String message{get;set;} //Api Status Message
    public @AuraEnabled String status{get;set;} //Api Status
    public @AuraEnabled Object response{get;set;} //Response Parameter
    public @AuraEnabled String totalCount{get;set;} //Response Parameter Size
    public @AuraEnabled String returnType{get;set;} //Response Type : JSON / XML
    public @AuraEnabled Datetime responseDate{get;set;} //Response Date
    public @AuraEnabled String interfaceId{get;set;}
    public @AuraEnabled String currentPage{get;set;}
    public @AuraEnabled String totalPage{get;set;}
    //public Boolean externalApi = false; //외부 API 구분
    
    public ApiCommonRequest request {get;set;} // 테스트를 위해서 요청전문을 되돌려준다.
    
    /**
      * @description 생성자
      */
    public ApiCommonResponse() {
        this.code = '0';
        this.message = 'SUCCESS';
        this.status = 'SUCCESS';
    }

    public void setResponse(httpResponse response){
      String body = response.getBody();
      System.debug('body : ' + body);

      if(body != null && String.isNotBlank(body)){
        Map<String, Object> apiResponse = (Map<String, Object>)Json.deserializeUntyped(body);
        System.debug('apiResponse : ' + apiResponse);

        this.response = apiResponse.get('response') != null ? apiResponse.get('response') : '';
        this.totalCount = String.isNotBlank((String)apiResponse.get('totalCount')) ? (String)apiResponse.get('totalCount') : '0';
        this.interfaceId = String.isNotBlank((String)apiResponse.get('interfaceId')) ? (String)apiResponse.get('interfaceId') : '';
        
        if(response.getStatusCode() < 200
        || response.getStatusCode() > 299){
          this.status = 'ERROR';
          // this.error = (String)apiResponse.get('error');
          this.code = String.valueOf(response.getStatusCode());
          this.message = (String)apiResponse.get('message');
        }
        
        this.responseDate = System.now();
      }
    }

    public void setResponse(httpResponse response, Boolean externalApi){
      String body = response.getBody();
      System.debug('body : ' + body);

      if(body != null && String.isNotBlank(body) && externalApi){
        Map<String, Object> apiResponse = (Map<String, Object>)Json.deserializeUntyped(body);
        System.debug('apiResponse : ' + apiResponse);

        this.response = body;
        this.totalCount = String.isNotBlank((String)apiResponse.get('totalCount')) ? (String)apiResponse.get('totalCount') : '0';
        this.interfaceId = String.isNotBlank((String)apiResponse.get('interfaceId')) ? (String)apiResponse.get('interfaceId') : '';
        this.responseDate = System.now();
      }
    }

    public void setResponse(Object response) {
        this.response = response;
        this.responseDate = System.now();
    }
    
    public void setResponse(String code, String message, String status) {
        this.code = code;
        this.message = message;
        this.status = status;
        this.responseDate = System.now();
    }

    public void setResponse(String code, String message, String status, Object response) {
        this.code = code;
        this.message = message;
        this.status = status;
        this.response = response;
        this.responseDate = System.now();
    }
}
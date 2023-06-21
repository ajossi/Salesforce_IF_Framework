/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 06-21-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
/*

InterfaceId : TEST05

송신, 조회 서비스의 경우 Request Body는 내부CRM 담당자와 협의하여 결정한다.

클래스 선언 규칙은 API_(InterfaceID)_ + 송신은 Sender / 수신은 Receiver / 조회는 Search로 한다.

*/
public with sharing class API_TEST05_Search extends API_Service{
    //수신, 송신 여부에 따라 해당하는 메소드 오버라이드 하여 개발.
    public override httpResponse execute(API_Request request){
        httpResponse result = new httpResponse();
        try{

            /* Request 세팅 */
            String accessToken = getOAuthToken();
            request.headers.put('Authorization', 'Bearer ' + accessToken);

            //Request Body를 전달
            result = callout(request);

            /* Response Body 가공 및 처리 영역 */
            List<sObject> objList = new Mapper().jsonToObject(request.mappingDefinition, (Object)result.getBody());
            Insert objList;

        }catch(Exception e){
            // An error occured
            result.setStatusCode(500);
            result.setStatus(e.getStackTraceString());
        }

        return result;
    }

    public String getOAuthToken(){
        String result;
        httpResponse response = new httpResponse();
        Map<String, Object> resMap = new Map<String, Object>();
        
        try{
            API_Request request = new API_Request();
            request.uri = 'https://login.salesforce.com/services/oauth2/token';
            request.requestBody = 'grant_type=password' + 
                                    '&client_id=' + '3MVG9n_HvETGhr3CKoyvBOQAOKIYzJvWCcvh1B9Cop12v21nET_jijmkKqD0OhEZvrJN5E5UuVkwAUDSXNbbk' + 
                                    '&client_secret=' + '776C475D43366D98C48C93D21077D8865149B4A0E5611BF35B3A84F07771F888' + 
                                    '&username=' + 'hj.jo@dkbmc.com.dev' + 
                                    '&password=' + 'dkbmc123';  
            request.httpMethod = 'POST';
            request.headers.put('Content-Type','application/x-www-form-urlencoded');

            response = callout(request);

            resMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            result = (String)resMap.get('access_token');
            
        }catch(Exception e){
            // An error occured
            response.setStatusCode(500);
            response.setStatus(e.getStackTraceString());
        }

        return result;
    }

    public class Mapper extends API_Mapper{}
}
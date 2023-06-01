/**
 * @description       : 송신용 인터페이스 서비스 개발 예시 입니다.
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 06-01-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
/*

송신, 조회 서비스의 경우 Request Body는 내부CRM 담당자와 협의하여 결정한다.

Request Body 예시

{"name":"'value'"}

클래스 선언 규칙은 API_(InterfaceID)_ + 송신은 Sender / 수신은 Receiver / 조회는 Search로 한다.

*/
public without sharing class API_TEST02_Sender extends API_Service{
    //수신, 송신 여부에 따라 해당하는 메소드 오버라이드 하여 개발.
    public override httpResponse execute(API_Request request){
        httpResponse result = new httpResponse();
        try{
            System.debug('request.requestBody : ' + request.requestBody);

            result = callout(request);

            System.debug('result.getBody() : ' + result.getBody());

        }catch(Exception e){
            // An error occured
            result.setStatusCode(500);
            result.setStatus(e.getStackTraceString());
        }

        return result;
    }
}
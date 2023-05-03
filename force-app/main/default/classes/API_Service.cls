/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 04-13-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
public interface API_Service {
    //수신용
    RestResponse execute(RestRequest request, RestResponse response);
    //호출용
    httpResponse execute(API_Request request);
}
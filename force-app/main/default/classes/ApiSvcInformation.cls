/**
 * 
 * @author 조형준
 * @since 2022. 8. 17
 */
public interface ApiSvcInformation {
    /*
     * 해당 메소드를 재정의하여 인터페이스 개발
     **/
    ApiCommonResponse doProcess(ApiCommonRequest apiRequest, ApiCommonResponse apiResponse);
}
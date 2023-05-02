/**
 * 
 * @author 조형준
 * @since 22. 8. 1
 * @description I/F Api 유틸 클래스
 * @group Interface
 */
global without sharing class ApiUtilities {
    public static InterfaceRouteManager__c routeManager;
    public static ApiCommonResponse apiResponse;

    /**
     * 
     * @param apiRequest 공통 요청 파라미터
     * @return  `ApiCommonResponse` 공통 응답 파라미터
     * @description Inbound, Outbound에서 공통으로 사용하는 Interface 호출 메소드(InterfaceRouteManager__c에서 서비스명, uri 정보 등으로 Route 정보를 검색하여 호출.)
     */    
    public static ApiCommonResponse doRequest(ApiCommonRequest apiRequest) {
        RestResponse response = RestContext.response;
        apiResponse = new ApiCommonResponse();
        
        try{
            System.debug('apiRequest.uri : ' + apiRequest.uri);
            routeManager = getRouteManager(apiRequest.uri, apiRequest.method, apiRequest.serviceName);

            apiRequest.uri = routeManager.UriAddress__c;
            apiRequest.method = routeManager.Method__c;

            if(routeManager == null) return apiResponse;
            else if(String.isNotBlank(routeManager.DispatcherClass__c)){
                ApiSvcInformation callout = (ApiSvcInformation)Type.forName(routeManager.DispatcherClass__c).newInstance();
                apiResponse = callout.doProcess(apiRequest, apiResponse);
            }
        } catch(Exception e){
            System.debug(e.getStackTraceString());
            apiResponse.setResponse('404', e.getStackTraceString() + ' / ' + e.getMessage(), 'Fail');
            saveLog(apiRequest, apiResponse);
        } finally{
            saveLog(apiRequest, apiResponse);
        }

        return apiResponse;
    }

    /**
     * 
     * @param apiRequest 공통 요청 파라미터
     * @return  `ApiCommonResponse` 공통 응답 파라미터
     * @description 공통 Outbound Method
     */    
    public static ApiCommonResponse doCallout(ApiCommonRequest apiRequest) {
        System.debug(apiRequest.uri);
        httpResponse calloutResponse = new httpResponse();
        
        try{
            Http calloutHttp = new Http();
            HttpRequest calloutRequest = new HttpRequest();

            String uriAddress = '';
            if(String.isNotBlank(routeManager.UriAddress__c)) uriAddress = routeManager.UriAddress__c;
            
            calloutRequest.setMethod(routeManager.Method__c);
            calloutRequest.setTimeout(120000);

            //GET의 경우 body x
            if(!routeManager.Method__c.equals('GET')) {
                // if(String.isNotBlank(routeManager.ContentType__c)){
                //     calloutRequest.setHeader('Content-Type',routeManager.ContentType__c);
                //     System.debug('ContentType Not null');
                //     System.debug('ContentType : ' + routeManager.ContentType__c);
                // }else{
                    calloutRequest.setHeader('Content-Type','application/json');
                    System.debug('ContentType null');
                //}

                if(apiRequest.request != null && String.isNotBlank(String.valueOf(apiRequest.request))){
                    calloutRequest.setHeader('Content-Length', String.valueOf(JSON.serializePretty(apiRequest.request).Length()));
                    calloutRequest.setBody(JSON.serializePretty(apiRequest.request));
                    System.debug('Set Body!');
                    System.debug('request : ' + JSON.serializePretty(apiRequest.request));
                }else{
                    System.debug('Do Not Set Body!');
                }

                System.debug('Not GET!');
            }else{
                System.debug('GET!');

                if(apiRequest.request != null && String.isNotBlank(String.valueOf(apiRequest.request))) uriAddress += (String)apiRequest.request;
            }

            if(apiRequest.headers != null && !apiRequest.headers.isEmpty()){
                for(String key : apiRequest.headers.keySet()){
                    System.debug('key : ' + key);
                    System.debug('value : ' + (String) apiRequest.headers.get(key));
                    calloutRequest.setHeader(key, (String) apiRequest.headers.get(key));
                }
            }

            calloutRequest.setEndpoint('callout:' + routeManager.TargetSystem__r.Name + uriAddress);

            System.debug('calloutRequest : ' + calloutRequest);

            calloutResponse = calloutHttp.send(calloutRequest);
            System.debug('calloutResponse : ' + calloutResponse);

            if(apiRequest.externalApi){
                apiResponse.setResponse(calloutResponse, apiRequest.externalApi);
            }else{
                apiResponse.setResponse(calloutResponse);
            }
        } catch(Exception e){
            System.debug('Exception : ' + e.getStackTraceString());
            System.debug('Exception Message : ' + e.getMessage());
            apiResponse.setResponse('404', e.getStackTraceString() + ' / ' + e.getMessage(), 'Fail', calloutResponse.getBody());
            saveLog(apiRequest, apiResponse);
        }
        return apiResponse;
    }

    /**
     * 
     * @param uri Interface에 해당하는 uri 정보
     * @param method Callout 방식(Post, Get 등)
     * @param serviceName 화면에서 사용하기 위해 정의한 서비스 명(ex. productSearch)
     * @return  `InterfaceRouteManager__c`
     * @description Interface 정보를 가져오기 위한 메소드, 해당하는 Interface가 없으면 에러 반환.
     */    
    public static InterfaceRouteManager__c getRouteManager(String uri, String method, String serviceName){
        InterfaceRouteManager__c routeManager;
        List<String> uriList = new List<String>();
        List<InterfaceRouteManager__c>  routeManagerList = new List<InterfaceRouteManager__c>();
        String query;
        String queryWhere = '';
        String api;
        String interfaceId;

        System.debug('uri: ' + uri);
        System.debug('method: ' + method);
        System.debug('serviceName: ' + serviceName);

        query = 'SELECT Id'
                       + '        ,TargetSystem__c'
                       + '        ,TargetSystem__r.Name'
                       + '        ,RecordType.Name'
                       + '        ,Direction__c'
                       + '        ,DispatcherClass__c'
                       + '        ,MapperClass__c'
                       + '        ,InterfaceId__c'
                       + '        ,ServiceName__c'
                       + '        ,Active__c'
                       + '        ,TargetObject__c'
                       + '        ,Method__c'
                       + '        ,UriAddress__c'
                       + '        ,ContentType__c'
                       + '    FROM InterfaceRouteManager__c'
                       + '    WHERE Active__c = true';
        
        if(String.isNotBlank(uri)){
            queryWhere = '  AND UriAddress__c = :uri LIMIT 1';
        } else if(String.isNotBlank(serviceName)){
            queryWhere = '    AND ServiceName__c = :serviceName LIMIT 1';
        }

        if(queryWhere != null){
            routeManagerList = Database.query(query + queryWhere);
        }else{
            apiResponse.setResponse('Not Found Interface Route', '해당 uri에 대한 I/F 정보가 존재하지 않습니다. 시스템 관리자에게 문의 부탁드립니다.', 'Fail');
        }

        if(routeManagerList.size() > 0) routeManager = routeManagerList[0];
        else {
            apiResponse.setResponse('Not Found Interface Route', '해당 uri에 대한 I/F 정보가 존재하지 않습니다. 시스템 관리자에게 문의 부탁드립니다.', 'Fail');
        }

        return routeManager;
    }

    /**
     * 
     * @param apiRequest 공통 요청 파라미터
     * @param apiResponse 공통 응답 파라미터
     */    
    public static void saveLog(ApiCommonRequest apiRequest, ApiCommonResponse apiResponse){
        String originalTransactionId = Logger.getTransactionId();

        Logger.info('Api Log Save');
        Logger.Debug('Api Request uri : ' + apiRequest.uri);
        Logger.Debug('Api Request method : ' + apiRequest.method);
        Logger.Debug('Api Request headers : ' + apiRequest.headers);
        Logger.Debug('Api Request Request Date : ' + apiRequest.requestDate);
        
        //파일 관련 인터페이스의 경우 로그 저장x(보안)
        if(!apiRequest.uri.equals('/api/api/sf/rm-0057')
        && !apiRequest.uri.equals('/api/rest/sa/sf-0097')
        && !apiRequest.uri.equals('/api/rest/sf/re-0138')){
            Logger.Debug('Api Request Param : ' + apiRequest.request);
            Logger.Debug('Api Response Param : ' + apiResponse.response);
        }

        //에러의 경우 Debug가 아닌 Error로 기록하도록 변경 - 22.12.07 조형준
        if(!apiResponse.message.equals('SUCCESS')){
            Logger.Error('Api Response message : ' + apiResponse.message);
        }else{
            Logger.Debug('Api Response message : ' + apiResponse.message);
        }
        Logger.Debug('Api Response status : ' + apiResponse.status);
        Logger.Debug('Api Response code : ' + apiResponse.code);
        Logger.Debug('Api Response Size : ' + apiResponse.totalCount);
        Logger.Debug('Api Response returnType : ' + apiResponse.returnType);
        Logger.Debug('Api Response response Date : ' + apiResponse.responseDate);

        Logger.saveLog();
    }

    public class ApiUtilitiesException extends Exception {}

    //yyyyMMdd
    public Date StringToDate(String str){
        Date result;
        List<String> tempList = new List<String>();

        //TODO: Salesforce limitation 4000년
        Integer yearLimit = 4000;
        Integer tempYear = Integer.valueOf(str.subString(0,4));

        if(tempYear > 1900 && String.isNotBlank(str) && str.length() == 8 && Integer.valueOf(str) != 0) {

            String year = tempYear >= yearLimit ? String.valueOf(yearLimit) : str.subString(0,4); 
            
            tempList.add(year);
            tempList.add(str.subString(4,6));
            tempList.add(str.subString(6,8));

            result = Date.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]));
        } else {
            result = null;
        }

        return result;
    }

    //ttmm, ttmmss
    public Time StringToTime(String str){
        Time result;
        List<String> tempList = new List<String>();

        if(String.isNotBlank(str) && str.length() == 4 && Integer.valueOf(str) != 0) {
            tempList.add(str.subString(0,2));
            tempList.add(str.subString(2,4));

            result = Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), 0,0);
        } else if(String.isNotBlank(str) && str.length() == 6 && Integer.valueOf(str) != 0){
            tempList.add(str.subString(0,2));
            tempList.add(str.subString(2,4));
            tempList.add(str.subString(4,6));

            result = Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]),0);
        } else{
            result = null;
        }

        return result;
    }

    //입력받은 데이터를 원하는 자리수로 가공(0을 붙이거나 제거)
    public String changeLength(String empNum, Integer length, String addStr){
        String result = '';

        if(String.isNotBlank(empNum) && String.isNotBlank(addStr)){
            if(empNum.length() > length){
                result = empNum.subString(empNum.length() - length, empNum.length());
            } else if(empNum.length() < length){
                for(Integer i = 0; i < length - empNum.length(); i++){
                    result += addStr;
                }
                result += empNum;
            } else {
                result = empNum;
            }
        }else{
            result = null;
        }
        return result;
    }

    // 문자열 안에서 String인지 Decimal인지 판별
    public Boolean isNumeric(String num){
        try{
            Decimal.valueof(num);
            return true;
        }
        catch(TypeException e){
            System.debug('TypeException ::::::::: ' + e.getMessage());
            return false;
        }
    }
}
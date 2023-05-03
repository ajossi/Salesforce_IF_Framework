/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 04-21-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
public without sharing class API_Response {
    public Boolean success;
    public String status;
    public String message;
    public Integer resultsize = 0;
    public List<Object> results = new List<Object>();
    public Integer errorsize = 0;
    public List<Object> errors = new List<Object>();
    public Datetime responseDate = System.now();

    //기본 응답 형태
    public API_Response(){
        this.success = true;
        this.status = 'SUCCESS';
        this.message = '';
    }

    //기본 응답 형태 + 레코드 정보
    public API_Response(List<Object> results){
        this.success = true;
        this.status = 'SUCCESS';
        this.message = '';
        this.results = results;
        this.resultSize = results.size();
    }

    //기본 에러 응답 형태(에러 메세지)
    public void createUnhandledExcpetionResponse(String errorMessage) {
        this.success = false;
        this.status = 'ERROR';
        this.message = errorMessage;
    }
    
    //기본 에러 응답 형태(에러 메세지) + 정상 처리 레코드 목록 + 에러 레코드 목록
    public void createUnhandledExcpetionResponse(String errorMessage, List<Object> results, List<Object> errors) {
        this.success = false;
        this.status = 'ERROR';
        this.message = errorMessage;
        this.results = results;
        this.resultSize = results.size();
        this.errors = errors;
        this.errorSize = errors.size();
    }
}
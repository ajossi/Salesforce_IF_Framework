/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 06-20-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
/*
JSON 형태의 데이터를 매핑정의 정보를 활용하여 자동으로 Convert해주는 클래스
*/
public abstract without sharing class API_Mapper {
    public static Map<String, Object> mappingDefinitionMap = new Map<String, Object>();
    public API_Mapper(){}

    /*
    mappingDefinition : 매핑 정의 정보
    jsonObject : sObject로 Convert할 Json 데이터
    */

    public List<sObject> jsonToObject(Object mappingDefinition, Object jsonObject){
        List<sObject> sObjectList = new List<sObject>();
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped((String)jsonObject);
        mappingDefinitionMap = (Map<String, Object>)JSON.deserializeUntyped((String)mappingDefinition);

        for(String key : jsonMap.keySet()){
            List<sObject> tempList = new List<sObject>();
            tempList = jsonToList(key, jsonMap.get(key));

            sObjectList.addAll(tempList);
        }

        return sObjectList;
    }

    public List<sObject> jsonToList(String sObjectName, Object jsonObject){
        List<sObject> sObjectList = new List<sObject>();
        Map<String, Object> mappingDefinition = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mappingDefinitionMap.get(sObjectName)));

        try{
            List<Object> jsonObjectList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(jsonObject));
            
            //수신받은 List
            for(Object obj : jsonObjectList){
                Map<String, Object> tempObj = (Map<String, Object>)obj;

                sobject sObj = Schema.getGlobalDescribe().get(sObjectName).newSObject();
                for (String mappingField : tempObj.keySet()) {
                    if(tempObj.get(mappingField) instanceof List<Object>){
                        List<sObject> tempList = new List<sObject>();
                        tempList = jsonToList(mappingField, tempObj.get(mappingField));

                        sObjectList.addAll(tempList);
                    }else{
                        if (mappingDefinition.containsKey(mappingField)) {
                            Map<String, Object> mappingFieldMap = (Map<String, Object>)mappingDefinition.get(mappingField);
                            sObj.put((String)mappingFieldMap.get('value'), convertFieldType((String)mappingFieldMap.get('type'), tempObj.get(mappingField)));
                        }
                    }
                }
                sobjectList.add(sObj);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug('error : ' + e.getStackTraceString());
        }
        return sObjectList;
    }

    //타입 변경에 특정한 조건이 필요할 경우 재정의하여 사용 가능.
    public Object convertFieldType(String fieldType, Object value){
        Object result;

        switch on (fieldType) {
            WHEN 'Boolean' {
                result = typeBoolean(value);                    
            }
            when 'Currency' { 
                result = typeCurrency(value); 
            }
            when 'Datetime' {
                result = typeDatetime(value);
            }
            when 'Date' {
                result = typeDate(value);                     
            }
            when 'Double' { 
                result = typeDouble(value);                   
            }
            when 'Integer' {
                result = typeInteger(value);                   
            }
            when 'Long' { 
                result = typeLong(value);
            }
            when 'Percent' {
                result = typePercent(value);
            }
            when 'Picklist' {
                result = typePicklist(value);
            }
            when 'String' {
                result = typeString(value);
            }
            when 'Time' {
                result = typeTime(value);
            }
            when else {
                throw new Import_Exceptions.Mapping_Exception('No type conversion found for ' + fieldType);
            }
        }

        return result;
    }
    //true, false
    public virtual Object typeBoolean(Object value){
        return Boolean.valueOf(value);
    }
    public virtual Object typeCurrency(Object value){
        return Decimal.valueOf(value.toString());
    }
    //2023-06-13T00:49:24
    public virtual Object typeDatetime(Object value){
        DateTime valueDateTime;
        if (value != null){
            valueDateTime = (DateTime) JSON.deserialize(JSON.serialize(value), DateTime.class);
        }
        return valueDateTime;
    }
    //2023-06-13
    public virtual Object typeDate(Object value){
        Date valueDate;
        if (value != null){
            valueDate = (Date) JSON.deserialize(JSON.serialize(value), Date.class);
        }
        return valueDate;
    }
    public virtual Object typeDouble(Object value){
        return Double.valueOf(value);
    }
    public virtual Object typeInteger(Object value){
        return Integer.valueOf(value);
    }
    public virtual Object typeLong(Object value){
        return Long.valueOf(value.toString());
    }
    public virtual Object typePercent(Object value){
        return Decimal.valueOf(value.toString());
    }
    //Option 1;Option 2;Option 3
    public virtual Object typePicklist(Object value){
        return value.toString();
    }
    public virtual Object typeString(Object value){
        return string.valueOf(value);
    }
    //18:30
    public virtual Object typeTime(Object value){
        Time valueTime;

        if (value != null){
            valueTime = (Time) JSON.deserialize(JSON.serialize(value), Time.class);
        }
        return valueTime;
    }
/*
    public static Integer getJsonDepth(String jsonString) {
        return calculateDepth((Map<String, Object>)JSON.deserializeUntyped(jsonString), 0);
    }	
    private static Integer calculateDepth(Map<String, Object> jsonMap, Integer currentDepth) {
        Integer maxDepth = currentDepth;
    
        for (Object value : jsonMap.values()) {
            if (value instanceof Map<String, Object>) {
                Integer childDepth = calculateDepth((Map<String, Object>)value, currentDepth + 1);
                maxDepth = Math.max(maxDepth, childDepth);
            } else if (value instanceof List<Object>) {
                Integer childDepth = calculateListDepth((List<Object>)value, currentDepth + 1);
                maxDepth = Math.max(maxDepth, childDepth);
            }
        }
    
        return maxDepth;
    }
    
    private static Integer calculateListDepth(List<Object> jsonList, Integer currentDepth) {
        Integer maxDepth = currentDepth;
    
        for (Object value : jsonList) {
            if (value instanceof Map<String, Object>) {
                Integer childDepth = calculateDepth((Map<String, Object>)value, currentDepth + 1);
                maxDepth = Math.max(maxDepth, childDepth);
            } else if (value instanceof List<Object>) {
                Integer childDepth = calculateListDepth((List<Object>)value, currentDepth + 1);
                maxDepth = Math.max(maxDepth, childDepth);
            }
        }
    
        return maxDepth;
    }
    */
}
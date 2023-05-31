/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 05-26-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
public without sharing class API_Mapper {
    public static List<sObject> mapping(String objectName, String mappingDefinition, String jsonObject){
        List<sObject> sObjectList = new List<sObject>();

        try{
            Map<String, Object> mappingDefinitionMap = (Map<String, Object>)JSON.deserializeUntyped(mappingDefinition);
            Map<String, Object> jsonObjectMaps = (Map<String, Object>)JSON.deserializeUntyped(jsonObject);
            System.debug('mappingDefinitionMap : ' + mappingDefinitionMap);
            System.debug('jsonObjectMaps : ' + jsonObjectMaps);
            sobject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
            
            for(Object obj : jsonObjectMaps.values()){
                System.debug(obj);
                System.debug(JSON.serialize(obj));

                List<Object> jsonObjectList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                System.debug('jsonObjectList : ' + jsonObjectList);

                // for(String str : mappingDefinitionMap.keySet()){
                //     sObj.put(String.valueOf(mappingDefinitionMap.get(str)), String.valueOf(jsonObjectList.get(str)));
                // }
                // sObjectList.add(sObj);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug('error : ' + e.getStackTraceString());
        }
        return sObjectList;
    }
}
/**
 * @description       : 
 * @author            : hj.jo@dkbmc.com
 * @group             : 
 * @last modified on  : 04-21-2023
 * @last modified by  : hj.jo@dkbmc.com
**/
public without sharing class API_Mapper {
    public static List<sObject> mapping(String sObjectName, String mappingDefinition, String jsonObject){
        Map<String, String> mappingDefinitionMap = (Map<String, String>)JSON.deserialize(mappingDefinition, Map<String, String>.class);
        Map<String, Object> jsonObjectMaps = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(jsonObject));
        System.debug(jsonObjectMaps);
        List<sObject> sObjectList = new List<sObject>();

        for(Object obj : jsonObjectMaps.values()){
            Type objType = Type.forName(sObjectName);
            SObject newRecord = (SObject)objType.newInstance();
            System.debug(obj);
            System.debug(JSON.serialize(obj));

            Map<String, Object> jsonObjectMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));

            for(String str : mappingDefinitionMap.keySet()){
                newRecord.put(mappingDefinitionMap.get(str), jsonObjectMap.get(str));
            }
            sObjectList.add(newRecord);
        }

        return sObjectList;
    }
}
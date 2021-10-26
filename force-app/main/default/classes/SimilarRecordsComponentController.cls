/**
 * @description       : controller class for Similar Records Component
 * @author            : Siddharth Patni
 * @last modified on  : 10-26-2021
 * @last modified by  : Siddharth Patni
**/
public with sharing class SimilarRecordsComponentController {
    /**
    * @author Siddharth Patni | 10-26-2021 
    * @param objectName : Object's api name
    * @return List<String> : List of field Api name or null if custom Similar Record setting no found
    **/
    @AuraEnabled(cacheable= true)
    public static List<String> getSimilarRecordsCustomSetting(String objectName) {
        try {
            List<SimilarRecordsSetup__c> record = [SELECT Fields__c FROM SimilarRecordsSetup__c WHERE name = :objectName LIMIT 1];
            if(record.size() == 1){
                return record[0].Fields__c.split(',');
            } else{
                return null;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return null;
    }
    /**
    * @description : Returns Similar Records JSON based on condition defined
    * @author Siddharth Patni | 10-26-2021 
    * @param objectApiName : Api name of object
    * @param objectId : Id of record
    * @param fields : all the fields of query , comma saperated in single string
    * @param whereClause : condition based on which similarity is checked
    * @param offset : offset (Lazy Load)
    * @return String : json string of all similar data
    **/
    @AuraEnabled
    public static String getSimilarRecords(
        String objectApiName,
        String objectId,
        String fields,
        String whereClause,
        String offset){
        try {
            whereClause = whereClause.removeEnd(' OR ');
            // adding Name field if not already has and 
            if( ( fields.split(',').indexOf('Name') == -1 ) && 
                ( objectApiName != 'Task' && 
                  objectApiName != 'Event' && 
                  objectApiName != 'Activity' )
            ){
                fields = 'Name,' + fields;
            }
            String query = 'SELECT ' + fields 
                        + ' FROM ' + objectApiName 
                        + ' WHERE (' + whereClause + ' ) AND Id != \''
                        + objectId + '\' LIMIT 10 OFFSET ' + offset ;
                        
            List<sObject> result = Database.query(query);
            return JSON.serialize(result);
        } catch (Exception e) {
            System.debug('e : ' + e);
        }
        return null;
    }
    /**
    * @description : Create custom setting for Similar Record setup
    * @author Siddharth Patni | 10-26-2021 
    * @param name 
    * @param fields 
    * @return String : successfull message or error message
    **/
    @AuraEnabled
    public static String insertSetup(String name, String fields){
        try {
            SimilarRecordsSetup__c obj = new SimilarRecordsSetup__c();
            obj.Fields__c = fields;
            obj.Name = name;
            upsert obj Name;
            return 'successfull';
        } catch (Exception e) {
            return e.getMessage();
        }
    }
    /**
    * @author Siddharth Patni | 10-26-2021 
    * @return List<WrappedData> : returns all custon Similar Records Setups
    **/
    @AuraEnabled
    public static List<WrappedData> getSimilarRecordsSetups(){
        try {
            List<WrappedData> records = new List<WrappedData>();
            Map<String,SimilarRecordsSetup__c> recordMap= SimilarRecordsSetup__c.getAll();
            for (String key: recordMap.keySet()){
                WrappedData record = new WrappedData();
                record.name = recordMap.get(key).Name;
                record.fields = recordMap.get(key).Fields__c;
                record.Id = recordMap.get(key).Id;
                records.add(record);
            }
            return records;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
    
    public class WrappedData{
        @AuraEnabled
        public String fields {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String id {get; set;}
    }
}

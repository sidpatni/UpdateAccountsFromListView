/**
 * @description       : Details of Objects Like Api Name and label of object and their fields
 * @author            : Siddharth Patni
 * @last modified on  : 10-27-2021
 * @last modified by  : Siddharth Patni
**/
public with sharing class ObjectConfigurationController {
    /**
     * @description : has two properties apiname and label
     */
    public class WrappedMeta implements Comparable{
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String apiName {get; set;}
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            WrappedMeta compareToEmp = (WrappedMeta)compareTo;
            if (label == compareToEmp.label) return 0;
            if (label > compareToEmp.label) return 1;
            return -1;        
        }   

    }

    /**
    * @description : return List of all object's API name and labels
    * @author Siddharth Patni | 10-26-2021 
    * @return List<String> 
    **/
    @AuraEnabled(cacheable = true)
    public static List<WrappedMeta> getObjectNames(){
        List<WrappedMeta> objectNames = new List<WrappedMeta>();
        Map<String, Schema.SObjectType> describe = Schema.getglobaldescribe();
        for(String objectName:describe.keyset()) {
            WrappedMeta wrappedMetaObj = new WrappedMeta();
            wrappedMetaObj.label = describe.get(objectName).getdescribe().getlabel();
            wrappedMetaObj.apiName = describe.get(objectName).getdescribe().getname();
            objectNames.add(wrappedMetaObj);
        }
        objectNames.sort();
        return objectNames;
    }

    /**
    * @description : returns list of API names and label of all field in an object
    * @author Siddharth Patni | 10-26-2021 
    * @param objName 
    * @return List<String> 
    **/
    @AuraEnabled(cacheable = true)
    public static List<WrappedMeta> getFieldNames(String objName) {

        List<WrappedMeta> fieldNameList = new List<WrappedMeta>();
        Map<String, Schema.SObjectType> describe = Schema.getglobaldescribe();

        if(describe.containskey(objName)) {
            Map<String, Schema.SObjectField> fieldmap = describe.get(objName).getdescribe().fields.getmap();

            for(String field : fieldmap.keyset()) {
                WrappedMeta wrappedMetaobj = new WrappedMeta();
                wrappedMetaobj.label = fieldmap.get(field).getdescribe().getlabel();
                wrappedMetaobj.apiName = fieldmap.get(field).getdescribe().getname();
                fieldNameList.add(wrappedMetaobj);
            }
        }
        fieldNameList.sort();
        return fieldNameList;
    }
    
    public class WrappedData{
        @AuraEnabled
        public String field {get; set;}
        @AuraEnabled
        public String expr {get; set;}
    }
}

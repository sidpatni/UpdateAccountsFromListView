/**
 * @description       : Details of Objects Like Api Name and label of object and their fields
 * @author            : Siddharth Patni
 * @last modified on  : 10-26-2021
 * @last modified by  : Siddharth Patni
**/
public with sharing class ObjectDetails {
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
    @AuraEnabled(cacheable=true)
    public static List<WrappedMeta> getObjectNamesList(){
        List<WrappedMeta> objectNames=new List<WrappedMeta>();
        map<string,schema.sobjecttype> describe = schema.getglobaldescribe();
        for(string objectname:describe.keyset()) {
            WrappedMeta wrappedMetaObj= new WrappedMeta();
            wrappedMetaObj.label=describe.get(objectname).getdescribe().getlabel();
            wrappedMetaObj.apiName=describe.get(objectname).getdescribe().getname();
                objectNames.add(wrappedMetaObj);
        }
        objectNames.sort();
        return objectNames;
    }

    /**
    * @description : returns list of API names and label of all field in an object
    * @author Siddharth Patni | 10-26-2021 
    * @param objname 
    * @return List<String> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<WrappedMeta> getFieldNames(String objname) {

        List<WrappedMeta> fieldNameList = new List<WrappedMeta>();
        map<string,schema.sobjecttype> describe = schema.getglobaldescribe();

        if(describe.containskey(objname)) {
            map<string,schema.sobjectfield> fieldmap = describe.get(objname).getdescribe().fields.getmap();

            for(string field:fieldmap.keyset()) {
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

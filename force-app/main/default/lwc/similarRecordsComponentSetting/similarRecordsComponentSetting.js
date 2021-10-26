import { LightningElement,track } from 'lwc';
import getObjectNamesList from '@salesforce/apex/ObjectDetails.getObjectNamesList';
import getFieldNames from '@salesforce/apex/ObjectDetails.getFieldNames';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertSetup from '@salesforce/apex/SimilarRecordsComponentController.insertSetup';
const ERROR_MESSAGE = 'Error while loading this component';
const SAVED_SUCCESSFULL_MESSAGE = 'Similar Records Setup Saved Successfully';

export default class SimilarRecordsComponentSetting extends LightningElement {
    @track objectList = [];                   // holds names of all objects returned by apex
    @track fieldList = [];                    // holds names of all fields returned by apex
    @track fieldsSelected = [];               // stores names of all fields to be queried 
    obj ;                                     // hold name of object selected by user in pop-up
    showModal = false;                        // controls visibility of modal
    objectsWithCustomSettings = [];           // hold name of all objects having custom Similar Record Setup

    // gets list of all objects in org and stores them in this.objectList
    connectedCallback(){
        try {
            this.loadObjects();
        } catch(exception){
            this.showToast(ERROR_MESSAGE,exception,'error');
        }
    }

    /** returns true if some fields are selected  */
    get hasFieldsSelected(){
        return (this.fieldsSelected.length === 0) ? false : true ; 
    }

    /** Loads all Object's Api names and labels*/
    loadObjects(){
        let options = [];
            getObjectNamesList()
            .then(result => {
                for (let key of result){
                    options.push({ label: key.label, value: key.apiName  });
                }
                this.objectList = options;
            })
            .catch(error => {
                this.showToast(ERROR_MESSAGE,error,'error');
            });
    }

    /** show objects in lightning-combobox */
    get objectsOptions(){
        try {
            var temp = [];
            
            this.objectList.forEach(element =>{
                if(!this.objectsWithCustomSettings.includes(element.value) ){
                    temp.push(element);
                }
            })
            return temp;
        }catch(error){
            console.error(error);
            return null;
        }
        
    }

    /** Loads Field's Api names and labels of object name passed */
    loadFields(objName){
        let fieldMap=[];
        getFieldNames({ objname: objName })
            .then(result => {
                for (var key of result) {
                    fieldMap.push({ label: key.label, value: key.apiName });
                }
                this.fieldList = fieldMap;
            })
            .catch(error => {
                this.showToast(ERROR_MESSAGE,error,'error');
            });
    }

    /** loads fields when object is selected by user */
    handleObjectSelect(event){
        try {
            this.obj = event.detail.value;
            // getting all field names from apex
            this.loadFields(this.obj);
        } catch(exception){
            this.showToast(ERROR_MESSAGE,exception,'error');
        }
    }

    /** handles field selected   */
    handleFieldSelected(event) {
        this.fieldsSelected = event.detail.value;
    }

    /** handle click on new button */
    handleNew(){
        this.resetValues();
        this.openModal();
    }    
    
    /** handles onEdit Event */
    handleEdit(event){
        this.obj = event.detail.objName;
        this.loadFields(this.obj);
        this.fieldsSelected = event.detail.fields.split(',');
        this.openModal();      
    }

    /** handle table reload */
    handleTableReload(event){
        this.objectsWithCustomSettings = event.detail.objectsWithCustomSettings;
    }
    /** shows toast message*/
    showToast(title,msg,variant){
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }
    
    /** handles click of save button , saves Custom Similar Record setup */
    createSetup(){
        try {
            insertSetup({name : this.obj, fields : this.fieldsSelected.join(',')})
            .then(result => {

                if (result === 'successfull'){
                    this.showToast(SAVED_SUCCESSFULL_MESSAGE,result,'success');
                    this.template.querySelector('c-similar-records-setups-table').loadData();
                    this.closeModal();
                    this.resetValues();
                }else{
                    this.showToast(ERROR_MESSAGE,result,'error');
                }
            });

        } catch (error) {
            console.error(error);
        }
    }
    openModal(){
        this.showModal = true ;
    }
    closeModal(){
        this.showModal = false ;
    }
    resetValues(){
        this.obj = null;
        this.fieldList = [];
        this.fieldsSelected = [];
    }
}
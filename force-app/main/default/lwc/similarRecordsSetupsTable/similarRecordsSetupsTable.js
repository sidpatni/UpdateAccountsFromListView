import { LightningElement, api } from 'lwc';
import getSimilarRecordsSetups from '@salesforce/apex/SimilarRecordsComponentController.getSimilarRecordsSetups';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';

const columns = [
    {
        label: 'Name',
        fieldName: 'name',
        type: 'url',
        typeAttributes:
        {
            label: 
            {
                fieldName: 'name' 
            },
            target: '_blank'
        },
        sortable: true
    },
    {
        label : 'Fields',
        fieldName: 'fields',
        sortable: true
    },
    {   type:'action',
        typeAttributes:{
            rowActions:[
                {
                    label:'Delete',
                    name:'delete',
                    
                },
                {
                    label:'Edit',
                    name:'edit'
                }
            ]
        }
    }

];
export default class SimilarRecordsSetupsTable extends LightningElement {
    @api recordId;
    
    columns = columns;
    records = [];
    data = [];
    error;
    objectsWithCustomSettings = [];
    connectedCallback(){
        this.loadData();
    }

    /**
    * DATATABLE SORTING
    */ 
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) { return primer(x[field]);}
            : function(x) {  return x[field]; };
        
        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
    /**
     * Load Data from apex
     */
    @api
    async loadData(){
        await getSimilarRecordsSetups()
        .then(result => {
            this.objectsWithCustomSettings = [];
            this.data = result;
            result.forEach(element => {
                this.objectsWithCustomSettings.push(element.name);
            });
        });

        var reloadEvent=new CustomEvent('reload', {
                detail:
                    {
                        objectsWithCustomSettings: this.objectsWithCustomSettings
                    }
            }); 
        
        this.dispatchEvent(reloadEvent);
    }

    /** handles action on row */
    handleRowAction(event) {

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch ( actionName ) {
            //in case of delete
            case 'delete':
                if (confirm("Are you sure, you want to delete?") == true) {
                    this.deleteSetup(row.id);
                }
                break;

            //in case of edit
            case 'edit':
                this.dispatchEvent(new CustomEvent('edit', {
                    detail:{
                        objName:row.name,
                        fields :row.fields
                    }
                }));
            break;
        }
    }

    /** handles delete */
    deleteSetup(deleteId){
        deleteRecord(deleteId)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record deleted successfully',
                    variant: 'success'
                })
            );
            this.loadData();
        })
        .catch(error => {
            console.error(error);
        });
    }
}
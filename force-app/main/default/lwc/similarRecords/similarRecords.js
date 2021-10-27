import { LightningElement, api } from 'lwc';
import getSimilarRecords from '@salesforce/apex/SimilarRecordsComponentController.getSimilarRecords';
import getRecord from '@salesforce/apex/Utility.getRecord';
import getSimilarRecordsCustomSetting from '@salesforce/apex/SimilarRecordsComponentController.getSimilarRecordsCustomSetting';

export default class SimilarLeads extends LightningElement {
    @api recordId;
    @api objectApiName;
    columns = [];
    similarRecords = [];
    record;
    fields = [];

    // returns true if this.similarRecords has some data to show
    get showTable(){
        if (this.similarRecords.length == 0){
            return false;
        }
        return true;
    }
    connectedCallback(){
        try {
            let cols = [{
                label: 'Name',
                fieldName: 'linkName',
                type: 'url',
                typeAttributes:
                {
                    label: 
                    {
                        fieldName: 'Name' 
                    },
                    target: '_blank'
                },
                sortable: true
            }];
            // if custom setting exist returns list<SimilarRecordsSetup__c>, else returns null
            getSimilarRecordsCustomSetting({objectName : this.objectApiName})
            .then(result =>{
                if(result){
                    result.forEach(field=> {
                        if(field != 'Name'){
                            cols.push({
                                label : field,
                                fieldName: field,
                                sortable: true
                            });
                        }
                    }); 
                    this.columns = cols;
                    this.fields = result;
                    // getting records fields to match similarity
                    getRecord({objectApiName:this.objectApiName, recordId : this.recordId, commaSeparatedFields : this.fields.join(',')})
                        .then(result => {
                            this.record = JSON.parse(result) ;
                            this.fields.forEach(field => {
                                if(this.record[field]){
                                    var temp = this.whereClause + field + ' = ' + '\'' + this.record[field] + '\' OR ';
                                    this.whereClause = temp ;
                                }
                            });
                            this.loadData();
                        });
                    }
            });
        } catch (error) {
            console.log(error);
        }
    }
    /**
     * sorting of data table 
     */
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.similarRecords];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.similarRecords = cloneData;
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
    // Loading data (Lazy Load)
    rowLimit = 10;
    rowOffSet = 0;
    hasMoreData = true;
    whereClause = '';

    /**
     * Description : add 10 records(Max.) at a time to this similarRecords
     */
    loadData(){
        return  getSimilarRecords({
            objectApiName : this.objectApiName,
            objectId : this.record['Id'],
            fields :this.fields.join(','),
            whereClause : this.whereClause,
            offset : this.rowOffSet })
        .then(resultJSON => {
            var result = JSON.parse(resultJSON);
            result.forEach(record=>{
                record.linkName = '/'+record.Id;
            });
            try{
                if(!this.similarRecords){
                        this.similarRecords = [...result] ;                   
                }else{
                    if(result.length < 10){
                        this.hasMoreData = false;
                    }
                    let updatedRecords = [...this.similarRecords, ...result];
                    this.similarRecords = updatedRecords;
                }
                this.similarRecords.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
            }catch(exception){
                console.log(exception);
            }
        })
        .catch(error => {
            console.log(error);
            this.similarRecords = undefined;
        });
    }
    /**
     * Description : handles onLoadMore data 
     * @param {*} event 
     */
    loadMoreData(event) {
        const { target } = event;
        target.isLoading = true;
        this.rowOffSet = this.rowOffSet + this.rowLimit;
        this.loadData()
        .then(()=> {
            target.isLoading = false;
        }); 
    }
    // title of lightning card
    get title(){
        return 'Similar ' + this.objectApiName;
    }
}


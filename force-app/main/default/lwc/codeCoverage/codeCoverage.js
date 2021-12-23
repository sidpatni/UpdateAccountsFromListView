import { LightningElement, track } from 'lwc';
import getCodeCoverage from '@salesforce/apex/CodeCoverage.getCodeCoverage';

const columns = [
    { label: 'Name', fieldName: 'className', sortable: true },
    { label: 'Covered Lines', fieldName: 'coveredLinesCount', sortable: false, cellAttributes: { alignment: 'center' } },
    { label: 'Uncovered Lines', fieldName: 'uncoveredLinesCount', sortable: false, cellAttributes: { alignment: 'center' } },
    { label: 'Total Lines', fieldName: 'totalLinesCount', sortable: false, cellAttributes: { alignment: 'center' } },
    { label: 'Code Coverage(%)', fieldName: 'codeCoverage', type: 'number', sortable: false, cellAttributes: { alignment: 'center' } }
];

export default class CodeCoverage extends LightningElement {
    data;
    columns = columns;
    showTable = false;
    code;
    isLoading = true;

    connectedCallback() {
        this.loadData();
    }
    /**
     * Loads Data through apex callout
     */
    loadData() {
        getCodeCoverage()
            .then(result => {
                console.log(result.length);
                this.data = result;
            })
            .catch(error => {
                console.log(error);
            });
    }
    /**
     * handles click of "Toggle View" button, Switch between Accordion View and Table View
     */
    toggleView() {
        if (this.showTable) {
            this.showTable = false;
        } else {
            this.showTable = true;
        }
    }
    
    // code of sorting 
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    // Used to sort the 'Class Name' column
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

}
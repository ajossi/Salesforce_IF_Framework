import { LightningElement, wire, track, api } from 'lwc';
import getApiRecords from '@salesforce/apex/API_ManagementController.getApiRecords';
import getLogRecords from '@salesforce/apex/API_ManagementController.getLogRecords';
import { showToast } from 'c/commonUtils';

//데이터 테이블 라벨, 데이터 매핑용
const columns = [
    // { label: 'Id', fieldName: 'Id', editable: false, hideDefaultActions: true}
    { label: 'Id', fieldName: 'url', type:'url', typeAttributes: {
        placeholder: '',
        object: "Log__c",
        label: {fieldName: "id"},
        filters: "",
        target: '_blank',
        valueId: { fieldName: 'id' } // binding Parent Id of current item in row to autopopulate value on load.
    }, editable: false }
    ,{ label: 'Log Number', fieldName: 'name', sortable: true, editable: false }
    ,{ label: 'Username', fieldName: 'username', sortable: true, editable: false }
    ,{ label: 'Transaction Id', fieldName: 'transactionId', editable: false }
    ,{ label: 'Total Entries', fieldName: 'totalLogEntries', sortable: true, editable: false }
    ,{ label: 'Total ERROR Entries', fieldName: 'totalERRORLogEntries', sortable: true, editable: false }
    ,{ label: 'Priority', fieldName: 'priority', sortable: true, editable: false }
    ,{ label: 'Start Time', fieldName: 'startTime', editable: false }
];

export default class API_LogManagementCmp extends LightningElement {
    //combobox
    loaded = false;
    value = '';
    
    isSpinner = false;

    //Data Table
    sortedDirection = 'desc';
    sortedBy = 'Name';
    @track data = [];
    columns = columns;
    @track apiRoutingOptions = [];

    get isDataEmpty() {
        const result = this.data.length === 0;
        console.log('result:', result);
        console.log(Array.isArray(this.data));
        return result;
    }

    connectedCallback() {
        getApiRecords({})
        .then(result=>{
            if(result){
                result.forEach((obj) => {this.apiRoutingOptions.push({
                    value: obj.InterfaceID__c,
                    label: obj.Label});
                });
            }
            console.log('apiRoutingOptions : ' + JSON.stringify(this.apiRoutingOptions));
            this.loaded = true;
        }).catch((error)=>{
            console.log('error:', error.message);
        });
    }

    handleChange(event){
        const interfaceId = event.detail.value;
        console.log('interfaceId : ' + interfaceId);
        this.isSpinner = true;

        getLogRecords({interfaceId :interfaceId})
        .then(result=>{
            this.data = result;
            console.log('data : ' + JSON.stringify(this.data));
            console.log('data.length : ' + this.data.length);

            this.isSpinner = false;
        }).catch((error)=>{
            console.error('error:', JSON.stringify(error));
        });
    }

    handleSort(event) {
        const { fieldName, sortDirection } = event.detail;
        const reverse = sortDirection !== 'asc';

        try{
            // 데이터를 fieldName에 따라 정렬합니다.
            this.data.sort((a, b) => {
                let valueA = a[fieldName];
                let valueB = b[fieldName];

                // null 값과 undefined 값 처리
                if (valueA === null || valueA === undefined) {
                    return reverse ? 1 : -1;
                } else if (valueB === null || valueB === undefined) {
                    return reverse ? -1 : 1;
                }

                if (typeof valueA === 'string') {
                    valueA = valueA.toLowerCase();
                    valueB = valueB.toLowerCase();
                }
                if (valueA < valueB) {
                    return reverse ? 1 : -1;
                } else if (valueA > valueB) {
                    return reverse ? -1 : 1;
                }
                return 0;
            });
            // 정렬된 데이터를 화면에 다시 렌더링합니다.
            this.data = [...this.data];
            this.sortedBy = fieldName;
            this.sortedDirection = sortDirection;
        }catch(err){
            console.log(err.message);
        }
    }
}
import { LightningElement, wire, track, api } from 'lwc';
import getApiRecords from '@salesforce/apex/API_ManagementController.getApiRecords';
import { showToast } from 'c/commonUtils';
import { refreshApex } from '@salesforce/apex';


//데이터 테이블 라벨, 데이터 매핑용
const columns = [
    { label: 'Id', fieldName: 'Id', editable: false, hideDefaultActions: true}
    ,{ label: 'Class Name', fieldName: 'ServiceClass__c', sortable: true, editable: false }
    ,{ label: 'Interface ID', fieldName: 'InterfaceID__c', sortable: true, editable: false }
    ,{ label: 'Description', fieldName: 'Description__c', editable: false }
    ,{ label: 'Active', fieldName: 'isActive__c', type:'boolean', sortable: true, editable: false }
    ,{ label: 'Legacy System', fieldName: 'LegacySystem__c', sortable: true, editable: false }
    ,{ label: 'Http Method', fieldName: 'HttpMethod__c', sortable: true, editable: false }
    ,{ label: 'URI', fieldName: 'URI__c', editable: false }
];

export default class API_RoutingTableCmp extends LightningElement {
    @track data = [];
    // interfaceIds = new Array();
    ids = new Array();
    columns = columns;
    isNewModalOpen = false;
    editOpen = false;
    isSpinner = false;

    //Data Table
    sortedDirection = 'asc';
    sortedBy = 'interfaceId';

    get isDataEmpty() {
        const result = this.data.length === 0;
        return result;
    }

    //Modal
    recordId = '';
    modalType = '';

    connectedCallback() {
        this.getApiRecords();
    }

    refreshView() {
        console.log('refreshView');
        location.reload();
    }

    getApiRecords() {
        try {
            this.isSpinner = true;
            getApiRecords({recordId : ''})
                .then(result => {
                    this.data = result;
                    console.log('result : ' + JSON.stringify(result));
                    console.log('data : ' + JSON.stringify(this.data));
                })
                .catch(error => {
                    console.error('Error:', JSON.stringify(error));
                })
                .finally(() => {
                    this.isSpinner = false;
                });
        } catch (error) {
            console.log('Error:' + error.message);
        }
    }
    

    handleNewBtn(){
        this.isNewModalOpen = true;
        this.editOpen = true;
        this.modalType = 'New';
        console.log(this.editOpen);
    }

    handleEditBtn(){
        try{
            this.isSpinner = true;

            if(this.ids.length == 0){
                showToast(this, 'Error', 'Edit Error', 'Please select the record you want to modify.');
            }
            else if(this.ids.length > 1){
                showToast(this, 'Error', 'Edit Error', 'Cannot modify multiple record.');
            }else{
                this.isNewModalOpen = true;
                this.editOpen = true;
                this.modalType = 'Edit';
                this.recordId = this.ids[0];
                console.log(this.editOpen);
            }
            this.isSpinner = false;
        }catch(err){
            console.error('Error:', JSON.stringify(err));
            console.log('Error:' + err.message);
        }
    }

    newModalCloseHander(){
        this.isNewModalOpen = false;
    }

    handleRowAction(event) {
        try{
            const selectedRows = event.detail.selectedRows;
            // this.interfaceIds = new Array();
            this.ids = new Array();

            // for (let i = 0; i < selectedRows.length; i++) {
            //     this.interfaceIds.push(selectedRows[i].InterfaceID__c);
            // }

            for (let i = 0; i < selectedRows.length; i++) {
                this.ids.push(selectedRows[i].Id);
            }

            console.log('ids : ' + this.ids);
        }catch(err){
            console.log(err.message);
        }
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
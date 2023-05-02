import { LightningElement, wire, track, api } from 'lwc';
import getTableData from '@salesforce/apex/BatchGroupManagementController.getTableData';
import getGroupData from '@salesforce/apex/BatchGroupManagementController.getGroupData';
import { showToast } from 'c/commonUtils';

const columns = [
    { label: 'BatchGroup', fieldName: 'batchGroupUrl', type:'url', typeAttributes: {
        placeholder: 'Select Batch Group',
        object: "BatchGroup__c",
        label: {fieldName: "groupName"},
        filters: "",
        target: '_blank',
        valueId: { fieldName: 'batchGroupId' } // binding Parent Id of current item in row to autopopulate value on load.
    }, editable: false }
    ,{ label: 'Scheduled', fieldName: 'scheduled', type:'boolean', editable: false }
    ,{ label: 'Cron Text', fieldName: 'cronText', editable: false }
    ,{ label: 'Interval', fieldName: 'interval', editable: false }
    ,{ label: 'Description', fieldName: 'description', editable: false }
    ,{ label: 'Sequence', fieldName: 'sequence', editable: false }
    ,{ label: 'BatchManager', fieldName: 'batchManagerUrl', type:'url', typeAttributes: {
        placeholder: 'Select Batch Manager',
        object: "BatchManager__c",
        label: {fieldName: "batchManagerName"},
        filters: "",
        target: '_blank',
        valueId: { fieldName: 'batchManagerId' } // binding Parent Id of current item in row to autopopulate value on load.
    }, editable: false }
    ,{ label: 'Active', fieldName: 'active', type:'boolean', editable: false }
    ,{ label: 'ScopeSize', fieldName: 'scopeSize', editable: false }
];

//const columns = ['BatchGroup', 'Scheduled', 'Cron Text', 'Interval', 'Description', 'Sequence', 'BatchManager', 'Active', 'ScopeSize'];

export default class BatchGroupManagementCmp extends LightningElement {
    //template
    loaded = false;

    //pickList
    groupOptions;
    @track groupValue;

    //table
    @track data;
    @track dataMap = new Map();
    columns = columns;
    rowOffset = 0;
    @track groupId;
    @track sequenceId;
    @track batchId;
    @track recordId;

    //popup
    @track editEvent = false;
    @track objectName;

    renderedCallback(){
        this.getTable();
    }

    connectedCallback() {
        this.initData();
    }

    initData(){
        getGroupData({})
        .then(result=>{
            this.groupOptions = result;
            this.loaded = true;
        }).catch((error)=>{
            console.log('error : ' + error);
        });
    }

    getTable(){
        getTableData({})
        .then(result=>{
            this.dataMap = result;
        }).catch((error)=>{
            console.log('error : ' + error);
        });
    }

    groupChange(event){
        try{
            this.groupValue = event.detail.value;
            this.data = this.dataMap[this.groupValue];
        }catch(e){
            console.log(e);
        }
    }
    
    getSelectedRecord(event) {
        const selectedRows = event.detail.selectedRows;
        // Display that fieldName of the selected rows

        try{
            if(selectedRows.length > 1){
                showToast(this,'error','단일 선택','하나의 레코드만 선택해주세요.');
            }else if(selectedRows.length > 0){
                this.groupId = selectedRows[0].batchGroupId;
                this.sequenceId = selectedRows[0].batchSequenceId;
                this.batchId = selectedRows[0].batchManagerId;
            }else if(selectedRows.length < 1){
                this.groupId = '';
                this.sequenceId = '';
                this.batchId = '';
            }
    
            console.log(this.groupId);
            console.log(this.sequenceId);
            console.log(this.batchId);
        }catch(e){
            console.log(e);
        }
    }

    groupEditClick(event){
        this.recordId = event.target.value;
        console.log('this.recordId : ' + this.recordId);
        this.objectName = 'group';
        this.editEvent = true;
    }
    
    sequenceEditClick(event){
        this.recordId = event.target.value;
        console.log('this.recordId : ' + this.recordId);
        this.objectName = 'sequence';
        this.editEvent = true;
    }

    batchEditClick(event){
        this.recordId = event.target.value;
        console.log('this.recordId : ' + this.recordId);
        this.objectName = 'batch';
        this.editEvent = true;
    }

    editCloseHandler(){
        this.editEvent=false;
        console.log('this.editEvent : ' + this.editEvent);
    }

    refreshView(){
        console.log('refresh');
        eval("$A.get('e.force:refreshView').fire();");
    }
}
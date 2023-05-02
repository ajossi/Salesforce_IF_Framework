import { LightningElement, wire, track, api } from 'lwc';
import getTableData from '@salesforce/apex/BatchGroupManagementController.getTableData';
import getGroupData from '@salesforce/apex/BatchGroupManagementController.getGroupData';

const columns = [
    { label: 'BatchGroup', fieldName: 'batchGroupId', type:'url', typeAttributes: {
        placeholder: 'Select Batch Group',
        object: "BatchGroup__c",
        label: {fieldName: "groupName"},
        filters: "",
        target: '_blank',
        valueId: { fieldName: 'batchGroupId' } // binding Parent Id of current item in row to autopopulate value on load.
    }, editable: true },
    { label: 'Scheduled', fieldName: 'scheduled', type:'boolean', editable: true },
    { label: 'Cron Text', fieldName: 'cronText', editable: true },
    { label: 'Interval', fieldName: 'interval', editable: true },
    { label: 'Description', fieldName: 'description', editable: true },
    { label: 'Sequence', fieldName: 'sequence', editable: true },
    { label: 'BatchManager', fieldName: 'batchManagerId', type:'lookup', editable: true },
    { label: 'Active', fieldName: 'active', type:'boolean', editable: true },
    { label: 'ScopeSize', fieldName: 'scopeSize', editable: true }
];

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
}
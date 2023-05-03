import { LightningElement, wire, track, api } from 'lwc';
import getAPIData from '@salesforce/apex/API_ManagementController.getAPIData';

//데이터 테이블 라벨, 데이터 매핑용
const columns = [
    { label: 'BatchGroup', fieldName: 'ServiceClass__c', editable: false }
    ,{ label: 'Scheduled', fieldName: 'InterfaceID__c', editable: false }
    ,{ label: 'Description', fieldName: 'Description__c', editable: false }
    ,{ label: 'Interval', fieldName: 'isActive__c', type:'boolean', editable: false }
    ,{ label: 'Sequence', fieldName: 'LegacySystem__c ', editable: false }
    ,{ label: 'BatchManager', fieldName: 'HttpMethod__c', editable: false }
    ,{ label: 'Active', fieldName: 'URI__c', editable: false }
];

export default class API_ManagementCmp extends LightningElement {
    data = [];
    columns = columns;
    isClickNewBtn = false;
    editOpen = false;

    connectedCallback() {
        getAPIData({})
        .then(result=>{
            this.data = result;
        }).catch((error)=>{
            console.log('error : ' + error);
        });
    }

    clickNewBtn(){
        this.isClickNewBtn = true;
        this.editOpen = true;
        console.log(this.editOpen);
    }

    newModalCloseHander(){
        this.isClickNewBtn = false;
    }
}
import { LightningElement, wire, track, api } from 'lwc';
import getGroupData from '@salesforce/apex/BatchGroupManagementController.getGroupData';
import getSequenceData from '@salesforce/apex/BatchGroupManagementController.getSequenceData';
import executeBatch from '@salesforce/apex/BatchGroupManagementController.executeBatch';

import { showToast } from 'c/commonUtils';

export default class BatchGroupExecuteCmp extends LightningElement {
    //template
    loaded = false;

    //pickList
    groupOptions;
    sequenceMap;
    executeCodeMap;
    @track sequenceOptions;
    @track groupValue;
    @track groupName;
    @track sequenceValue;
    @track sequenceName;
    @track executeCode;

    @track checkboxValue = true;

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
            showToast(this, 'Error', 'Error', error.message);
        });

        getSequenceData({})
        .then(result=>{
            this.sequenceMap = result.sequenceMap;
            this.executeCodeMap = result.executeCodeMap;
        }).catch((error)=>{
            console.log('error : ' + error);
            showToast(this, 'Error', 'Error', error.message);
        });
    }

    groupChange(event){
        try{
            this.groupName = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.groupValue = event.detail.value;
            this.sequenceOptions = this.sequenceMap[event.detail.value];
            console.log('groupName : ' + this.groupName);
            console.log('groupValue : ' + this.groupValue);
        }catch(e){
            console.log(e);
            showToast(this, 'Error', 'Error', e.message);
        }
    }

    sequenceChange(event){
        try{
            this.sequenceName = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.sequenceValue = event.detail.value;
            this.executeCode = this.executeCodeMap[event.target.options.find(opt => opt.value === event.detail.value).label];  
            console.log('sequenceName : ' + this.sequenceName);
            console.log('sequenceValue : ' + this.sequenceValue);
            console.log('this.executeCode : ' + this.executeCode);
        }catch(e){
            console.log(e);
            showToast(this, 'Error', 'Error', e.message);
        }
    }

    changeExecuteCode(event){
        this.executeCode = event.detail.value;
    }

    handleCheckboxChange(event){
        this.checkboxValue = event.target.checked;
        console.log('checkboxValue : ' + this.checkboxValue);
    }

    handleExecute(){
        try{
            executeBatch({code : this.executeCode})
            .then(result=>{
                showToast(this, 'Success', 'Success', 'Batch Executed!');
            }).catch((error)=>{
                console.log('error : ' + error);
                showToast(this, 'Error', 'Error', error.message);
            });
        } catch(e){
            console.log(e);
            showToast(this, 'Error', 'Error', e.message);
        }
    }
}
import { LightningElement, wire, track, api } from 'lwc';
import getScheduleData from '@salesforce/apex/BatchGroupManagementController.getScheduleData';
import scheduledBatch from '@salesforce/apex/BatchGroupManagementController.scheduledBatch';
import abortSchedule from '@salesforce/apex/BatchGroupManagementController.abortSchedule';
import { showToast } from 'c/commonUtils';

export default class BatchGroupScheduleCmp extends LightningElement {
    //template
    loaded = false;

    //pickList
    groupOptions;
    @track groupValue;
    @track groupName;

    connectedCallback() {
        this.initData();
    }

    initData(){
        getScheduleData({})
        .then(result=>{
            this.groupOptions = result;
            this.loaded = true;
        }).catch((error)=>{
            console.log('error : ' + error);
        });
    }

    groupChange(event){
        try{
            this.groupName = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.groupValue = event.detail.value;
            console.log('groupName : ' + this.groupName);
            console.log('groupValue : ' + this.groupValue);
        }catch(e){
            showToast(this, 'Error', 'Error', e.message);
            console.log(e);
        }
    }

    handleSchedule(){
        try{
            scheduledBatch({scheduleName: this.groupName})
            .then(result=>{
                showToast(this, 'Success', 'Success', 'Batch Schedule Success!');
            }).catch((error)=>{
                showToast(this, 'Error', 'Error', error.message);
            })
        }catch(e){
            showToast(this, 'Error', 'Error', e.message);
            console.log(e);
        }
    }

    handleAbort(){
        try{
            abortSchedule({scheduleName: this.groupName})
            .then(result=>{
                showToast(this, 'Success', 'Success', 'Schedule Aborted!');
            }).catch((error)=>{
                showToast(this, 'Error', 'Error', error.message);
            })
        }catch(e){
            showToast(this, 'Error', 'Error', e.message);
            console.log(e);
        }
    }
}
import { LightningElement, api, track} from 'lwc';
import executeCode from '@salesforce/apex/API_ManagementController.executeCode';
import getApiRecords from '@salesforce/apex/API_ManagementController.getApiRecords';
import { showToast } from 'c/commonUtils';

export default class API_CalloutTestCmp extends LightningElement {
    @track param = '';
    @track result = '';
    @track apiRouting = '';
    @track example = '';
    @track serviceClass = '';
    @track interfaceId = '';

    routingMap = [];
    @track routingOptions = [];
    loaded = true;
    isSpinner = false;

    connectedCallback() {
        getApiRecords({recordId : ''})
        .then(result=>{
            if(result){
                result.forEach((obj) => {
                    if(obj.Direction__c === 'Outbound'){
                        this.routingOptions.push({
                            value: obj.ServiceClass__c
                            , label: obj.InterfaceID__c});
                    }
                });

                result.forEach((obj) => {
                    this.routingMap[obj.ServiceClass__c] = obj.Id;
                });
            }
            console.log('routingOptions : ' + JSON.stringify(this.routingOptions));
            this.loaded = false;
        }).catch((error)=>{
            console.log('error:', error.message);
        });
    }

    handleRoutingChange(event){
        this.isSpinner = true;
        this.serviceClass = event.detail.value;
        this.recordId = this.routingMap[this.serviceClass];

        getApiRecords({recordId: this.recordId})
        .then(result=>{
            console.log(JSON.stringify(result));
            this.example = result[0]?.ExampleParam__c ? result[0].ExampleParam__c : null;
            console.log('example : ' + JSON.stringify(this.example));
            this.isSpinner = false;
        }).catch((error)=>{
            console.error('error:' + error.message);
            this.isSpinner = false;
        });
    }

    handleSubmit(){
        try{
            this.isSpinner = true;
            console.log('this.serviceClass : ' + this.serviceClass);
            console.log('this.param : ' + this.param);
            executeCode({serviceClass: this.serviceClass, requestBody: this.param})
            .then(result=>{
                this.result = result;
                console.log('result : ' + JSON.stringify(this.result));
                showToast(this, 'Success', 'Success Callout', 'Success Callout');
            }).catch((error)=>{
                showToast(this, 'error', 'error', JSON.stringify(error));
                console.error('error:', JSON.stringify(error));
                console.error('error:'+ error.message);
            });
            this.isSpinner = false;
        }catch(err){
            showToast(this, 'error', 'error', err.message);
            console.error('error:', JSON.stringify(err));
            console.error('error:' + err.message);
        }
    }

    handleParamChange(event){
        this.param = event.detail.value;
    }
}
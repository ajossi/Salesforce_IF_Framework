import { LightningElement, wire, track, api } from 'lwc';
import getInitData from '@salesforce/apex/InterfaceRouteManagementController.getInitData';
import callout from '@salesforce/apex/InterfaceRouteManagementController.callout';
import { showToast } from 'c/commonUtils';

export default class InterfaceRouteManagementCmp extends LightningElement {
    @track legacyValue;
    @track interfaceValue;
    @track legacyOptions = [];
    @track routeMap;
    @track exampleParamMap;
    @track params;
    @track result;
    isSubmit = false;

    loaded = false
    @wire(getInitData)
    initData({errors, data}){
        try{
            console.log('data : ' + data);
            console.log('data.legacySystemList : ' + JSON.stringify(data?.legacySystemList[0]));

            if(data?.legacySystemList){
                //this.value = data.legacySystemList[0].Id;
                data.legacySystemList.forEach((obj) => {this.legacyOptions.push({
                    value: obj.Id,
                    label: obj.Name});
                });
                this.routeMap = data?.interfaceRouteMap;
                this.exampleParamMap = data?.exampleParamMap;
                this.loaded = true;
            }

            console.log('legacyOptions : ' + JSON.stringify(this.legacyOptions));
            console.log('legacyOptions.length : ' + this.legacyOptions.length);
            console.log('routeMap : ' + JSON.stringify(this.routeMap));
            console.log('exampleParamMap : ' + JSON.stringify(this.exampleParamMap));
            console.log('value : ' + this.value);
        }catch(e){
            console.log(e);
            console.log(e.message);
        }
    }

    @track interfaceOptions = [];
    changeLegacy(event){
        try{
            this.legacyValue = event.detail.value;
            this.interfaceOptions = this.routeMap[event.detail.value];   
        }catch(e){
            console.log(e);
            console.log(e.message);
        }
    }

    changeInterface(event){
        try{
            this.interfaceValue = event.detail.value;
            this.params = this.exampleParamMap[event.detail.value];
            console.log('exampleParamMap : ' + this.exampleParamMap[event.detail.value]);
            const textarea = this.template.querySelector('lightning-textarea[data-recid=params]').value = this.exampleParamMap[event.detail.value];
        }catch(e){
            console.log(e);
            console.log(e.message);
        }
    }

    changeParams(event){
        this.params = event.detail.value;
    }

    clickSubmit(event){
        console.log('serviceName : ' + this.interfaceValue);
        console.log('params : ' + this.params);
        this.isSubmit = true;

        callout({serviceName: this.interfaceValue
                , params: this.params})
        .then((result => {
            this.result = result;
            this.isSubmit = false;
        }))
        .catch((error => {
            console.log('error : ' + error);
            this.isSubmit = false;
        }))
    }
}
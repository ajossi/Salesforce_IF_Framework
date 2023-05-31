/**
 * @description       : 
 * @author            : gunwoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 05-17-2023
 * @last modified by  : gunwoo.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   05-17-2023   gunwoo.lee@dkbmc.com   Initial Version
**/

import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/InterfaceManager__c.Name';
import { CloseActionScreenEvent } from 'lightning/actions';

import searchData from '@salesforce/apex/InterfaceManagerSearchController.searchData';

export default class SearchActionButton extends LightningElement {

    @api recordId;
    @track targetObject;
    @track InterfaceID;
    @track isShowSpinner = true;

    @wire(getRecord, { recordId: '$recordId' , fields: [NAME_FIELD] })
    getRecord({ error, data }){
		if(data){

			var result = JSON.parse(JSON.stringify(data));
			this.targetObject = result.fields.Name.value;
            
            console.log('this.targetObject :::: ', this.targetObject);

            searchData({
                 'recordId' : this.recordId
            })
            .then(result => {
                if (result.STATUS = 'S') {
                    this.isShowSpinner = false;
                } else if (result.STATUS = 'E') {
                    //error문구 표출
                } else {
                    //error문구 표출
                }
            })

		} else if(error) {

			var errors = JSON.parse(JSON.stringify(error));
			console.log('errors: ', errors);
			this.errorHandler(errors);

		}
    }

    handleClose(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    errorHandler(errors){
        this.showMyToast('error', 'error', reduceErrors(errors).join(', '), 'sticky');
    }

    showMyToast(variant, title, msg, mode){
        let dismissible = mode != undefined ? mode : 'dismissible';
        const event = new ShowToastEvent({
            "variant" : variant,
            "title" : title,
            "message" : msg,
            "mode" : dismissible
        });
        this.dispatchEvent(event);
    }
}
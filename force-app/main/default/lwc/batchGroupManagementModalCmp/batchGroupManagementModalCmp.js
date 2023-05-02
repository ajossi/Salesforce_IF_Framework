import { LightningElement, api, track, wire  } from 'lwc';
import { showToast } from 'c/commonUtils';

const object = {
    GROUP: 'group'
    , SEQUENCE: 'sequence'
    , BATCH: 'batch'
};

export default class BatchGroupManagementModalCmp extends LightningElement {
    
    //public
    @api recordId;
    @api objectName = object;

    editGroup = false;
    editSequence = false;
    editBatch = false;

    editOpen = false;

    renderedCallback(){
        this.templateCheck();
        console.log('modal this.recordId : ' + this.recordId);
    }

    connectedCallback() {
        //this.initData();
        Object.freeze(object);
    }

    templateCheck(){
        if(this.objectName == object.GROUP) this.editGroup = true;
        else if(this.objectName == object.SEQUENCE) this.editSequence = true;
        else if(this.objectName == object.BATCH) this.editBatch = true;
    }

    handleClose(event){
        this.editGroup = false;
        this.editSequence = false;
        this.editBatch = false;
        this.editOpen = false;
        const closeEvent = new CustomEvent('closed', {});

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

    //editCloseHandler(){
    //    this.editEvent=false;
    //    console.log('this.editEvent : ' + this.editEvent);
    //}

    handleSuccess(event){
        showToast(this,'Success','Success','Record Updated!');
        const refreshEvent = new CustomEvent('refresh',{});
        this.dispatchEvent(refreshEvent);
    }

    handleError(event){
        const message = event.detail.detail;
        showToast(this, 'Error', 'Error', message);
        console.log('error : ' + message);
    }

    handleLoad(){
        this.editOpen = true;
    }
}
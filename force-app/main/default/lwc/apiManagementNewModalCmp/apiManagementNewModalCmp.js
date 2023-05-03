import { LightningElement } from 'lwc';

export default class ApiManagementNewModalCmp extends LightningElement {
    clickCloseBtn(){
        const closeEvent = new CustomEvent('closed', {});

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }
}
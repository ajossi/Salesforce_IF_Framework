import {LightningElement, wire, track, api} from 'lwc';
import insertUpdateApiRecord from '@salesforce/apex/API_ManagementController.insertUpdateApiRecord';
import getApiRecords from '@salesforce/apex/API_ManagementController.getApiRecords';
import getDirectionValues from '@salesforce/apex/API_ManagementController.getDirectionValues';
import {showToast} from 'c/commonUtils';
import { refreshApex } from '@salesforce/apex';

export default class ApiManagementNewModalCmp extends LightningElement {
    @track isSpinner = false;
    @api modalType = '';
    @api recordId = '';
    loaded = false;

    //inputs
    @track interfaceid = '';
    @track uri = '';
    @track httpmethod = '';
    @track serviceclass = '';
    @track legacysystem = '';
    @track description = '';
    @track timeout;
    @track isactive = false;
    @track direction = '';
    @track exampleParam = '';
    @track mappingDefinition = '';
    @track headers = '';

    //combobox
    @track directionOptions = [];

    handleRefresh() {
        const closeEvent = new CustomEvent('closed', {});
        const refreshEvent = new CustomEvent('refresh', {});

        // Dispatches the event.
        this.dispatchEvent(refreshEvent);
        this.dispatchEvent(closeEvent);
    }

    retrieveData() {
        this.isSpinner = true;

        getDirectionValues({})
            .then(result => {
                console.log(JSON.stringify(result));
                result.forEach((obj) => {
                    this
                        .directionOptions
                        .push({value: obj, label: obj});
                });
                console.log(JSON.stringify(this.directionOptions));
                this.loaded = true;
            })
            .catch(error => {
                showToast(this, 'Error', 'get Api Record Error', error.message);
            });

        if (this.modalType == 'Edit') {
            console.log(this.modalType);

            getApiRecords({recordId: this.recordId})
                .then(result => {
                    console.log(JSON.stringify(result));

                    this.interfaceid = result[0].InterfaceID__c;
                    this.uri = result[0].URI__c;
                    this.httpmethod = result[0].HttpMethod__c;
                    this.serviceclass = result[0].ServiceClass__c;
                    this.legacysystem = result[0].LegacySystem__c;
                    this.description = result[0].Description__c;
                    this.timeout = result[0].Timeout__c;
                    this.isactive = result[0].isActive__c;
                    this.direction = result[0].Direction__c;
                    this.exampleParam = result[0].ExampleParam__c
                    this.mappingDefinition = result[0].MappingDefinition__c
                    this.headers = result[0].Headers__c
                })
                .catch(error => {
                    showToast(this, 'Error', 'get Api Record Error', error.message);
                });
        }
        this.isSpinner = false;
    }    

    connectedCallback() {
        this.retrieveData();
    }

    directionHandleChange(event) {
        this.direction = event.detail.value;
    }

    handleCencel() {
        const closeEvent = new CustomEvent('closed', {});

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

    handleInputChange(event) {}

    handleSave() {
        try {
            this.isSpinner = true;

            const inputElements = [...this.template.querySelectorAll('lightning-input')
                                    , ...this.template.querySelectorAll('lightning-combobox')
                                    , ...this.template.querySelectorAll('lightning-textarea')];
            const inputValues = {};

            inputElements.forEach((input) => {
                const field = input.dataset.field;
                const inputType = input.type;
                const value = inputType === 'checkbox' ? input.checked : input.value;
                var blank_pattern = /^\s+|\s+$/g;

                console.log('input : ' + JSON.stringify(input));
                console.log('field : ' + field);
                console.log('inputType : ' + inputType);
                console.log('value : ' + value);

                if (typeof value === 'string') {
                    if (value.replace(blank_pattern, '')) {
                        inputValues[field] = value;
                    }
                } else {
                    inputValues[field] = value;
                }
            });

            console.log(inputValues);

            insertUpdateApiRecord({inputValues: inputValues})
                .then(result => {
                    console.log('result : ' + JSON.stringify(result));
                    showToast(this, 'Success', 'Success', 'Record Update Success');

                    this.handleRefresh();
                })
                .catch(error => {
                    console.error('error:', JSON.stringify(error));
                    showToast(this, 'Error', 'Error', error.message);
                });

            this.isSpinner = false;
        } catch (err) {
            showToast(this, 'Error', 'Error', err.message);
        }
    }
}
import { LightningElement, wire, track, api } from 'lwc';
import getApiRecords from '@salesforce/apex/API_ManagementController.getApiRecords';
import { showToast } from 'c/commonUtils';

export default class API_ManagementCmp extends LightningElement {
}
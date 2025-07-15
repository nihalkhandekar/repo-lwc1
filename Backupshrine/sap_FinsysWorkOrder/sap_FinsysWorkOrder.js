import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import sap_finsys_slidderButton from '@salesforce/resourceUrl/sap_finsys_slidderButton';

export default class FinsysWorkOrder extends LightningElement {
  //active view - default to 'workOrderTransaction'
  @track activeView = 'workOrderTransaction';

  // Getter to check if 'workOrderTransaction' view should be displayed
  get showWorkOrderTransaction() {
    return this.activeView === 'workOrderTransaction';
  }

  // Getter to check if 'refunds' view should be displayed
  get showRefunds() {
    return this.activeView === 'refunds';
  }

  // Getter to check if 'returnedCheck' view should be displayed
  get showReturnedChecksProcessing() {
    return this.activeView === 'returnedCheck';
  }

  // Compute dynamic CSS class for the 'Work Order Transaction' button
  get transactionClass() {
    return `slds-m-left_x-small Transaction ${this.activeView === 'workOrderTransaction' ? 'activeTransaction-button' : ''}`;
  }

  // Compute dynamic CSS class for the 'Refunds' button
  get refundClass() {
    return `slds-m-left_x-small refund ${this.activeView === 'refunds' ? 'active-button' : ''}`;
  }

  // Compute dynamic CSS class for the 'Returned Checks Processing' button
  get returnCheckClass() {
    return `slds-m-left_x-small returnCheck ${this.activeView === 'returnedCheck' ? 'activeReturned-button' : ''}`;
  }

  // Handle navigation button click - update active view based on button's title attribute
  handleNavigation(event) {
    this.activeView = event.target.title;
  }

  // Load external CSS when the component is initialized
  connectedCallback() {
    loadStyle(this, sap_finsys_slidderButton).catch((error) => console.error('Error loading CSS file:', error));
  }
}
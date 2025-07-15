import LightningModal from 'lightning/modal';
import { loadStyle } from 'lightning/platformResourceLoader';
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';
import getActivityTransactionData from "@salesforce/apex/BatchFinsysControllerDuplicate.getActivityTransactionDataWhenOnlyIdIsAvailable";
import UpdateBatchStatus from "@salesforce/apex/BatchFinsysControllerDuplicate.UpdateBatchStatus";
import { CurrentPageReference } from 'lightning/navigation';
import { track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

export default class ViewOrEditBatchFinsys extends NavigationMixin(LightningModal) {
    @track recordId = '';
    @track mode = ''; // 'view', 'edit'
    @track isReadOnly = false;
    @track creatingOrUpdating = false;
    @track isLoading = false;
    @track hasResults = false;
    @track allFeeData = [];
    @track wiredDataResult;

    @track batchName = '';
    @track batchStatus = '';
    @track batchCreatedByName = '';
    @track batchCreatedDate = '';
    @track batchLastModifiedDate = '';
    @track totalTransactionCount = 0;
    @track totalTransactionAmount = 0;

    @track batchStatusOptions = [
        { label: 'Open', value: 'Open' },
        { label: 'Closed', value: 'Closed' },
        { label: 'Sealed', value: 'Sealed' },
        { label: 'Unseal', value: 'Unseal' }
    ];

    @track batchCodeOptions = [
        { label: 'Authentication/Apostille', value: 'Authentication/Apostille' },
        { label: 'Board of Accountancy', value: 'Board of Accountancy' },
        { label: 'Current Refunds CRD', value: 'Current Refunds CRD' },
        { label: 'Notary Public', value: 'Notary Public' },
        { label: 'Sales', value: 'Sales' },
        { label: 'Trademarks', value: 'Trademarks' }
    ];

    get headerText() {
        if (this.mode === 'view') {
            this.isReadOnly = true;
            return 'View Batch';
        }
        if (this.mode === 'edit') {
            this.isReadOnly = false;
            return 'Edit Batch';
        }
        return this.isReadOnly ? 'View Batch |  ' : 'Edit Batch    ';
    }

    get isvisible() {
        return this.mode === 'view';
    }

    @track batchRecordId;

    @wire(CurrentPageReference)
    setCurrentPageReference(pageRef) {
        if (pageRef) {
            this.mode = pageRef.state.c__mode;
            if (pageRef.state.c__recordID) {
                this.batchRecordId = pageRef.state.c__recordID;
            //    this.loadWorkOrderData();
            }
        }
        // refreshApex(this.wiredDataResult);
        console.log('pagee refe is '+ JSON.stringify(pageRef));

    }

    get batchRecordIdParam(){
        return this.batchRecordId;
    }


    @wire(getActivityTransactionData, { searchParamsJson: '$batchRecordIdParam' })
    wiredBatchData(result) {
        this.wiredDataResult = result;
        if (result.data) {
            this.processData(result.data);
        } else if (result.error) {
            console.error('Error loading Work Order data:', result.error);
            this.showToast('Error', 'Failed to load batch data', 'error');
        }
    }

    processData(data) {
        this.isLoading = true;
        if (data) {
            this.ActualData = JSON.parse(JSON.stringify(data));
            console.log('actual data is '+ JSON.stringify(this.ActualData));

            const batchData = this.ActualData.BatchData;

            if (batchData.Fees) {
                batchData.Fees = batchData.Fees.map(item => ({
                    ...item,
                    TotalFeeAmount: '$' + parseFloat(item.TotalFeeAmount).toFixed(2)
                }));
            }

            this.batchData = batchData.Fees || [];
            this.batchId = this.ActualData.BatchData.Id;
            this.batchName = this.ActualData.BatchData.BatchCode;
            this.batchStatus = this.ActualData.BatchData.BatchStatus;
            this.batchCreatedByName = this.ActualData.BatchData.CreatedBy;
            this.batchCreatedDate = this.ActualData.BatchData.CreatedDate;
            this.batchLastModifiedDate = this.ActualData.BatchData.LastModifiedDate;
            this.totalTransactionCount = this.ActualData.BatchData.TransactionCount;
            this.totalTransactionAmount = '$' + parseFloat(data.BatchData.TransactionAmount).toFixed(2);

            this.allFeeData = this.batchData;
            this.hasResults = this.allFeeData.length > 0;
        }
        this.isLoading = false;
    }




    connectedCallback() {
        loadStyle(this, stateExtradition)
            .catch(error => {
                console.error('Error loading CSS files:', error);
                this.showToast('Error', 'Failed to load styles', 'error');
            });
    }

    handleAction(event) {
        const action = event.detail.value;
        // const rowId = event.currentTarget.dataset.id;
        const individualApplicationId = event.currentTarget.dataset.value;

        if (action === 'edit_request') {
            this.editRequest(individualApplicationId);
        }
    }

    editRequest(individualApplicationId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__finsysWorkOrderModal'
            },
            state: {
                c__mode: 'edit',
                c__recordID: individualApplicationId,
                c__batchId: this.batchRecordId,
                c__source: 'viewOrEditBatchFinsys'
            }
        });
    }

    handleInputChange(event) {
        if (event.target.name === "BatchStatus") {
            this.batchStatus = event.target.value;
        }
    }

    async handleUpdateBatch() {
        try {
            const batchParams = {
                BatchId: this.batchRecordId,
                NewBatchStatus: this.batchStatus
            };

            const result = await UpdateBatchStatus({
                BatchData: JSON.stringify(batchParams)
            });

            if (result === 'Success') {
                this.showToast('Success', 'Batch updated successfully', 'success');
                // Refresh the wired data
                await refreshApex(this.wiredDataResult);
            } else {
                throw new Error(result);
            }
        } catch (error) {
            console.error('Error while updating batch:', error);
            this.showToast('Error', 'Failed to update batch: ' + error.message, 'error');
        }
    }


    showToast(title, message, variant) {
        const toast = this.template.querySelector('c-toast-message-state-modal');
        if (toast) {
            toast.showToast({
                title: title,
                message: message,
                variant: variant,
            });
        }
    }


    handleEditClick() {
        this.isReadOnly = false;
        this.mode = 'edit';
    }

    goBackModalToComponent() {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__batchFinsys'
            }
        });
    }

    goBackModal() {
        if (this.mode === 'edit') {
            this.isReadOnly = true;
            this.mode = 'view';
            //    this.loadWorkOrderData();
            refreshApex(this.wiredDataResult);
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__batchFinsys'
                }
            });
        }
    }

    handleKeyPress(event) {
        const validKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab'];
        const isNumber = /^\d$/.test(event.key);
        if (!isNumber && !validKeys.includes(event.key)) {
            event.preventDefault();
        }
    }

    handlePrintBatch() {
        const pdfGenerator = this.template.querySelector('c-pdf-genrator');
        if (pdfGenerator) {
            pdfGenerator.generateBatchPDF();
        }
    }
}
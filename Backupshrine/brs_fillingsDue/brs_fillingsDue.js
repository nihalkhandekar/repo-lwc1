import { LightningElement, track,api,wire } from 'lwc';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
    FlowNavigationBackEvent
} from 'lightning/flowSupport';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/commonPubSub';
import { CurrentPageReference } from 'lightning/navigation';
import { ComponentErrorLoging } from "c/formUtility";
import getFilingDueDetails from '@salesforce/apex/brs_filingDueController.getFilingDueDetails';
import getFilingStatus from '@salesforce/apex/brs_filingDueController.getFilingStatus';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Filings_Due from '@salesforce/label/c.Filings_Due';
import filings_due_info from '@salesforce/label/c.filings_due_info';
import loading_brs from '@salesforce/label/c.loading_brs';
import Next from '@salesforce/label/c.Next';
import Back from '@salesforce/label/c.Back';

export default class brs_fillingsDue extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @track todoIcon = assetFolder + "/icons/alert-circle-orange.svg";
    @track pastdueIcon = assetFolder + "/icons/alert-circle-outline@3x.png";
    @track upcomingIcon = assetFolder + "/icons/upcomingCardIcon.png";
    @track chevronRightGrey = assetFolder + "/icons/chevronRightGrey.svg";
    @track fileIcon = assetFolder + "/icons/business-details.svg";
    @track closeIcon = assetFolder + "/icons/close-circle.svg";
    @track buildingGroup = assetFolder + "/icons/buildingGroup.svg";
    @track notodo = assetFolder + "/icons/NoData_todo.png";
    @track noupcoming = assetFolder + "/icons/NoData_upcoming.png";
    @track noActionIcon2 = assetFolder + "/icons/no-action-img2.svg";
    @track yellowcheckmark = assetFolder + "/icons/yellowcheckmark.png";
    @track label;
    @track details = [];
    @track selectedItem;
    @track oldestDetailNo;
    @track queueDetailNo;
    @track upcomingDetailNo;
    @api reportType;
    @api filingId;
    @api fillingLength;
    @api hideHeaders = false;
    @api filingYear;
    @api hideDescription = false;
	@api compName = 'c/brs_fillingsDue';
    @api showNoChangeErrorMessage=false;
    @api errorMessage;
    @api filingStatus;
    @api isTempApis= false;
    @api isReviewScreen = false;
    @track hideBack = false;
    @api availableActions = [];
    @api
    get accountId(){
        return this._accountId;
    }
    set accountId(value){
        this._accountId = value;
    }

    label = {
        Filings_Due,
        filings_due_info,
        loading_brs,
        Next,
        Back
      };

    connectedCallback(){
        if (this.availableActions.find(action => action === 'BACK')) {
            this.hideBack = false;  
        }
        else
        {
            this.hideBack = true;
        }
        this.isLoading = true;
        this.isTempApis=true;
        getFilingDueDetails({
            accountId: this.accountId,
            reportType: this.reportType
        })
        .then((result) => {
            this.isLoading = false;
            this.fillingLength = result.length;
            this.oldestDetailNo = result.filter(item => item.isToDo && item.isPastDue).length;
            this.queueDetailNo = result.filter(item => !item.isToDo && !item.isUpcoming && item.isPastDue).length;
            this.upcomingDetailNo = result.filter(item => item.isUpcoming).length;
            let selectedItemArr = result.filter(item => item.isToDo);
            if(selectedItemArr.length > 0) {
                this.filingId = selectedItemArr[0].Id ;
				this.filingYear = selectedItemArr[0].Name;
                this.dispatchFIlingId();
            }
            this.details = result.map(item => {
                if(item.dueDate) {
                    item.dueDate = this.changeDateFormate(item.dueDate);
                }
                return item;
            });
        })
        .catch((error) => {
            this.isLoading = false;
            ComponentErrorLoging(
                this.compName,
                "getFilingDueDetails",
                "",
                "",
                "Medium",
                error.message
              );
        });
    }
    gotoNextScreen(){
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }
    handleBack() {
   
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
    }
    validate() {
    if(!this.filingId)
    {
        this.showNoChangeErrorMessage=true;
        this.errorMessage="There is no Filing to Approve";
    }
    else if(this.filingId)
    {

            getFilingStatus({
                filingId: this.filingId
            })
            .then((result) => {
                console.log('result@@',result);
                if(result == 'Approved')
                {
                   //this.showNoChangeErrorMessage=true;
                    //this.errorMessage="Filing is already Approved";
                    window.location.reload();
                }
                else
                {
                    const nextNavigationEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(nextNavigationEvent);
                }
                return result
            }).catch(error => {
                this.isLoading = false;
                console.log(error);
                ComponentErrorLoging(
                    'brs_achPaymentScreen',
                    "getPaymentDetails",
                    "",
                    "",
                    "Medium",
                    error.message
                );
                return false;
            });
    }

    }
    changeDateFormate(date) {
        let dateData = new Date(date)
        return ('0'+(dateData.getMonth() + 1)).slice(-2) + '/' + dateData.getDate() + "/" + dateData.getFullYear();
    }

    dispatchFIlingId() {
        const attributeChangeEvent = new FlowAttributeChangeEvent('filingId', this.filingId);
        this.dispatchEvent(attributeChangeEvent);
    }
}
import { api, LightningElement, track, wire } from 'lwc';
import { 
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
    FlowNavigationBackEvent
} from 'lightning/flowSupport';
import upsertStockRecords from '@salesforce/apex/brs_stockClassificationController.upsertStockRecords';
import getStockRecords from '@salesforce/apex/brs_stockClassificationController.getStockRecords';
import deleteStockRecords from '@salesforce/apex/brs_stockClassificationController.deleteStockRecords';
import STOCK_OBJECT from '@salesforce/schema/Stock_Classification__c';
import Total_Authorized_Shares from '@salesforce/label/c.TOTAL_AUTHORIZED_SHARES';
import Franchise_Tax from '@salesforce/label/c.FRANCHISE_TAX';
import Stock_Classification_Modal_Info_Text from '@salesforce/label/c.STOCK_CLASSIFICATION_MODAL_INFO_TEXT';
import Stock_Classification_Modal_Limitation_Info_Link from '@salesforce/label/c.STOCK_CLASSIFICATION_MODAL_LIMITATION_INFO_LINK';
import Stock_Classification_Add_More from '@salesforce/label/c.STOCK_CLASSIFICATION_ADD_MORE';
import Stock_Classification_Header_Add_Class from '@salesforce/label/c.STOCK_CLASSIFICATION_HEADER_ADD_CLASS'
import Stock_Classification_Header_Add_No_Of_Stocks from '@salesforce/label/c.STOCK_CLASSIFICATION_HEADER_ADD_NO_OF_STOCKS';
import Stock_Classification_Header_Add_Par_Value from '@salesforce/label/c.STOCK_CLASSIFICATION_HEADER_ADD_PAR_VALUE';
import Stock_Classification_Modal_Total_Mis_Match_Text from '@salesforce/label/c.STOCK_CLASSIFICATION_MODAL_TOTAL_MIS_MATCH_TEXT';
import Stock_Classification_Modal_Text_Limit_Info from '@salesforce/label/c.STOCK_CLASSIFICATION_MODAL_TEXT_LIMIT_INFO';
import Stock_Classification_Modal_Confirm_Btn_Text from '@salesforce/label/c.STOCK_CLASSIFICATION_MODAL_CONFIRM_BTN_TEXT';
import Stock_Classification_Header_Add__Terms from '@salesforce/label/c.STOCK_CLASSIFICATION_HEADER_ADD_TERMS';
import Stock_Add_Edit from '@salesforce/label/c.STOCK_ADD_EDIT';
import Stock_Classification_Modal_Header from '@salesforce/label/c.STOCK_CLASSIFICATION_MODAL_HEADER';
import Stock_Classes from '@salesforce/label/c.STOCK_CLASSES';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import { ComponentErrorLoging } from "c/formUtility";
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener } from 'c/commonPubSub';
import Class_Of_Share_SubText from '@salesforce/label/c.CLASS_OF_SHARE_SUBTEXT';
import Class_Of_Share_Yes_Button from '@salesforce/label/c.CLASS_OF_SHARE_YES_BUTTON';
import Class_Of_Share_No_Button from '@salesforce/label/c.CLASS_OF_SHARE_NO_BUTTON';
import Stock_Classification_Modal_Re_Edit_Error_Text from '@salesforce/label/c.STOCK_CLASSIFICATION_MODAL_RE_EDIT_ERROR_TEXT';
import stockClassificationNoInputMsg from '@salesforce/label/c.brs_stockClassificationNoInputMsg';
import BusinessAuthorizartionText1 from '@salesforce/label/c.BusinessAuthorizartionText1';
import BusinessAuthorizartionText2 from '@salesforce/label/c.BusinessAuthorizartionText2';
import Describeyourclassification from '@salesforce/label/c.Describeyourclassification';
import SC_parvalue_ph from '@salesforce/label/c.SC_parvalue_ph';
import SC_class_ph from '@salesforce/label/c.SC_class_ph';
import SC_noofstocks_ph from '@salesforce/label/c.SC_noofstocks_ph';
import { showOrHideBodyScroll } from "c/appUtility";
import Back from '@salesforce/label/c.Back';
import Next from '@salesforce/label/c.Next'; 
import Minimum_franchise_tax from '@salesforce/label/c.Minimum_franchise_tax';
import Please_Note from '@salesforce/label/c.Please_Note';

export default class stockClassification extends LightningElement {
    @track addIcon = assetFolder + "/icons/add-circle-outline.svg";
    @track deleteIcon = assetFolder + "/icons/delete-icon.png";
    @api objectApiName = STOCK_OBJECT;
    @track compName = "brs_stockClassification";
    @track isModalOpen = false;
    @api totalStockAdded;
    @track disableLink = true;
    @track link = 'https://www.cga.ct.gov/current/pub/chap_601.htm#sec_33-665';
    @track disableConfirmButton = true;
    @track showDeleteIcon = false;
    @api totalStocksEntered = 0;
    @track showTotalMisMatchError = false;
    @track showTotalMisMatchErrorOnEdit = false;
    @track accountId;
    @api displayStockDetails = false;
    @track specChar;
    @track showTextArea = false;
    @track editIcon = assetFolder + "/icons/edit-grey.svg";
    @track modalSize = 'small';
    @track nextLabel = Next;
    @track backLabel = Back;
    @track topPleaseNoteSection;
    @api showClassPopUP;
    @api accinfo1;
    @api totalStockAddedbyuser;
    @api value;
    @api isNoButtonClicked;
    @api hidePopUP = false;
    @wire(CurrentPageReference) pageRef;
    keyIndex = 0;
    @api stocksList = [
        {
            Stock_Class__c: '',
            Number_of_Stocks__c: null,
            Par_Value__c: null,
            Classification_Description__c: null,
            required: false
        }];
    @api accinfo = {
        Total_Authorized_Shares__c: null,
        Franchise_Tax__c: null
    };
    @api accountrecord;
    @api tax;

    label = {
        Total_Authorized_Shares,
        Franchise_Tax,
        Stock_Classification_Modal_Info_Text,
        Stock_Classification_Modal_Limitation_Info_Link,
        Stock_Classification_Add_More,
        Stock_Classification_Header_Add_Class,
        Stock_Classification_Header_Add_No_Of_Stocks,
        Stock_Classification_Header_Add_Par_Value,
        Stock_Classification_Modal_Total_Mis_Match_Text,
        Stock_Classification_Modal_Text_Limit_Info,
        Stock_Classification_Modal_Confirm_Btn_Text,
        Stock_Classification_Header_Add__Terms,
        Stock_Add_Edit,
        Stock_Classification_Modal_Header,
        Stock_Classes,
        Class_Of_Share_SubText,
        Class_Of_Share_Yes_Button,
        Class_Of_Share_No_Button,
        Stock_Classification_Modal_Re_Edit_Error_Text,
        stockClassificationNoInputMsg,BusinessAuthorizartionText1,BusinessAuthorizartionText2,
        SC_parvalue_ph,
        SC_class_ph,
        SC_noofstocks_ph,
        Describeyourclassification,
        Please_Note,
        Minimum_franchise_tax
    }

    connectedCallback() {
        if (!this.pageRef) {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
        }
        this.isNoButtonClicked = false;
        this.topPleaseNoteSection = `<p class="small"><b class="dull-orange-text">${this.label.Please_Note}</b></p><p class="small karaka-text">${this.label.Minimum_franchise_tax}</p>`;
        const noButtonClickedEvent = new FlowAttributeChangeEvent('isNoButtonClicked', this.isNoButtonClicked);
        this.dispatchEvent(noButtonClickedEvent);
        if (this.accountrecord) {
            this.accountId = this.accountrecord.Id;
            this.accinfo.Total_Authorized_Shares__c = this.accountrecord.Total_Authorized_Shares__c ? this.accountrecord.Total_Authorized_Shares__c : null;
            this.accinfo.Franchise_Tax__c = this.accountrecord.Franchise_Tax__c ? this.accountrecord.Franchise_Tax__c : null;
            this.tax = this.accinfo.Franchise_Tax__c;
            if (this.accinfo.Total_Authorized_Shares__c) {
                this.disableLink = false;
            }
            this.accinfo1 = this.accinfo;
        } else {
                this.accinfo.Total_Authorized_Shares__c = this.totalStockAddedbyuser;
                this.accinfo.Franchise_Tax__c = this.tax;
                if (this.accinfo.Total_Authorized_Shares__c) {
                    this.disableLink = false;
                }
                this.accinfo1 = this.accinfo;
            }
        if(this.accountId){
            this.getStocks();
        }
        
    }

    setAccData(event) {
        if (!this.specChar) {
            this.accinfo.Total_Authorized_Shares__c = event.target.value;
            this.totalStockAddedbyuser =  event.target.value;
        }
        var accRecValue = this.accountrecord ? JSON.parse(JSON.stringify(this.accountrecord)) : {};
        if (this.accinfo.Total_Authorized_Shares__c && this.accinfo.Total_Authorized_Shares__c!=0) {
            this.disableLink = false;
            this.calculateFranchiseTax();
            accRecValue.Total_Authorized_Shares__c = this.accinfo.Total_Authorized_Shares__c;
            accRecValue.Franchise_Tax__c = this.accinfo.Franchise_Tax__c;
            this.accountrecord = Object.assign({}, accRecValue);
        } else {
            this.disableLink = true;
            this.tax = 0;
            this.accinfo.Total_Authorized_Shares__c = null;
            accRecValue.Total_Authorized_Shares__c = this.accinfo.Total_Authorized_Shares__c;
            accRecValue.Franchise_Tax__c = this.tax;
            this.accountrecord = Object.assign({}, accRecValue);
        }
        const attributeChangeEvent = new FlowAttributeChangeEvent('accinfo1', this.accountrecord);
        this.dispatchEvent(attributeChangeEvent);
    }

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        this.showClassPopUP = false;
        showOrHideBodyScroll(true);
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        showOrHideBodyScroll(false); 
    }

    calculateFranchiseTax() {
        let franchiseTax = 0;
        const flatFranchiseTax = 150;
        const flatTaxBracket2 = 400;
        const flatTaxBracket3 = 2650;
        const minSharesTaxBracket1 = 20000;
        const maxSharesTaxBracket1 = 100000;
        const minSharesTaxBracket2 = 100001;
        const maxSharesTaxBracket2 = 1000000;
        const perShareCostTaxBracket1 = 0.005;
        const perShareCostTaxBracket2 = 0.0025;
        const perShareCostTaxBracket3 = 0.0020;
        const shares = this.accinfo.Total_Authorized_Shares__c;
        if (shares > minSharesTaxBracket1) {
            franchiseTax += flatFranchiseTax;
            if (shares <= maxSharesTaxBracket1) {
                franchiseTax += (shares - minSharesTaxBracket1) * perShareCostTaxBracket1;
            } else if (shares >= minSharesTaxBracket2 && shares <= maxSharesTaxBracket2) {
                franchiseTax += flatTaxBracket2 + (shares - maxSharesTaxBracket1) * perShareCostTaxBracket2;
            } else {
                franchiseTax += flatTaxBracket3 + (shares - maxSharesTaxBracket2) * perShareCostTaxBracket3;
            }
            this.tax = franchiseTax;
        } else {
            this.tax = flatFranchiseTax;
        }
        this.accinfo.Franchise_Tax__c = this.tax;
    }
    saveStock() {
        upsertStockRecords({
            result: this.stocksList,
        })
            .then(result => {
                this.stocksList = result;
                this.isModalOpen = false;
                showOrHideBodyScroll(false);
            })
            .catch(error => {
                ComponentErrorLoging(
                    this.compName,
                    "upsertStockRecords",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
    }
    addRow() {
        this.keyIndex = this.keyIndex + 1;
        this.stocksList.push({
            Stock_Class__c: '',
            Number_of_Stocks__c: null,
            Par_Value__c: null,
            AccountId__c: this.accountId,
            required: true
        });
        this.showDeleteIcon = true;
        this.showTextArea = true;
    }

    removeRow(event) {
        if (this.stocksList.length >= 2) {
            const index = event.currentTarget.accessKey;
            const stock = this.stocksList[index];
            const id = stock.Id;
            if (id) {
                this.deleteStocks(id);
            }
            this.stocksList.splice(index, 1);
            this.keyIndex -= 1;
            if (this.stocksList.length == 1) {
                this.showDeleteIcon = false;
                this.stocksList[0].required = false;
                this.showTextArea = false;
            }
        }
    }

    validateFields(event) {
        var isVal = true;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            isVal = isVal && element.checkValidity();
        });
        if (this.stocksList.length === 1) {
            if (isVal) {
                this.disableConfirmButton = false;
            } else {
                this.disableConfirmButton = true;
            }
        }
        if (event.target.name === 'stockClass')
            this.stocksList[event.target.accessKey].Stock_Class__c = event.target.value;
        else if (event.target.name === 'noOfStocks') {
            this.onSharesInputBlur(event);
            if(event.target.value){
                this.stocksList[event.target.accessKey].Number_of_Stocks__c = parseInt(event.target.value);
                this.verifyStocksCount();
            }
        }
        else if (event.target.name === 'parVal') {
            this.stocksList[event.target.accessKey].Par_Value__c = parseFloat(event.target.value);
        }
        else if (event.target.name === 'desc') {
            this.stocksList[event.target.accessKey].Classification_Description__c = event.target.value;
        }
    }
    submitDetails() {
        const inputTextValidation=[...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        const istextAreaValid=[...this.template.querySelectorAll('lightning-textarea')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        if (inputTextValidation && istextAreaValid) {
            const total = this.getTotalStocksClassified();
            if (total == this.accinfo.Total_Authorized_Shares__c) {
                this.totalStocksEntered = this.stocksList.length;
                // Update record BE call
                this.showTotalMisMatchError = false;
                this.showTotalMisMatchErrorOnEdit = false;
                this.saveStock();
                this.displayStockDetails = true;
            } else {
                this.showTotalMisMatchError = true;
            }
        }
    }

    verifyStocksCount() {
        const total = this.getTotalStocksClassified();
        if (total == this.accinfo.Total_Authorized_Shares__c || this.accinfo.Total_Authorized_Shares__c==0) {
            this.showTotalMisMatchError = false;
        }
    }

    deleteStocks(id) {
        deleteStockRecords({ stockId: id })
		.catch((error) => {
            ComponentErrorLoging(
                this.compName,
                "deleteStockRecords",
                "",
                "",
                "Medium",
                error.message
            );
        });;
    }
    handleKeyPress(event) {
        var charCode = event.keyCode || event.which;
        if (charCode !== 229 && charCode !== 8 && (charCode < 48 || (charCode > 57 && charCode < 96) || charCode > 105)) {
            this.specChar = true;
            event.preventDefault();
        } else {
            this.specChar = false;
        }
    }

    //Salesforce hook
    @api
    validate() {
        debugger;
        var validationFlag = false;
        var inputFields = this.template.querySelectorAll("lightning-input[data-id=authId]");
        if (inputFields !== null && inputFields !== undefined) {
            inputFields.forEach(function (field) {
                field.reportValidity();
            });
            for (var i = 0; i < inputFields.length; i++) {
                validationFlag = inputFields[i].checkValidity();
                if (!validationFlag) {
                    break;
                }
            }
            if (validationFlag) {
                if (this.displayStockDetails) {
                    const total = this.getTotalStocksClassified();
                    if (total == this.accinfo.Total_Authorized_Shares__c) {
                        const nextNavigationEvent = new FlowNavigationNextEvent();
                        this.dispatchEvent(nextNavigationEvent);
                    } else {
                        if (this.accinfo.Total_Authorized_Shares__c && this.accinfo.Total_Authorized_Shares__c!=0){
                            this.showTotalMisMatchErrorOnEdit = true;
                        }
                        else{
                            this.showTotalMisMatchErrorOnEdit = false;
                        }
                        
                    }
                } else {
                    if(this.totalStocksEntered > 0 || (this.totalStocksEntered <= 0 && this.isNoButtonClicked)){
                        const nextNavigationEvent = new FlowNavigationNextEvent();
                        this.dispatchEvent(nextNavigationEvent);
                    } else if (this.totalStocksEntered <= 0 && !this.isNoButtonClicked){
                        this.showClassPopUP = this.hidePopUP ? false : true;
                        if(!this.showClassPopUP){
                            const nextNavigationEvent = new FlowNavigationNextEvent();
                            this.dispatchEvent(nextNavigationEvent);
                        }
                    }
                }
            }
            
        }
    }

    closeClassOfShareModal() {
        this.showClassPopUP = false;
    }

    handleNext() {
        this.isNoButtonClicked = true;
        this.closeClassOfShareModal();
        const attributeChangeEvent = new FlowAttributeChangeEvent('showClassPopUP', this.showClassPopUP);
        this.dispatchEvent(attributeChangeEvent);
        const noButtonClickedEvent = new FlowAttributeChangeEvent('isNoButtonClicked', this.isNoButtonClicked);
        this.dispatchEvent(noButtonClickedEvent);
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }

    getTotalStocksClassified() {
        let total = 0;
        this.stocksList.forEach(item => {
            total += item.Number_of_Stocks__c;
        });
        return total;
    }
    /**
     * @function onSharesInputBlur - method written to prevent user to enter zero
     * @param {event} - event triggered
     */
    onSharesInputBlur(e){
        if(Number(e.target.value) === 0){
            if (e.target.name === 'noOfStocks') {
                e.target.value = '';
                this.stocksList[e.target.accessKey].Number_of_Stocks__c = '';
            } else {
                this.accinfo = {
                    ...this.accinfo,
                    Total_Authorized_Shares__c: ''
                } 
            }
        }
    }
    back(){
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    getStocks(){
        getStockRecords({ accountId: this.accountId })
            .then((data) => {
                if (data && data.length != 0) {
                    this.totalStocksEntered = data.length;
                    this.stocksList = [];
                    data.forEach((item, index) => {
                        let stockData = Object.assign({}, item);
                        if (index === 0) {
                            stockData['required'] = false;
                        } else {
                            stockData['required'] = true;
                        }
                        this.stocksList.push(stockData);
                    })
                    this.disableConfirmButton = false;
                    this.displayStockDetails = true;
                    this.disableLink = false;
                    if (this.totalStocksEntered > 1) {
                        this.showDeleteIcon = true;
                        this.showTextArea = true;
                    }
                } else {
                    this.stocksList[0].AccountId__c = this.accountId;
                }
            }).catch((error) => {
                this.stocksList[0].AccountId__c = this.accountId;
                ComponentErrorLoging(
                    this.compName,
                    "getStockRecords",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            })
    }
}
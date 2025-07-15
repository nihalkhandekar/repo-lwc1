import { LightningElement, track, api, wire } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import { fireEvent, registerListener } from 'c/commonPubSub';
import { CurrentPageReference } from "lightning/navigation";
import deleteAgentRecord from '@salesforce/apex/brs_contactDetailPage.deleteAgentRecord';
import insertAgentRecord from '@salesforce/apex/brs_contactDetailPage.insertAgentRecord';
import GenericInput_Invalid_Email from "@salesforce/label/c.GenericInput_Invalid_Email";
import GenericInput_Email_Missmatch from "@salesforce/label/c.GenericInput_Email_Missmatch";
import Generic_Input_Error_Message from "@salesforce/label/c.Generic_Input_Error_Message"
import Com_PhoneAlert from '@salesforce/label/c.Com_PhoneAlert';
import getAgentRecordsonLoad from '@salesforce/apex/brs_contactDetailPage.getAgentRecordsonLoad';
import getTempRecordsonLoad from '@salesforce/apex/brs_contactDetailPage.getTempRecordsonLoad';
import deleteTempRecord from '@salesforce/apex/brs_contactDetailPage.deleteTempRecord';
import updateAgentRecord from '@salesforce/apex/brs_contactDetailPage.updateAgentRecord';
import { ComponentErrorLoging } from "c/formUtility";
import { emailPattern, showOrHideBodyScroll,focusTrap,formatMobileNumberOnEntering,getMailingAddress } from "c/appUtility";
import Add_Agent from '@salesforce/label/c.Add_Agent';
import Add_Agent_Description from '@salesforce/label/c.Add_Agent_Description';
import Add_Agent_Details from '@salesforce/label/c.Add_Agent_Details';
import Edit from '@salesforce/label/c.Edit';
import Remove from '@salesforce/label/c.Remove';
import Name from '@salesforce/label/c.Name';
import Next from '@salesforce/label/c.Next';
import Mailing_Address from '@salesforce/label/c.Mailing_Address';
import Agent_fields_Mandatory from '@salesforce/label/c.Agent_fields_Mandatory';
import Back from '@salesforce/label/c.Back';
import Agent_Select_Option from '@salesforce/label/c.Agent_Select_Option';
import Email_Address from '@salesforce/label/c.Email_Address';
import Manual_Add_Individual_Agent from '@salesforce/label/c.Manual_Add_Individual_Agent';
import Confirm from '@salesforce/label/c.Confirm';
import Search_Business_Agent from '@salesforce/label/c.Search_Business_Agent';
import brs_Residence_Address from '@salesforce/label/c.brs_Residence_Address';
import brs_Business_Address from '@salesforce/label/c.brs_Business_Address';
import Search_Business_Agent_Description from '@salesforce/label/c.Search_Business_Agent_Description';
import Principal_As_Agent from '@salesforce/label/c.Principal_As_Agent';
import Search_Result from '@salesforce/label/c.Search_Result';
import No_Result from '@salesforce/label/c.No_Result';
import Principal_As_Agent_Description from '@salesforce/label/c.Principal_As_Agent_Description';
import Agent_Business from '@salesforce/label/c.Agent_Business';
import Agent_New_Business from '@salesforce/label/c.Agent_New_Business';
import Please_Note from '@salesforce/label/c.Please_Note';
import Agent_Appointed_Description from '@salesforce/label/c.Agent_Appointed_Description';
import EDIT_ADDRESS_INFO from '@salesforce/label/c.EDIT_ADDRESS_INFO';
import CANCEL_EDITING from '@salesforce/label/c.CANCEL_EDITING';
import Business_ID from '@salesforce/label/c.Business_AELI';
import Phone from '@salesforce/label/c.Phone';
import Phone_No from '@salesforce/label/c.Phone_No';
import Business_Type_LLC from '@salesforce/label/c.Business_Type_LLC';
import Stock from '@salesforce/label/c.Stock';
import Business_Type_BCORP from '@salesforce/label/c.Business_Type_BCORP';
import Domestic from '@salesforce/label/c.Domestic_Label_Comparable';
import Foreign from '@salesforce/label/c.Foreign_Label_Comparable';
import Non_Stock from '@salesforce/label/c.Non_Stock';
import Secretary_Of_State from '@salesforce/label/c.Secretary_Of_State';
import Secretary_Of_State_Address from '@salesforce/label/c.Secretary_Of_State_Address';
import Secretary_Header from '@salesforce/label/c.Secretary_Header';
import Secretary_Description from '@salesforce/label/c.Secretary_Description';
import Secretary_Of_State_City from '@salesforce/label/c.Secretary_Of_State_City';
import Secretary_Of_State_StateValue from '@salesforce/label/c.Secretary_Of_State_StateValue';
import Secretary_Of_State_Street from '@salesforce/label/c.Secretary_Of_State_Street';
import Secretary_Of_State_ZipCode from '@salesforce/label/c.Secretary_Of_State_ZipCode';
import businessProfile_agent from '@salesforce/label/c.businessProfile_agent';
import brs_Connecticut from '@salesforce/label/c.brs_Connecticut';
import Agent_fields_Mandatory1 from '@salesforce/label/c.Agent_fields_Mandatory1';
import Mobile_Number from '@salesforce/label/c.Mobile_Number';
import ADD_Int_Addr_Label from "@salesforce/label/c.ADD_Int_Addr_Label";
import Change_Agent_Label from "@salesforce/label/c.Change_Agent_Label";
import upsertTempRecord from '@salesforce/apex/brs_contactDetailPage.upsertTempRecord';
import BRS_Addagent from '@salesforce/label/c.BRS_Addagent';
import Agent_Change_Name from '@salesforce/label/c.Agent_Change_Name';
import Agent_Individual_Option from '@salesforce/label/c.Individual';
import Agent_Business_Option from '@salesforce/label/c.Business_Comparable';
import firstreport_flow_name from '@salesforce/label/c.firstreport_flow_name';
import annualreport_flow_name from '@salesforce/label/c.annualreport_flow_name';
import agent_annual_subheader from '@salesforce/label/c.agent_annual_subheader';
import agent_annual_header from '@salesforce/label/c.agent_annual_header';
import agent_annual_header1 from '@salesforce/label/c.agent_annual_header1';
import First_Name_Placeholder from '@salesforce/label/c.First_Name_Placeholder';
import Last_Name_Placeholder from '@salesforce/label/c.Last_Name_Placeholder';
import Mobilenumber_Placeholder from '@salesforce/label/c.Mobilenumber_Placeholder';
import Email_Placeholder from '@salesforce/label/c.Email_Placeholder';
import AddressUnit_Apt from '@salesforce/label/c.AddressUnit_Apt';
import Agent_Confirm_Header from '@salesforce/label/c.Agent_Confirm_Header';
import Agent_Confirm_Subheader from '@salesforce/label/c.Agent_Confirm_Subheader';
import Business_Error_Validation from '@salesforce/label/c.Business_Error_Validation';
import Cancel_Label from '@salesforce/label/c.Cancel_Label';
import brs_Add_Incorporator_SelectType from '@salesforce/label/c.brs_Add_Incorporator_SelectType';
import BRS_Addagent_Change from '@salesforce/label/c.BRS_Addagent_Change';
import First_Name_Required from '@salesforce/label/c.First_Name_Required';
import Business_Search_Error_Validation from '@salesforce/label/c.Business_Search_Error_Validation';
import Last_Name_Required from '@salesforce/label/c.Last_Name_Required';
import Confirm_Email from '@salesforce/label/c.Confirm_Email';
import Agent_Resignation from '@salesforce/label/c.Agent_Resignation_Comparable';
import verify_SectretaryState from '@salesforce/label/c.verify_SectretaryState';
import brs_maintenance_address_agent from '@salesforce/label/c.brs_maintenance_address_agent';
import address_error_message from '@salesforce/label/c.address_error_message';
import Same_As_Business_Address from '@salesforce/label/c.Same_As_Business_Address';
import Same_As_Principal_Address from '@salesforce/label/c.Same_As_Principal_Address';
import Connecticut_Business_Address from '@salesforce/label/c.Connecticut_Business_Address';
import Connecticut_Mailing_Address from '@salesforce/label/c.Connecticut_Mailing_Address';
import CT from '@salesforce/label/c.CT';
import Email_Address_Required from '@salesforce/label/c.Email_Address_Required';
import Mobile_Number_Required from '@salesforce/label/c.Mobile_Number_Required';
import Update from '@salesforce/label/c.Update';
import not_applicable from '@salesforce/label/c.not_applicable';
import United_States from '@salesforce/label/c.United_States';
import { agentLabels } from "c/brs_agentUtility";
export default class Brs_addAgentDetails extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    label = {
        Add_Agent, Add_Agent_Description, Add_Agent_Details, Edit, Email_Address, Name, Remove,
        Mailing_Address, Agent_Select_Option, Manual_Add_Individual_Agent, EDIT_ADDRESS_INFO,
        Agent_fields_Mandatory, CANCEL_EDITING, Business_ID, Phone, Next, Search_Business_Agent,
        Search_Business_Agent_Description, Back, Confirm, brs_Business_Address,
        brs_Residence_Address, Principal_As_Agent, Principal_As_Agent_Description, Agent_Business,
        Agent_New_Business, Search_Result, No_Result, Please_Note, Agent_Appointed_Description,
        GenericInput_Invalid_Email, GenericInput_Email_Missmatch, Com_PhoneAlert,
        Phone_No, Business_Type_LLC, Business_Type_BCORP, Stock, Domestic, First_Name_Placeholder,Last_Name_Placeholder,
        Mobilenumber_Placeholder, Email_Placeholder, Agent_Confirm_Header, Agent_Confirm_Subheader,
        Foreign, Non_Stock, Secretary_Of_State, Secretary_Of_State_Address, Secretary_Description,
        Secretary_Header, Secretary_Of_State_ZipCode, Secretary_Of_State_Street,
        Secretary_Of_State_StateValue, Secretary_Of_State_City, businessProfile_agent,
        brs_Connecticut, Agent_fields_Mandatory1, Mobile_Number, Change_Agent_Label,
        BRS_Addagent, Agent_Change_Name, Agent_Individual_Option, Agent_Business_Option,
        firstreport_flow_name, annualreport_flow_name, agent_annual_subheader, agent_annual_header,
        agent_annual_header1, Business_Error_Validation, Cancel_Label, brs_Add_Incorporator_SelectType,
        BRS_Addagent_Change, First_Name_Required, Last_Name_Required,Confirm_Email, Agent_Resignation, brs_maintenance_address_agent, Business_Search_Error_Validation,
        verify_SectretaryState, address_error_message, AddressUnit_Apt, CT, Same_As_Business_Address,
        Same_As_Principal_Address, Connecticut_Business_Address, Connecticut_Mailing_Address, Email_Address_Required,
        Mobile_Number_Required, Update, not_applicable, United_States ,...agentLabels
    };
    @track residenceLowerCaseLabel;@track mailingLowerCaseLabel;@track businessLowerCaseLable;@track businessRequired = false;
    @api isAgentChanged = false;@api isTempDeleted = false;@api flowName;@api filingId;@api showAgentErrorMessageNew = false;
    @api tempId;@api showTemp = false; @api AgentChangeError = false;@api showAgent= false;
    @api varNewFilingId;@api isFlowReport = false;
    @api accountrecord;@api getAgentDetailsData = undefined;
    @api showTempValue = false;@api source = "Worker Portal";
    @api businessFiling;@api principalList = undefined;
    @api isAddressChange = false;@api addAgentRecordData;
    @api isAgentChangeFlow = false;@api hasAddressChanged = false;
    @api tempHistory;
    @track showUpdateButton = false;
    @track showAgentErrorMessage = false;
    @track isEditedAddressFields = false;
    @track isLoading = false;
    @track emailPattern = emailPattern;
    @track businessErrorValidation = '';
    @track compName = "brs_addAgentDetails";
    @track name; @track phone; @track email;
    @track selectedPrincipalAddressId;
    @track secretaryRecord = false;
    @track agentId = '';
    @track addIcon = assetFolder + "/icons/add-circle-outline.svg";
    @track closeIcon = assetFolder + "/icons/close-outline-blue.svg";
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track changeUser = assetFolder + "/icons/changeuser.svg";
    @track editIcon = assetFolder + "/icons/edit-blue.svg";
    @track deleteIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track addAgentData = false;
    @track addAgentDataIndividual = false;
    @track individualBusinessAddress = false;
    @track addAgentMainPopup = false;
    @track searchAgentBusiness = false;
    @track addBusinessAgentInfo = false;
    @track showMailingAddress = false;
    @track domesticForigenFlowBtns = false;
    @track firstAndAnnualFlowBtns = false;
    @track selectedAgentOption = "";
    @track AgentFirstName;
    @track AgentLastName;
    @track AgentPhone;
    @track AgentEmail;
    @track AgentConfirmEmail = "";
    @track searchKey = "";@track addSecretaryState = false;
    @track readonlyAgentDetails = false;@track checkAgentChanged = false;
    @track acceptPoBox = true;@track errorMessageForSearch = '';@track accountId = "";@track showPrincipalCheckbox = true;
    @track hasTempAddress = false;@track agentRecord = false;@track changeAgentRecord = false;@track FirstReportName = false;
    @track changegentMainPopup = false;@track addAgentPopupBtn = true;@track agentBusinessEmailAddress = "";@track agentBusinessConfirmEmailAddress = "";
    @track agentBusinessPhoneNumber = "";@track editAddInfoBtn = false;@track editInfoDetails = false;@track copyBusinessAddressCheck = false;
    @track copyMailingAddressCheck = false;@track copyPrincipalAddressCheck = false;@track businessIdValue = "";@api searchAgentResult;
    @track showBackButton = true;@track editTempRecord = false;@track editBusinessId = '';@track hidecheckbox = true;
    @track agentBusinessAddress = "";@track isTempApis = false;@track isAgentResignation = false;@track isAgentChange = false;
    @track isAnnualFlow = false;@track isFirstReportFlow = false;@track changeAgentName = false;@track agentBusinessHeader = this.label.Agent_Business;
    @track originalAgentId = "";@track agentChanged = false;@track errorText ="";@track showPleaseNote = true;
    @track initialAddressFields = {addressStreet:"",addressUnit:"",addressCity:"",addressState:"",addressZip:"",addressInternational:"",addressCountry:""}
    @track principalOfficeAddressCheckboxOptions = [{label: this.label.Same_As_Principal_Address, value: this.label.Same_As_Principal_Address}];
    @track selectedRadio;
    @api businessAddressFields = {...this.initialAddressFields}
    @api residenceAddressFields = {...this.initialAddressFields}
    @api mailingAddressFields = {...this.initialAddressFields}
    @track businessAddressCheckboxOptions = [{
        label: this.label.Same_As_Business_Address,
        value: this.label.Same_As_Business_Address,
        isDisabled: true
    }];
    @track initialData = {Type__c:"",Email__c:"",Type__c_Error:false,addAgentPopupBtn:true,Agent_Phone__c:"",Name__c:"",FirstName__c:"",LastName__c:"",Id:"",Business_ID__c:"",Business_City__c:"",Business_Country__c:"",Business_Street_Address_1__c:"",Business_Street_Address_2__c:"",Business_Zip_Code__c:"",Business_InternationalAddress__c:"",Business_Address__c:"",Business_State__c:"",Residence_City__c:"",Residence_Country__c:"",Residence_Street_Address_1__c:"",Residence_Street_Address_2__c:"",Residence_Zip_Code__c:"",Mailing_City__c:"",Mailing_Country__c:"",Mailing_Street_Address_1__c:"",Mailing_Street_Address_2__c:"",Mailing_Zip_Code__c:"",Mailing_State__c:""};
    @track businessPrincipalTableData = [];
    @track agentIndividualTableData = [];
    @track showAddressFormWhenAnyFieldMiss = false;
    @api agentData = {...this.initialData};
    @track secretaryData = [{
        Business_Name__c: this.label.Secretary_Of_State,
        Business_Address__c: this.label.Secretary_Of_State_Address
    }];
    @track secretaryColumns = [
        {
            label: this.label.Name,
            fieldName: 'Business_Name__c',
            type: 'text',
            sortable: false
        },
        {
            label: this.label.Recovery_SelfCertify_BusinessAddressLabel,
            fieldName: 'Business_Address__c',
            type: 'text',
            sortable: false
    }];
    @api get principalOptions() {
        return this._principalOptions;
    }
    set principalOptions(opt) {
        this._principalOptions = JSON.parse(opt);
    }
    @api get agentOptionsWithSec() {
        return this._agentOptionsWithSec;
    }
    set agentOptionsWithSec(opt) {
        this._agentOptionsWithSec = JSON.parse(opt);
    }
    @api get agentOptionsWithoutSec() {
        return this._agentOptionsWithoutSec;
    }
    set agentOptionsWithoutSec(opt) {
        this._agentOptionsWithoutSec = JSON.parse(opt);
    }
    get getIndividualColumns() {
        let tablecolumns = [{
            label: this.label.Name,
            fieldName: 'name',
            sortable: false
        },
        {
            label: this.label.Mobile_Number,
            fieldName: 'phone',
            sortable: false
        },
        {
            label: this.label.Email_Address,
            fieldName: 'email',
            sortable: false
        }
        ];
        this.agentIndividualTableData = [{
            name: this.name,
            phone: this.phone,
            email: this.email
        }];
        return tablecolumns;
    }
    get getBusinessPrincipalColumns() {
        let tablecolumns = [{
            label: this.label.Business_ID,
            fieldName: 'Business_ID__r',
            sortable: false
        },
        {
            label: this.label.Name,
            fieldName: 'Name__c',
            sortable: false
        },
        {
            label: this.label.brs_Business_Address,
            fieldName: 'Business_address__c',
            sortable: false
        }, {
            label: this.label.Mailing_Address,
            fieldName: 'Mailing_address__c',
            sortable: false
        }
        ];
        this.businessPrincipalTableData = [{
            ...this.searchAgentResult
        }];
        return tablecolumns;
    }
    mobileHandler(event) {
        this.mobilenumberFormate(event.target.value);
    }
    mobileHandlerBusiness(event) {
        this.mobilenumberFormate(event.target.value);
    }
    onMobileNumberKeyPress(event){
        const charCode = event.keyCode || event.which;
        if (charCode < 48 || charCode > 57) {
            event.preventDefault();
        }
    }
    get getHeaderClassName(){
        const withBelowSpace = "slds-col slds-large-size_11-of-12 slds-size_11-of-12 modelHeader";
        const withOutBelowSpace = "slds-col slds-large-size_11-of-12 slds-size_11-of-12";
        return this.showPleaseNote ? withBelowSpace : withOutBelowSpace;
    }
    mobilenumberFormate(mobileNumber) {
        this.businessErrorValidation = false;
        let formatedNumber = formatMobileNumberOnEntering(mobileNumber);
        this.AgentPhone = formatedNumber;
        this.agentBusinessPhoneNumber = formatedNumber;
    }
    handlePhoneBlur(event) {
        this.AgentPhone = event.target.value;
    }
    handlePhoneBlurBusiness(event) {
        this.agentBusinessPhoneNumber = event.target.value;
    }
    get agentOptions() {
        if (this.accountrecord && (this.accountrecord.Citizenship__c == this.label.Foreign && (this.accountrecord.Business_Type__c == this.label.Limited_Partnership_Comparable || this.accountrecord.Business_Type__c == this.label.Business_Type_LLC || this.accountrecord.Business_Type__c === this.label.Non_Stock || this.accountrecord.Business_Type__c === this.label.Stock))) {
            return this._agentOptionsWithSec;
        } else {
            return this._agentOptionsWithoutSec;
        }
    }
    @api validate() {
        let isValid = true;
        if((this.isAnnualFlow || this.isFirstReportFlow ) && !this.checkBusinessLinkage()){
            isValid = false;
        }else if((this.isFirstReportFlow || this.isAnnualFlow) && this.getAgentDetailsData && this.isAnyMandatoryFieldMissing()){
            isValid = false;
        }else if (this.isAgentChange && this.getAgentDetailsData && !this.isAgentChangeFlow) {  
            isValid = false;
        } else if(this.isAddressChange && !this.isAgentChangeFlow){
            isValid = false;
        } else if(!this.getAgentDetailsData){
            isValid = false;
        }
        fireEvent(this.pageRef, "flowvalidation", {
            detail: { isValid }
        });
        return {
            isValid,
            errorMessage: ""
        };
    }
    isAnyMandatoryFieldMissing(){
        let agentData = this.getAgentDetailsData;
        let hasMissingField = false;
        if(agentData.Temp_Type__c == this.label.Agent_Individual_Option || agentData.Type__c == this.label.Agent_Individual_Option){
            const firstName = agentData.FirstName__c;
            const lastName = agentData.LastName__c;
            const phoneNumber = agentData.Phone__c || agentData.Agent_Phone__c;
            const email = agentData.Email__c;
            const residenceAddress = agentData.Residence_Street_Address_1__c && agentData.Residence_City__c && agentData.Residence_State__c && agentData.Residence_Zip_Code__c;
            hasMissingField = !firstName || !lastName || !residenceAddress || !phoneNumber || !email || agentData.Residence_State__c !== this.label.CT;  
        } else if(!this.secretaryRecord) {
            const businessName = agentData.Name__c;
            const phoneNumber = agentData.Phone__c || agentData.Agent_Phone__c;
            const email = agentData.Email__c;
            const businessAddress = agentData.Business_Street_Address_1__c && agentData.Business_City__c && agentData.Business_State__c && agentData.Business_Zip_Code__c;
            hasMissingField = !businessName || !phoneNumber || !email || !businessAddress || agentData.Business_State__c !== this.label.CT;
        }
        if(!this.secretaryRecord && this.showMailingAddress && !hasMissingField){
            let mailingeAddress = agentData.Mailing_Street_Address_1__c && agentData.Mailing_City__c && agentData.Mailing_State__c && agentData.Mailing_Zip_Code__c;
            hasMissingField = !mailingeAddress || agentData.Mailing_State__c !== this.label.CT;
        } 
        return hasMissingField;
    }
    connectedCallback() {
        this.residenceLowerCaseLabel = this.label.brs_Residence_Address.toLowerCase();
        this.mailingLowerCaseLabel = this.label.Mailing_Address.toLowerCase();
        this.businessLowerCaseLable = this.label.brs_Business_Address.toLowerCase();
        if (this.varNewFilingId != null && this.varNewFilingId != undefined) {
            var cloneRes = JSON.parse(this.varNewFilingId);
            this.filingId = cloneRes[0].filingId;
        }
        this.isAnnualFlow = this.flowName === this.label.annualreport_flow_name;
        this.isFirstReportFlow = this.flowName === this.label.firstreport_flow_name;
        this.isAgentChange = this.flowName === this.label.Agent_Change_Name;
        this.isAddressChange = this.flowName === this.label.brs_maintenance_address_agent;
        this.isTempApis = (this.flowName === this.label.firstreport_flow_name || this.isAnnualFlow);
        this.isAgentResignation = this.flowName === this.label.Agent_Resignation
        if (this.accountrecord) {
            var accRecValue = JSON.parse(JSON.stringify(this.accountrecord));
            if (accRecValue) {
                this.accountId = accRecValue.Id;
                if (accRecValue.Citizenship__c == this.label.Domestic) {
                    if (accRecValue.Business_Type__c == this.label.Business_Type_LLC ||
                        accRecValue.Business_Type__c == this.label.Business_Type_BCORP ||
                        accRecValue.Business_Type__c == this.label.Stock) {
                        this.showMailingAddress = true;
                    } else {
                        this.showMailingAddress = false;
                    }
                }
                else {
                    if (accRecValue.Business_Type__c == this.label.Business_Type_LLC) {
                        this.showMailingAddress = true;
                    } else {
                        this.showMailingAddress = false;
                    }
                }
            }
            this.hasPrincipalOfficeAddress();
        }
        if (this.isAddressChange) {
            this.firstAndAnnualFlowBtns = true;
            this.domesticForigenFlowBtns = false;
            if (!this.isAgentChanged) {
                this.getAgentRecords();
            } else {
                this.getTempAgentRecords();
            }
            this.FirstReportName = false;
            this.addAgentPopupBtn = false;
            this.changeAgentName = false;
        } else if (this.isTempApis) {
            this.FirstReportName = true;
            this.addAgentPopupBtn = false;
            this.changeAgentName = false;
            this.clearAllFields();
            if (!this.showTempValue) {
                this.isFlowReport = true;
                this.getAgentRecords();
                this.firstAndAnnualFlowBtns = true;
                this.domesticForigenFlowBtns = false;
            } else {
                this.isFlowReport = true;
                this.getTempAgentRecords();
            }
        } else if (this.isAgentChange) {
            this.changeAgentName = true;
            this.FirstReportName = false;
            this.addAgentPopupBtn = false;
            if (this.isAgentChanged == false) {
                this.getAgentRecords();
            } else {
                this.getTempAgentRecords();
            }
        } else if (this.isAgentResignation) {
            this.getAgentRecords();
            this.isFlowReport = true;
        } else {
            this.getAgentRecords();
            this.domesticForigenFlowBtns = true;
            if(!this.getAgentDetailsData){
                this.agentRecord = false;
            }
        }
        if (!this.pageRef) {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
        }
        registerListener('flowvalidation', this.handleNotification, this);
    }
    handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid == true) {
            this.showAgentErrorMessage = false;
        }else {
            this.showAgentErrorMessage = true;
            if((this.isAnnualFlow || this.isFirstReportFlow ) && !this.checkBusinessLinkage()){
                this.errorText = this.label.business_linkage_error;
                return;
            }
            if((this.isFirstReportFlow || this.isAnnualFlow) && this.getAgentDetailsData && this.isAnyMandatoryFieldMissing()){
                this.errorText = this.label.Agent_Information_missing_message;
            } else{
                this.showErrorMessageByType();
            }            
        }
    }
    showErrorMessageByType() {
        if (this.isAgentChange) {
            this.errorText = this.label.BRS_Addagent_Change;
        } else if (this.isAddressChange) {
            this.errorText = this.label.address_error_message;
        } else {
            this.errorText = this.label.BRS_Addagent;
        }
    }
    handleAgentFirstName(event) {
        this.agentData.FirstName__c = event.target.value;
        this.AgentFirstName = this.agentData.FirstName__c;
    }
    handleAgentFirstNameBlur(event){
        const value = event.target.value.trim();
        this.agentData.FirstName__c = value;
        this.AgentFirstName = value;
    }
    handleAgentLastName(event) {
        this.agentData.LastName__c = event.target.value;
        this.AgentLastName = this.agentData.LastName__c;
    }
    handleAgentLastNameBlur(event){
        const value = event.target.value.trim();
        this.agentData.LastName__c = value;
        this.AgentLastName = value;
    }
    handlePhoneNumber(event) {
        this.agentData.Agent_Phone__c = event.target.value;
        this.AgentPhone = this.agentData.Agent_Phone__c;
    }
    handleEmail(event) {
        this.agentData.Email__c = event.target.value.trim().toLowerCase();
        this.AgentEmail = this.agentData.Email__c;
        if(this.AgentEmail === this.AgentConfirmEmail){
            this.checkConfirmEmail();
        }
    }
    onCopyPrincipalAddressCheck(event) {
        var accRecValue = JSON.parse(JSON.stringify(this.accountrecord));
        if (!this.copyPrincipalAddressCheck) {
            this.copyPrincipalAddressCheck = true;
            let Business_Street_Address_1__c, Business_Street_Address_2__c,Business_City__c,Business_State__c,Business_Zip_Code__c,Business_Country__c,Business_InternationalAddress__c;
            if(this.hasTempAddress){
                var accTempRecValue = JSON.parse(JSON.stringify(this.tempHistory));
                Business_Street_Address_1__c = accTempRecValue.BillingStreet_New__c ? accTempRecValue.BillingStreet_New__c :"";
                Business_Street_Address_2__c = accTempRecValue.Business_Unit__c ? accTempRecValue.Business_Unit__c :"";
                Business_City__c = accTempRecValue.Billing_City_New__c ? accTempRecValue.Billing_City_New__c :"";
                Business_State__c = accTempRecValue.BillingState_New__c ? accTempRecValue.BillingState_New__c :"";
                Business_Zip_Code__c = accTempRecValue.BillingPostalCode_New__c ? accTempRecValue.BillingPostalCode_New__c :"";
                Business_Country__c = accTempRecValue.Billing_Country_New__c ? accTempRecValue.Billing_Country_New__c :"";
                Business_InternationalAddress__c = accTempRecValue.Principle_Office_International_Address_N__c ? accTempRecValue.Principle_Office_International_Address_N__c :"";
            }else{
                Business_Street_Address_1__c = accRecValue.BillingStreet ? accRecValue.BillingStreet :"";
                Business_Street_Address_2__c = accRecValue.Billing_Unit__c ? accRecValue.Billing_Unit__c :"";
                Business_City__c = accRecValue.BillingCity ? accRecValue.BillingCity :"";
                Business_State__c = accRecValue.BillingState ? accRecValue.BillingState :"";
                Business_Zip_Code__c = accRecValue.BillingPostalCode ? accRecValue.BillingPostalCode :"";
                Business_Country__c = accRecValue.BillingCountry ? accRecValue.BillingCountry :"";
                Business_InternationalAddress__c = accRecValue.Principle_Office_International_Address__c ? accRecValue.Principle_Office_International_Address__c :"";
            }
            this.hidecheckbox = Business_State__c !== this.label.CT;
            this.agentData = {...this.initialData,Business_Street_Address_1__c,Business_Street_Address_2__c,Business_City__c,Business_State__c,Business_Zip_Code__c,Business_Country__c,Business_InternationalAddress__c}
        } else {
            this.copyPrincipalAddressCheck = false;
            this.agentData = {...this.initialData,Business_Street_Address_1__c:"",Business_Street_Address_2__c:"",Business_City__c:"",Business_State__c:"",Business_Zip_Code__c:"",Business_InternationalAddress__c:"",Business_Country__c:""}
        }
        this.setBusinessAddressFields();
    }
    setBusinessAddressFields() {
        this.businessAddressFields = {
            addressStreet: this.agentData.Business_Street_Address_1__c,
            addressUnit: this.agentData.Business_Street_Address_2__c,
            addressCity: this.agentData.Business_City__c,
            addressState: this.agentData.Business_State__c,
            addressZip: this.agentData.Business_Zip_Code__c,
            addressInternational: this.agentData.Business_InternationalAddress__c,
            addressCountry: this.agentData.Business_Country__c
        }
    };
    get isSameAsPrincipalChecked() {
        if (this.copyPrincipalAddressCheck) {
            return [this.label.Same_As_Principal_Address];
        }
        return "";
    }
    get isBusinessAddressChecked() {
        if (this.copyBusinessAddressCheck) {
            return [this.label.Same_As_Business_Address];
        }
        return "";
    }
    get isMailingChecked() {
        if (this.copyMailingAddressCheck) {
            return [this.label.Same_As_Business_Address];
        }
        return "";
    }
    onCopyBusinessAddressCheck(event) {
        var businessAddress = this.template.querySelector("c-brs_address.busniessAddress");
        var baddress = JSON.parse(JSON.stringify(businessAddress.getdata()));
        if (!this.copyBusinessAddressCheck) {
            this.copyBusinessAddressCheck = true;
            this.agentData = {
                ...this.initialData,
                Residence_Street_Address_1__c: baddress.street,
                Residence_Street_Address_2__c: baddress.unit ? baddress.unit : "",
                Residence_City__c: baddress.city,
                Residence_State__c: baddress.state,
                Residence_Zip_Code__c: baddress.zip
            }
        } else {
            this.copyBusinessAddressCheck = false;
            this.agentData = {
                ...this.initialData,
                Residence_Street_Address_1__c: "",
                Residence_Street_Address_2__c: "",
                Residence_City__c: "",
                Residence_Zip_Code__c: ""
            };
        }
        this.setResidenceAddressFields();
    }
    onCopyMailingAddressCheck(event) {
        var businessAddress = this.template.querySelector("c-brs_address.busniessAddress");
        var baddress = JSON.parse(JSON.stringify(businessAddress.getdata()));
        if (!this.copyMailingAddressCheck) {
            this.copyMailingAddressCheck = true;
            this.agentData = {
                ...this.initialData,
                Mailing_Street_Address_1__c: baddress.street,
                Mailing_Street_Address_2__c: baddress.unit ? baddress.unit : "",
                Mailing_City__c: baddress.city,
                Mailing_State__c: baddress.state,
                Mailing_Zip_Code__c: baddress.zip
            }
        } else {
            this.copyMailingAddressCheck = false;
            this.agentData = {
                ...this.initialData,
                Mailing_Street_Address_1__c: "",
                Mailing_Street_Address_2__c: "",
                Mailing_City__c: "",
                Mailing_Zip_Code__c: "",
                Mailing_State__c: baddress.state
            };
        }
        this.setMailingAddressFields();
    }
    setResidenceAddressFields() {
        this.residenceAddressFields = {
            addressStreet: this.agentData.Residence_Street_Address_1__c,
            addressUnit: this.agentData.Residence_Street_Address_2__c,
            addressCity: this.agentData.Residence_City__c,
            addressState: this.agentData.Residence_State__c,
            addressZip: this.agentData.Residence_Zip_Code__c
        }
    };
    setMailingAddressFields() {
        this.mailingAddressFields = {
            addressStreet: this.agentData.Mailing_Street_Address_1__c,
            addressUnit: this.agentData.Mailing_Street_Address_2__c,
            addressCity: this.agentData.Mailing_City__c,
            addressState: this.agentData.Mailing_State__c,
            addressZip: this.agentData.Mailing_Zip_Code__c
        }
    };
    handleConfirmEmail(event) {
        this.AgentConfirmEmail = event.target.value.trim().toLowerCase();
        this.checkConfirmEmail();
    }
    checkConfirmEmail() {
        let input = this.template.querySelector(
            "lightning-input[data-id=input-box2]"
        );
        if (this.AgentEmail.trim() === this.AgentConfirmEmail.trim()) {
            input.setCustomValidity("");
            input.reportValidity();
        } else {
            input.setCustomValidity(GenericInput_Email_Missmatch);
            input.reportValidity();
        }
    }
    removeCopyPaste(e) {
        e.preventDefault();
        return false;
    }
    handleAgentOptions(event) {
        this.selectedAgentOption = event.detail.value;
        if (this.selectedAgentOption == this.label.Agent_Individual_Option || this.selectedAgentOption == this.label.Agent_Business_Option || this.selectedAgentOption === this.label.Secretary_of_the_State_Comparable) {
            this.agentData.Type__c_Error = false;
        }
    }
    getAgentDetailsButton() {
        this.addAgentPopupBtn = false;
        this.changeAgentRecord = false;
        this.changegentMainPopup = false;
        this.modalOpenOrClose(false);
    }
    closeAddAgentMainPopup() {
        this.addAgentPopupBtn = true;
        this.addAgentMainPopup = false;
        this.modalOpenOrClose(false);
        this.addAgentData = false;
        this.addAgentDataIndividual = false;
        this.individualBusinessAddress = false;
        this.searchAgentResult = null;
        this.searchAgentBusiness = false;
        this.addBusinessAgentInfo = false;
        this.copyBusinessAddressCheck = false;
        this.copyMailingAddressCheck = false;
        this.copyPrincipalAddressCheck = false;
        this.addSecretaryState = false;
        this.showBackButton = true;
    }
    closeAddAgentMainPopupKeyPress(event){
        if (event.keyCode === 13 || event.keyCode == 32) {
            this.closeAddAgentMainPopup();
        }
    }
    handleAddAgentPopup() {
        this.agentData = {
            ...this.agentData,
            Type__c_Error: false
        }
        this.showPleaseNote = true;
        this.agentChanged = true;
        this.readonlyAgentDetails = false;
        this.addAgentPopupBtn = true;
        this.addAgentMainPopup = true;
        this.modalOpenOrClose(true);
        this.modalFocusTrap();
        this.addAgentData = true;
        this.addAgentDataIndividual = false;
        this.individualBusinessAddress = false;
        this.searchAgentBusiness = false;
        this.addBusinessAgentInfo = false;
        this.copyBusinessAddressCheck = false;
        this.copyMailingAddressCheck = false;
        this.copyPrincipalAddressCheck = false;
        this.agentId = "";
        this.clearAllFields();
        this.clearBusinessFields();
        this.label.Manual_Add_Individual_Agent = Manual_Add_Individual_Agent;
        this.label.Agent_fields_Mandatory = Agent_fields_Mandatory;   
        this.agentBusinessHeader = Agent_Business;
        this.label.Agent_fields_Mandatory = Agent_fields_Mandatory;
    }
    individualBusinessRadioValidation() {
        this.agentData = {
            ...this.initialData, Type__c_Error: !this.selectedAgentOption
        }
        return this.selectedAgentOption !== "";
    }
    redirectManualAddAgentDetails() {
        if (this.individualBusinessRadioValidation()) {
            if (this.selectedAgentOption == this.label.Agent_Individual_Option) {
                this.addAgentData = false;
                this.addAgentDataIndividual = true;
                this.searchAgentBusiness = false;
                this.addBusinessAgentInfo = false;
                this.editAddInfoBtn = false;
                this.editInfoDetails = false;
                this.hasTable(false);
            } else if (this.selectedAgentOption === this.label.Agent_Business_Option) {
                this.addAgentData = false;
                this.addAgentDataIndividual = false;
                this.searchAgentBusiness = true;
                this.addBusinessAgentInfo = false;
                this.editAddInfoBtn = false;
                this.editInfoDetails = false;
                this.agentBusinessHeader = this.label.Agent_Business;
                this.hasTable(true);
            } else if (this.selectedAgentOption === this.label.Secretary_of_the_State_Comparable) {
                this.addAgentData = false;
                this.addSecretaryState = true;
                this.showUpdateButton = false;
                this.addAgentDataIndividual = false;
                this.searchAgentBusiness = false;
                this.addBusinessAgentInfo = false;
                this.editAddInfoBtn = false;
                this.editInfoDetails = false;
                this.hasTable(false);
            }
            this.modalFocusTrap();
        }
    }
    goBackSecretaryState() {
        this.addAgentData = true;
        this.addAgentDataIndividual = false;
        this.individualBusinessAddress = false;
        this.editAddInfoBtn = false;
        this.editInfoDetails = false;
        this.addSecretaryState = false;
        this.modalFocusTrap();
    }
    goBackSearchAgentBusiness() {
        this.addAgentData = false;
        this.addAgentDataIndividual = false;
        this.searchAgentBusiness = true;
        this.addBusinessAgentInfo = false;
        this.editAddInfoBtn = false;
        this.editInfoDetails = false;
        this.agentBusinessHeader = this.label.Agent_Business;
        if(this.agentId){
            this.showBackButton = false;
        }
        this.modalFocusTrap();
    }
    addresschange(event) {
        var address = JSON.parse(JSON.stringify(event.detail));
        let isDisabled = true; 
        this.copyBusinessAddressCheck = false;
        this.copyMailingAddressCheck = false;
        if ((address.street && address.city && address.state && address.zip && (address.zip.length === 5 || address.zip.length === 10)) || (address.internationalAddress !== "" && address.country !== "")) {
            isDisabled = false;
        }
        if (address.state && address.state === this.label.CT) {
            this.hidecheckbox = true;
        } else if (address.countryFormat === ADD_Int_Addr_Label) {
            this.copyBusinessAddressCheck = false; 
            this.copyMailingAddressCheck = false;
            this.hidecheckbox = false;
        } else {
            this.hidecheckbox = false;
        }
        this.businessAddressCheckboxOptions = [{ ...this.businessAddressCheckboxOptions[0], isChecked: false, isDisabled }];
    }
    handleSearchBusiness(event) {
        this.selectedPrincipalAddressId = "";
        this.errorMessageForSearch = "";
        this.searchKey = event.detail;
    }
    handleGetResults(event) {
        this.principalList = event.detail;
    }
    goBackManualAgent() {
        this.addAgentData = true;
        this.addAgentDataIndividual = false;
        this.editAddInfoBtn = false;
        this.editInfoDetails = false;
        this.modalFocusTrap();
    }
    handleAgentDataIndividual() {
        let confirmEmail = this.template.querySelectorAll('.confirm-email-individual');
        let isInputsCorrect = [...this.template.querySelectorAll('.agent-inputs')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (confirmEmail && this.AgentFirstName && this.AgentLastName) {
            if (isInputsCorrect && this.AgentEmail === this.AgentConfirmEmail) {                
                this.isEditedAddressFields = false;
                this.name = this.AgentFirstName + " " + this.AgentLastName;
                this.phone = this.AgentPhone;
                this.email = this.AgentEmail;
                this.addAgentData = false;
                this.addAgentDataIndividual = false;
                this.individualBusinessAddress = true;
                this.showUpdateButton = false;
                this.errorMessage = "";
                this.showBackButton = true;
                if (this.agentId && !this.hasAddressChanged) {
                    this.setEditBusinessAddess(this.addAgentRecordData);
                    this.setEditResidenceAddess(this.addAgentRecordData);
                    this.setEditMailingAddess(this.addAgentRecordData);
                }
                this.modalFocusTrap();
            } else if (this.AgentConfirmEmail === "") {
                confirmEmail[0].setCustomValidity(Generic_Input_Error_Message);
                confirmEmail[0].reportValidity();
            } else if (this.AgentConfirmEmail !== this.AgentEmail) {
                confirmEmail[0].setCustomValidity(GenericInput_Email_Missmatch);
                confirmEmail[0].reportValidity();
            } else {
                confirmEmail[0].setCustomValidity("");
                confirmEmail[0].reportValidity();
            }
        }
    }
    handleSearchAgentBusiness() {
        if (this.selectedPrincipalAddressId && this.selectedPrincipalAddressId.Id != this.accountId) {
            this.businessIdValue = this.principal.Business_ID__r;
            this.searchAgentResult = {
                ...this.principal,
                Business_address__c: this.getFullBusinessAddress(this.principal, true),
                Mailing_address__c: this.getFullMailingAddress(this.principal)
            }
            this.businessErrorValidation = "";
            this.addAgentData = false;
            this.addAgentDataIndividual = false;
            this.searchAgentBusiness = false;
            this.addBusinessAgentInfo = true;
            this.showUpdateButton = false;
            this.editAddInfoBtn = true;
            if(this.showAddressFormWhenAnyFieldMiss){
                this.editInfoDetails = true;
                this.handleClickeventForEditInfo();
            }else{
                this.editInfoDetails = false;
            }
            this.errorMessageForSearch = "";
            this.showBackButton = true;
            this.modalFocusTrap();
        } else {
            this.errorMessageForSearch = (this.selectedPrincipalAddressId?.Id == this.accountId)? this.label.Same_Agent_Business_Error: this.label.Business_Search_Error_Validation;
            this.addAgentData = false;
            this.addAgentDataIndividual = false;
            this.searchAgentBusiness = true;
            this.addBusinessAgentInfo = false;
            this.editAddInfoBtn = true;
            this.editInfoDetails = false;
        }
    }
    onPrincipalListRadioCheck(event) {
        var selected = event.detail;
        this.selectedRadio = selected.Id;
        this.errorMessageForSearch = "";
        const BillingStreet = selected.BillingStreet ? selected.BillingStreet : "";
        const BillingCity = selected.BillingCity ? selected.BillingCity : "";
        const BillingState = selected.BillingState ? selected.BillingState : "";
        const BillingPostalCode = selected.BillingPostalCode ? selected.BillingPostalCode : "";
        const BillingCountry = selected.BillingCountry ? selected.BillingCountry : "";
        const ShippingStreet = selected.ShippingStreet ? selected.ShippingStreet : "";
        const ShippingCity = selected.ShippingCity ? selected.ShippingCity : "";
        const ShippingState = selected.ShippingState ? selected.ShippingState : "";
        const ShippingPostalCode = selected.ShippingPostalCode ? selected.ShippingPostalCode : "";
        const ShippingCountry = selected.ShippingCountry ? selected.ShippingCountry : "";
        let hasAllFields = !(BillingStreet && BillingCity && BillingState && BillingPostalCode);
        if(this.showMailingAddress && !hasAllFields){
            hasAllFields = !(ShippingStreet && ShippingCity && ShippingState && ShippingPostalCode);
        }
        this.showAddressFormWhenAnyFieldMiss = hasAllFields;        
        this.selectedPrincipalAddressId = {
            ...selected,
            Name__c: selected.Name,
            Type__c: this.selectedAgentOption,
            Business_ID__r: selected.AccountNumber,
            Business_ID__c: selected.Id,
            Business_Street_Address_1__c: BillingStreet,
            Business_City__c: BillingCity,
            Business_Street_Address_2__c: selected.Billing_Unit__c ? selected.Billing_Unit__c :"",
            Business_State__c: BillingState,
            Business_Zip_Code__c: BillingPostalCode,
            Business_Country__c: BillingCountry,
            Business_InternationalAddress__c: selected.Principle_Office_International_Address__c ? selected.Principle_Office_International_Address__c :"",
        };
        if(this.showMailingAddress){
            this.selectedPrincipalAddressId = {
                ...this.selectedPrincipalAddressId,
                Mailing_City__c: ShippingCity,
                Mailing_State__c: ShippingState,
                Mailing_Street_Address_1__c: ShippingStreet,
                Mailing_Street_Address_2__c: selected.Shipping_Unit__c ? selected.Shipping_Unit__c :"",
                Mailing_Zip_Code__c: ShippingPostalCode,
                Mailing_Country__c: ShippingCountry,
                Mailing_International_Address__c: selected.Mailing_International_Address__c ? selected.Mailing_International_Address__c:""
            }
        }
        this.principal = {
            ...this.selectedPrincipalAddressId,
            Business_Address__c: selected.Business_Address_1__c,
            Mailing_Address__c: this.showMailingAddress ? selected.Mailing_Address_1__c : ""
        };
    }
    goBackaddAgentDataIndividual() {
        this.addAgentData = true;
        this.addAgentDataIndividual = false;
        this.searchAgentBusiness = false;
        this.addBusinessAgentInfo = false;
        this.editAddInfoBtn = false;
        this.editInfoDetails = false;
        this.hasTable(false);
        this.modalFocusTrap();
    }
    goBackAgentIndividual() {
        this.addAgentData = false;
        this.addAgentDataIndividual = true;
        this.individualBusinessAddress = false;
        this.editAddInfoBtn = false;
        this.editInfoDetails = false;
        if(this.agentId){
            this.showBackButton = false;
        }
        var businessAddress = this.template.querySelector("c-brs_address.busniessAddress");
        var resAddress = this.template.querySelector("c-brs_address.residentialAddress");
        var baddress = JSON.parse(JSON.stringify(businessAddress.getdata()));
        var raddress = JSON.parse(JSON.stringify(resAddress.getdata()));
        this.businessAddressFields ={
            addressStreet: baddress.street,
            addressUnit: baddress.unit,
            addressCity: baddress.city,
            addressState: baddress.state,
            addressZip: baddress.zip,
            addressInternational: baddress.internationalAddress,
            addressCountry: baddress.country
        }
        this.residenceAddressFields = {
            addressStreet: raddress.street,
            addressUnit: raddress.unit,
            addressCity: raddress.city,
            addressState: raddress.state,
            addressZip: raddress.zip,
            addressCountry: raddress.country
        }
        if(this.showMailingAddress){            
            var mailAddress = this.template.querySelector("c-brs_address.mailingAddress");           
            var mladdress = JSON.parse(JSON.stringify(mailAddress.getdata()));
            this.mailingAddressFields = {
                addressStreet: mladdress.street,
                addressUnit: mladdress.unit,
                addressCity: mladdress.city,
                addressState: mladdress.state,
                addressZip: mladdress.zip,
                addressCountry: mladdress.country
            }
        }        
        this.hasAddressChanged = true;
        this.modalFocusTrap();
    }
    handleIndividualAgent() {
        if (this.hasAllAddressFields()) {
            this.isLoading = true;
            var agent;
            let phoneNumber = this.AgentPhone.split("-").join("");
            if (this.isTempApis || this.isAgentChange) {
                agent = {
                    FirstName__c: this.AgentFirstName,
                    LastName__c: this.AgentLastName,
                    Type__c: 'Agent',
                    Name__c: this.AgentFirstName + " " + this.AgentLastName,
                    Email__c: this.AgentEmail,
                    Phone__c: phoneNumber,
                    Business_ID__c: this.accountId,
                    Account__c: null
                }
            }
            else {
                agent = {
                    FirstName__c: this.AgentFirstName,
                    LastName__c: this.AgentLastName,
                    Type__c: this.selectedAgentOption,
                    Name__c: this.AgentFirstName + " " + this.AgentLastName,
                    Email__c: this.AgentEmail,
                    Agent_Phone__c: phoneNumber,
                    Agent_Account_ID__c: null,	
                    Business_ID__c: this.accountId,
                }
            }
            var businessAddress = this.template.querySelector("c-brs_address.busniessAddress");
            var resAddress = this.template.querySelector("c-brs_address.residentialAddress");
            var baddress = JSON.parse(JSON.stringify(businessAddress.getdata()));
            var raddress = JSON.parse(JSON.stringify(resAddress.getdata()));
            if (businessAddress) {
                agent = {
                    ...agent,
                    Business_City__c: baddress.city,
                    Business_Street_Address_1__c: baddress.street,
                    Business_Street_Address_2__c: baddress.unit ? baddress.unit : "",
                    Business_Zip_Code__c: baddress.zip,
                    Business_State__c: baddress.state,
                    Business_Country__c: baddress.country,
                    Business_InternationalAddress__c: baddress.internationalAddress
                }
            }
            if (resAddress) {
                agent = {
                    ...agent,
                    Residence_City__c: raddress.city,
                    Residence_Street_Address_1__c: raddress.street,
                    Residence_Street_Address_2__c: raddress.unit ? raddress.unit : "",
                    Residence_Zip_Code__c: raddress.zip,
                    Residence_State__c: raddress.state,
                    Residence_Country__c: raddress.state ? this.label.United_States : "",
                }
            }
            if (this.showMailingAddress) {
                var mailAddress = this.template.querySelector("c-brs_address.mailingAddress");
                var mladdress = JSON.parse(JSON.stringify(mailAddress.getdata()));
                if (mailAddress) {
                    agent = {
                        ...agent,
                        Mailing_City__c: mladdress.city,
                        Mailing_Street_Address_1__c: mladdress.street,
                        Mailing_Street_Address_2__c: mladdress.unit ? mladdress.unit : "",
                        Mailing_Zip_Code__c: mladdress.zip,
                        Mailing_State__c: mladdress.state,
                        Mailing_Country__c: mladdress.state ? this.label.United_States : "",
                    }
                }
            }
            if (this.agentId) {
                let hasMailingNotChanged = true;
                if (this.showMailingAddress && (this.isTempApis || this.isAddressChange)) {
                    let unit = this.getAgentDetailsData.Mailing_Street_Address_2__c ? this.getAgentDetailsData.Mailing_Street_Address_2__c :"";
                    hasMailingNotChanged = (mladdress.city === this.getAgentDetailsData.Mailing_City__c
                        && mladdress.state === this.getAgentDetailsData.Mailing_State__c && mladdress.zip === this.getAgentDetailsData.Mailing_Zip_Code__c && mladdress.street === this.getAgentDetailsData.Mailing_Street_Address_1__c
                        && mladdress.unit === unit);
                }
                const businessUnit = this.getAgentDetailsData.Business_Street_Address_2__c ? this.getAgentDetailsData.Business_Street_Address_2__c : "";                
                const businessCity = this.getAgentDetailsData.Business_City__c ? this.getAgentDetailsData.Business_City__c :"";
                const businessState = this.getAgentDetailsData.Business_State__c ? this.getAgentDetailsData.Business_State__c : "";
                const businessZip = this.getAgentDetailsData.Business_Zip_Code__c ? this.getAgentDetailsData.Business_Zip_Code__c : "";
                const businessStreet = this.getAgentDetailsData.Business_Street_Address_1__c ? this.getAgentDetailsData.Business_Street_Address_1__c :"";
                const businessCountry = this.getAgentDetailsData.Business_Country__c ? this.getAgentDetailsData.Business_Country__c : "";
                const businessInternational = this.getAgentDetailsData.Business_InternationalAddress__c ? this.getAgentDetailsData.Business_InternationalAddress__c : "";
                const residenceUnit = this.getAgentDetailsData.Residence_Street_Address_2__c ? this.getAgentDetailsData.Residence_Street_Address_2__c : "";
                const residenceCity = this.getAgentDetailsData.Residence_City__c ? this.getAgentDetailsData.Residence_City__c :"";
                const residenceState = this.getAgentDetailsData.Residence_State__c ? this.getAgentDetailsData.Residence_State__c : "";
                const residenceZip = this.getAgentDetailsData.Residence_Zip_Code__c ? this.getAgentDetailsData.Residence_Zip_Code__c : "";
                const residenceStreet = this.getAgentDetailsData.Residence_Street_Address_1__c ? this.getAgentDetailsData.Residence_Street_Address_1__c :"";              
                if ((this.isTempApis || this.isAddressChange) && this.agentId && this.AgentFirstName === this.addAgentRecordData.FirstName__c && this.AgentLastName === this.addAgentRecordData.LastName__c
                && this.AgentEmail === this.addAgentRecordData.Email__c && (phoneNumber === this.addAgentRecordData.Agent_Phone__n || this.AgentPhone === this.addAgentRecordData.Agent_Phone__n) && baddress.internationalAddress === businessInternational && baddress.country.toLowerCase() === businessCountry.toLowerCase() && 
                baddress.unit === businessUnit && baddress.city === businessCity && baddress.state ===  businessState && baddress.zip === businessZip && baddress.street === businessStreet && 
                raddress.city === residenceCity && raddress.unit === residenceUnit && raddress.state === residenceState && raddress.zip === residenceZip && raddress.street === residenceStreet && hasMailingNotChanged) {
                    this.isLoading = false;
                    this.isEditedAddressFields = true;
                } else {
                    this.isEditedAddressFields = false;
                    if (this.isTempApis && this.editTempRecord === false) {
                        agent = {
                            ...agent,
                            Temp_Type__c: this.label.Agent_Individual_Option,
                            Phone__c: phoneNumber,
                            Change_Type__c: "Edited",
                            Agent__c: this.originalAgentId,
                            Business_Filing__c: this.filingId
                        }
                        this.updateAgentIndividualBusinessRecord(agent);
                    } else if (this.editTempRecord === true && this.isTempApis) {
                        agent = {
                            ...agent,
                            Temp_Type__c: this.label.Agent_Individual_Option,
                            Phone__c: phoneNumber,
                            Id: this.agentId
                        }
                        this.updateAgentIndividualBusinessRecord(agent);
                    } else if (this.isAgentChange) {
                        agent = {
                            ...agent,
                            Temp_Type__c: this.label.Agent_Individual_Option,
                            Phone__c: phoneNumber,
                            Id: this.agentId
                        }
                        this.updateAgentIndividualBusinessRecord(agent);
                    } else if (this.isAddressChange === true && this.editTempRecord === false) {
                        agent = {
                            ...agent,
                            Temp_Type__c: this.label.Agent_Individual_Option,
                            Type__c: "Agent",
                            Phone__c: phoneNumber,
                            Agent__c: this.agentId,
                            Business_Filing__c: this.filingId,
                            Change_Type__c: "Edited"
                        }
                        this.updateAgentIndividualBusinessRecord(agent);
                    } else if (this.isAddressChange === true && this.editTempRecord === true) {
                        agent = {
                            ...agent,
                            Temp_Type__c: this.label.Agent_Individual_Option,
                            Phone__c: phoneNumber,
                            Id: this.agentId
                        }
                        this.updateAgentIndividualBusinessRecord(agent);
                    } else {
                        agent = {
                            ...agent,
                            Id: this.agentId
                        }
                        this.updateAgentIndividualBusinessRecord(agent);
                    }
                }
            } else {
                if (this.isTempApis) {
                    agent = {
                        ...agent,
                        Temp_Type__c: this.selectedAgentOption,
                        Business_Filing__c: this.filingId,
                        Change_Type__c: "Created",
                    }
                    this.insertAgentIndividualBusinessRecord(agent,true);
                } else if (this.isAgentChange) {
                    agent = {
                        ...agent,
                        Temp_Type__c: this.selectedAgentOption,
                        Business_Filing__c: this.filingId,
                        Change_Type__c: "Created",
                    }
                    this.insertAgentIndividualBusinessRecord(agent,true);                    
                } else {
                    this.insertAgentIndividualBusinessRecord(agent);
                }
            }
            var accRecValue = JSON.parse(JSON.stringify(this.accountrecord));
            this.accountrecord = Object.assign({}, accRecValue);
        }
    }
    createOriginalDeleteTempRecord(){
        if(this.originalAgentId){
            let originalAgent = {
                Account__c: this.accountId,
                Change_Type__c: 'Deleted',
                Business_ID__c: this.accountId,
                Type__c: 'Agent',
                Business_Filing__c: this.filingId,
                Agent__c: this.originalAgentId
            }
            this.createTempAgentOriginalRecord(originalAgent);
        }
    }
    insertAgentIndividualBusinessRecord(agent,deleteOriginal) {
        this.isLoading = true;
        if (this.isTempApis || this.isAgentChange) {
            upsertTempRecord({ tempRec: agent }).then((data) => {
                if(deleteOriginal){
                    this.createOriginalDeleteTempRecord();
                }
                this.selectedPrincipalAddressId = "";
                this.isLoading = false;
                this.getAgentDetailsData = data;
                this.agentChanged = true;
                this.setAgentCardDetails(this.getAgentDetailsData);
                this.isAgentChangeFlow = true;
                this.showTempValue = true;
                this.editTempRecord = true;
                this.isAgentChanged = true;
                this.changeAgentName = false;
                this.FirstReportName = false;
                this.checkAgentChanged = true;
                this.secretaryRecord = false;
                this.closeAddAgentMainPopup();
                this.getAgentDetailsButton();
                this.showAgentErrorMessage = false;
                this.AgentChangeError = false;
            }).catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(this.compName, "insertAgentIndividualBusinessRecord", "", "", "Medium", error.message);
            })
        } else {
            insertAgentRecord({ agentRec: agent }).then((data) => {
                this.selectedPrincipalAddressId = "";
                this.isLoading = false;
                this.getAgentDetailsData = data;
                this.setAgentCardDetails(this.getAgentDetailsData);
                this.closeAddAgentMainPopup();
                this.getAgentDetailsButton();
                this.showAgentErrorMessage = false;
                this.AgentChangeError = false;
            }).catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(this.compName, "insertAgentIndividualBusinessRecord", "", "", "Medium", error.message);
            })
        }
    }
    updateAgentIndividualBusinessRecord(agent) {
        this.isLoading = true;
        if (this.isTempApis || this.isAgentChange) {
            upsertTempRecord({ tempRec: agent }).then((data) => {
                this.selectedPrincipalAddressId = "";
                this.isLoading = false;
                this.FirstReportName = false;
                this.showTempValue = true;
                this.isAgentChanged = true;
                this.isAgentChangeFlow = true;
                this.checkAgentChanged = true;
                this.changeAgentName = false;
                this.getAgentDetailsData = data;
                this.editTempRecord = true;
                this.secretaryRecord = false;
                this.fetchAndEditAgentCardDetails(this.getAgentDetailsData);
                this.closeAddAgentMainPopup();
                this.getAgentDetailsButton();
                this.showAgentErrorMessage = false;
                this.AgentChangeError = false;
            }).catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(this.compName, "updateAgentIndividualBusinessRecord", "", "", "Medium", error.message);
            })
        } else if (this.isAddressChange === true) {
            upsertTempRecord({ tempRec: agent }).then((data) => {
                this.selectedPrincipalAddressId = "";
                this.isLoading = false;
                this.getAgentDetailsData = data;
                this.isAgentChanged = true;
                this.editTempRecord = true;
                this.showTempValue = true;
                this.checkAgentChanged = true;
                this.isAgentChangeFlow = true;
                this.showAgentErrorMessage = false;
                this.fetchAndEditAgentCardDetails(this.getAgentDetailsData);
                this.closeAddAgentMainPopup();
                this.getAgentDetailsButton();
            }).catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(this.compName, "updateAgentIndividualBusinessRecord", "", "", "Medium", error.message);
            })
        } else {
            updateAgentRecord({ AgentRec: agent }).then((data) => {
                this.selectedPrincipalAddressId = "";
                this.isLoading = false;
                this.getAgentDetailsData = data;
                this.fetchAndEditAgentCardDetails(this.getAgentDetailsData);
                this.closeAddAgentMainPopup();
                this.getAgentDetailsButton();
            }).catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(this.compName, "updateAgentIndividualBusinessRecord", "", "", "Medium", error.message);
            })
        }
    }
    setAgentCardDetails(data) {
        this.selectedAgentOption = data.Type__c;
        this.agentId = data.Id;
        let formatedPhNumber;
        if (this.isTempApis || this.isAgentChange) {
            formatedPhNumber = data.Phone__c;
            this.firstAndAnnualFlowBtns = false;
            this.domesticForigenFlowBtns = true;
        } else {
            formatedPhNumber = data.Agent_Phone__c;
            this.firstAndAnnualFlowBtns = false;
            this.domesticForigenFlowBtns = true;
        }
        formatedPhNumber = this.formatPhoneNumber(formatedPhNumber);
        this.addAgentRecordData = {
            ...data,
            Agent_Phone__n: formatedPhNumber,
            Business_Address__c: this.getFullBusinessAddress(data),
            Residence_Address__c: this.getFullResidenceAddress(data),
            Mailing_Address__c: this.getFullMailingAddress(data),
            Mailing_Address__div: this.showMailingAddress,
        }
        if (data.Type__c === this.label.Agent_Individual_Option || data.Temp_Type__c === this.label.Agent_Individual_Option) {
            this.addAgentRecordData = {
                ...this.addAgentRecordData,
                isIndividual: true,
                showBusinessId: false,
                Residence_Street__div: true,
                businessId: ""
            }
        } else if (data.Type__c === this.label.Secretary_of_the_State_Comparable || data.Temp_Type__c === this.label.Secretary_of_the_State_Comparable) {
            this.secretaryRecord = true;
            this.agentRecord = false;
            this.changeAgentRecord = false;
        } else {
            this.addAgentRecordData = {
                ...this.addAgentRecordData,
                isIndividual: false,
                Residence_Street__div: false,
                showBusinessId: true,
                businessId: this.principal.Business_ID__r
            }
            this.searchAgentResult = {
                Business_ID__r: this.addAgentRecordData.businessId,
                Name__c: this.getAgentDetailsData.Name__c,
                Business_address__c: this.getFullBusinessAddress(this.getAgentDetailsData, true),
                Mailing_address__c: this.getFullMailingAddress(this.getAgentDetailsData)
            }
            this.getAgentDetailsData = {
                ...this.getAgentDetailsData,
                ...this.searchAgentResult,
                ...this.addAgentRecordData
            }
        }
        this.agentRecord = true;
    }
    fetchAndEditAgentCardDetails(data) {
        this.agentId = data.Id;
        var formatedPhNumber,businessId;
        if (this.isTempApis || this.isAgentChange || this.isAddressChange) {
            var AccountId = Object.assign({}, data.Account__r);           
            if (AccountId.AccountNumber != undefined) {businessId = AccountId.AccountNumber} else { businessId = this.editBusinessId }
        }
        if (this.isTempApis || this.isAgentChange) {           
            formatedPhNumber = data.Phone__c;
            this.firstAndAnnualFlowBtns = false;
            this.domesticForigenFlowBtns = true;
        } else if (this.isAddressChange === true) {
            this.firstAndAnnualFlowBtns = true;
            this.domesticForigenFlowBtns = false;
            formatedPhNumber = data.Phone__c;
        } else if (this.isAgentResignation) {
            this.changeAgentName = false;
            this.FirstReportName = false;
            this.addAgentPopupBtn = false;
            formatedPhNumber = data.Agent_Phone__c;
            this.firstAndAnnualFlowBtns = false;
            this.domesticForigenFlowBtns = false;
        } else {
            if ((data.Type__c === this.label.Agent_Individual_Option || data.Temp_Type__c === this.label.Agent_Individual_Option) ||
                data.Type__c === this.label.Agent_Business_Option || data.Temp_Type__c === this.label.Agent_Business_Option) {
                if (data.Business_ID__r != undefined) {
                    businessId = data.Business_ID__r
                } else {
                    businessId = this.editBusinessId
                }
                formatedPhNumber = data.Agent_Phone__c;
                this.firstAndAnnualFlowBtns = false;
                this.domesticForigenFlowBtns = true;
            }
        }
        formatedPhNumber = this.formatPhoneNumber(formatedPhNumber);
        if (data.Type__c === this.label.Agent_Individual_Option || data.Temp_Type__c === this.label.Agent_Individual_Option) {
            this.addAgentRecordData = {
                ...this.getAgentDetailsData,
                Agent_Phone__n: formatedPhNumber,
                Business_Address__c: this.getFullBusinessAddress(data),
                Residence_Address__c: this.getFullResidenceAddress(data),
                Mailing_Address__c: this.getFullMailingAddress(data),
                Mailing_Address__div: this.showMailingAddress,
                Residence_Street__div: true,
                showBusinessId: false,
                isIndividual: true,
                Temp_Type__c: this.label.Agent_Individual_Option
            }
        } else if (data.Type__c === this.label.Agent_Business_Option || data.Temp_Type__c === this.label.Agent_Business_Option) {
            this.searchAgentResult = {
                Business_ID__r: this.editBusinessId,
                Name__c: data.Name__c,
                Business_address__c: this.getFullBusinessAddress(data,true),
                Mailing_address__c: this.getFullMailingAddress(data)
            }
            this.addAgentRecordData = {
                ...this.getAgentDetailsData,
                Agent_Phone__n: formatedPhNumber,
                Business_Address__c: this.getFullBusinessAddress(data),
                Residence_Address__c: this.getFullResidenceAddress(data),
                Mailing_Address__c: this.getFullMailingAddress(data),
                businessId: businessId,
                Mailing_Address__div: this.showMailingAddress,
                Residence_Street__div: false,
                showBusinessId: true,
                Temp_Type__c: this.label.Agent_Business_Option
            }
            this.getAgentDetailsData = {
                ...this.getAgentDetailsData,
                ...this.searchAgentResult,
                ...this.addAgentRecordData
            }
        } else if (data.Type__c === this.label.Secretary_of_the_State_Comparable || data.Temp_Type__c === this.label.Secretary_of_the_State_Comparable) {
            this.secretaryRecord = true;
            this.agentRecord = false;
            this.changeAgentRecord = false;
        }
        this.agentRecord = true;
    }
    handleChangeAgentInfoEmailAddress(event) {
        this.businessErrorValidation = false;
        this.agentBusinessEmailAddress = event.target.value.trim().toLowerCase();
        if(this.agentBusinessEmailAddress === this.agentBusinessConfirmEmailAddress){
            this.checkConfirmEmailBusiness();
        }
    }
    handleChangeConfirmEmailAddress(event) {
        this.agentBusinessConfirmEmailAddress = event.target.value.trim().toLowerCase();;
        this.checkConfirmEmailBusiness();
    }
    checkConfirmEmailBusiness() {
        let input = this.template.querySelector("lightning-input[data-id=input-box3]");
        if (this.agentBusinessEmailAddress === this.agentBusinessConfirmEmailAddress) {
            input.setCustomValidity("");
            input.reportValidity();
        } else {
            input.setCustomValidity(GenericInput_Email_Missmatch);
            input.reportValidity();
        }
    }
    handleChangePhoneNumber(event) {
        this.agentBusinessPhoneNumber = event.target.value;
    }
    hasAllAddressFields() {
        const resAddress = this.template.querySelector("c-brs_address.residentialAddress");
        const validResAddress = resAddress.validateaddress();
        var businessAddress = this.template.querySelector("c-brs_address.busniessAddress"); 
        const validBusAddress = businessAddress.validateaddress();
        if (this.showMailingAddress) {
            const mailAddress = this.template.querySelector("c-brs_address.mailingAddress");
            const validMailAddress = mailAddress.validateaddress();
            return validResAddress && validMailAddress && validBusAddress;
        } else {
            return validResAddress && validBusAddress;
        }
    }
    hasEditAddressValidate() {
        const editBusinessAddress = this.template.querySelector("c-brs_address.editBusinessAddress");
        const editMailingAddress = this.template.querySelector("c-brs_address.editMailingAddress");
        let addressValid = true;
        let emailsValid = true;
        let isBusinessLinked = true;
        if (this.showMailingAddress === true) {
            if (editBusinessAddress && editMailingAddress) {
                const baddress = JSON.parse(JSON.stringify(editBusinessAddress.getdata()));
                const maddress = JSON.parse(JSON.stringify(editMailingAddress.getdata()));
                const bError = editBusinessAddress.validateaddress();
                const mError = editMailingAddress.validateaddress();
                addressValid = (bError && mError && baddress.city !== "" && baddress.street !== "" && baddress.zip !== "" && baddress.state !== ""
                    && maddress.city !== "" && maddress.street !== "" && maddress.zip !== "" && maddress.state !== "")
            }
        } else {
            if (editBusinessAddress) {
                const baddress = JSON.parse(JSON.stringify(editBusinessAddress.getdata()));
                const bError = editBusinessAddress.validateaddress();
                addressValid = (bError && baddress.city !== "" && baddress.street !== "" && baddress.zip !== "" && baddress.state !== "")
            }
        }
        if(!this.isAddressChange){
            let confirmEmail = this.template.querySelectorAll('.confirm-business-email');
            if (this.agentBusinessConfirmEmailAddress === "") {
                confirmEmail[0].setCustomValidity(Generic_Input_Error_Message);
                confirmEmail[0].reportValidity();
                emailsValid = false;
            } else if(this.agentBusinessEmailAddress !== this.agentBusinessConfirmEmailAddress){
                confirmEmail[0].setCustomValidity(GenericInput_Email_Missmatch);
                confirmEmail[0].reportValidity();
                emailsValid = false;
            } else{
                confirmEmail[0].setCustomValidity("");
                confirmEmail[0].reportValidity();
            }
        }
        let addressChanged = true;
        if((this.isAnnualFlow || this.isFirstReportFlow ) && !this.checkBusinessLinkage()){
            isBusinessLinked = false;
            this.businessErrorValidation = this.label.business_linkage_edit_error;
        }
        if((this.isAddressChange || this.isTempApis) && this.agentId && isBusinessLinked){
            addressChanged = this.isBusinessAddressChanged();
        }
        return addressValid && emailsValid && addressChanged && isBusinessLinked;
    }

    isBusinessAddressChanged() {
        let businessAddressChanged = false;
        let mailingAddressChanged = false;
        let mailOrMobileChanged = false;
        let mainlingNotInCT = false;
        let businessNotInCT = false;
        this.businessErrorValidation = "";
        if (this.editInfoDetails) {
                let editbusinessAddress = this.template.querySelector('c-brs_address.editBusinessAddress');                
                let baddress = JSON.parse(JSON.stringify(editbusinessAddress.getdata()));               
                const businessStreet = this.getAgentDetailsData.Business_Street_Address_1__c ? this.getAgentDetailsData.Business_Street_Address_1__c : "";
                const businessUnit = this.getAgentDetailsData.Business_Street_Address_2__c ? this.getAgentDetailsData.Business_Street_Address_2__c : "";
                const businessCity = this.getAgentDetailsData.Business_City__c ? this.getAgentDetailsData.Business_City__c : "";
                const businessState = this.getAgentDetailsData.Business_State__c ? this.getAgentDetailsData.Business_State__c : "";
                const businessZip = this.getAgentDetailsData.Business_Zip_Code__c ? this.getAgentDetailsData.Business_Zip_Code__c : "";
                const businessCountry = this.getAgentDetailsData.Business_Country__c ? this.getAgentDetailsData.Business_Country__c : "";
                businessAddressChanged = !(baddress.street === businessStreet && baddress.unit === businessUnit && baddress.city === businessCity
                    && baddress.state === businessState && baddress.zip === businessZip && baddress.country === businessCountry);
            if(this.showMailingAddress){
                let editMailingAddress = this.template.querySelector('c-brs_address.editMailingAddress');
                let maddress = JSON.parse(JSON.stringify(editMailingAddress.getdata()));
                const mailingStreet = this.getAgentDetailsData.Mailing_Street_Address_1__c ? this.getAgentDetailsData.Mailing_Street_Address_1__c : "";
                const mailingUnit = this.getAgentDetailsData.Mailing_Street_Address_2__c ? this.getAgentDetailsData.Mailing_Street_Address_2__c : "";
                const mailingCity = this.getAgentDetailsData.Mailing_City__c ? this.getAgentDetailsData.Mailing_City__c : "";
                const mailingState = this.getAgentDetailsData.Mailing_State__c ? this.getAgentDetailsData.Mailing_State__c : "";
                const mailingZip = this.getAgentDetailsData.Mailing_Zip_Code__c ? this.getAgentDetailsData.Mailing_Zip_Code__c : "";
                const mailingCountry = this.getAgentDetailsData.Mailing_Country__c ? this.getAgentDetailsData.Mailing_Country__c : "";
                mailingAddressChanged = !(maddress.street === mailingStreet && maddress.unit === mailingUnit && maddress.city === mailingCity
                   && maddress.state === mailingState && maddress.zip === mailingZip && maddress.country === mailingCountry);
            }               
        } else{
            businessNotInCT =  this.getAgentDetailsData.Business_State__c !== this.label.CT;
            if(this.showMailingAddress){
                mainlingNotInCT =this.getAgentDetailsData.Mailing_State__c  !== this.label.CT;
            }
        }
        if (!this.isAddressChange) {
            mailOrMobileChanged = !(this.agentBusinessEmailAddress === this.addAgentRecordData.Email__c && this.agentBusinessPhoneNumber === this.addAgentRecordData.Agent_Phone__n);
        }
        if(businessNotInCT || mainlingNotInCT){
            this.businessErrorValidation = this.label.Business_Error_Validation;
        }else if ((!businessAddressChanged || !mailingAddressChanged) && !mailOrMobileChanged) {
            this.businessErrorValidation = this.label.address_error_message;
        }
        return (businessAddressChanged || mailingAddressChanged || mailOrMobileChanged) && (!(businessNotInCT || mainlingNotInCT));
    }
    handleBusinessAgentInfo() {
        let isInputsCorrect = [...this.template.querySelectorAll('.business-inputs')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        var agentInfo;
        if (this.selectedPrincipalAddressId) {
            let phoneNumber = this.agentBusinessPhoneNumber.split("-").join("");
            if (this.isTempApis || this.isAgentChange) {
                agentInfo = {
                    Name__c: this.principal.Name__c,
                    Email__c: this.agentBusinessEmailAddress,
                    Phone__c: phoneNumber,
                    Account__c: this.selectedAgentOption === this.label.Agent_Business_Option ? this.principal.Business_ID__c : null,
                    Type__c: 'Agent',
                    Business_ID__c: this.accountId
                }
            }
            else {
                agentInfo = {
                    Name__c: this.principal.Name__c,
                    Business_ID__c: this.accountId,
                    Email__c: this.agentBusinessEmailAddress,
                    Agent_Phone__c: phoneNumber,
                    Agent_Account_ID__c: this.principal.Business_ID__c == this.accountId ? this.principal.Agent_Account_ID__c:this.principal.Business_ID__c,
                    Type__c: this.principal.Type__c,
                }
            }
            if (this.hasEditAddressValidate() && isInputsCorrect) {
                if (this.editInfoDetails) {
                    let editbusinessAddress = this.template.querySelector('c-brs_address.editBusinessAddress');
                    let editMailingAddress = this.template.querySelector('c-brs_address.editMailingAddress');
                    if (editbusinessAddress) {
                        var baddress = JSON.parse(JSON.stringify(editbusinessAddress.getdata()));
                        agentInfo = {
                            ...agentInfo,
                            Business_Street_Address_1__c: baddress.street,
                            Business_Street_Address_2__c: baddress.unit,
                            Business_City__c: baddress.city,
                            Business_State__c: baddress.state,
                            Business_Zip_Code__c: baddress.zip,
                            Business_Country__c: this.label.United_States,
                        };
                    }
                    if (editMailingAddress) {
                        var maddress = JSON.parse(JSON.stringify(editMailingAddress.getdata()));
                        agentInfo = {
                            ...agentInfo,
                            Mailing_Street_Address_1__c: maddress.street,
                            Mailing_Street_Address_2__c: maddress.unit,
                            Mailing_City__c: maddress.city,
                            Mailing_State__c: maddress.state,
                            Mailing_Zip_Code__c: maddress.zip,
                            Mailing_Country__c: this.label.United_States
                        };
                    }
                } else {
                    agentInfo = {
                        ...agentInfo,
                        businessId: this.principal.Business_ID__r,
                        Business_ID__r: this.principal.Business_ID__r,
                        Business_Street_Address_1__c: this.principal.Business_Street_Address_1__c,
                        Business_Street_Address_2__c: this.principal.Business_Street_Address_2__c,
                        Business_City__c: this.principal.Business_City__c,
                        Business_State__c: this.principal.Business_State__c,
                        Business_Zip_Code__c: this.principal.Business_Zip_Code__c,
                        Business_Country__c: this.label.United_States
                    };
                    if(this.showMailingAddress){
                        agentInfo = {
                            ...agentInfo,
                            Mailing_Street_Address_1__c: this.principal.Mailing_Street_Address_1__c,
                            Mailing_Street_Address_2__c: this.principal.Mailing_Street_Address_2__c,
                            Mailing_City__c: this.principal.Mailing_City__c,
                            Mailing_State__c: this.principal.Mailing_State__c,
                            Mailing_Zip_Code__c: this.principal.Mailing_Zip_Code__c,
                            Mailing_Country__c: this.label.United_States
                        };
                    }
                }
                if (agentInfo.Business_State__c === this.label.CT) {
                    if (this.showMailingAddress === true) {
                        if (agentInfo.Mailing_State__c === this.label.CT) {
                            if (this.agentId) {
                                this.updateAgentIndividualBusinessRecord({
                                    ...agentInfo,
                                    Id: this.agentId
                                });
                            } else {
                                if (this.isTempApis || this.isAgentChange) {
                                    agentInfo = {
                                        ...agentInfo,
                                        Temp_Type__c: this.principal.Type__c,
                                        Phone__c: phoneNumber,
                                        Business_Filing__c: this.filingId,
                                        Change_Type__c: "Created",
                                    }
                                    this.insertAgentIndividualBusinessRecord(agentInfo, true);
                                } else {
                                    this.insertAgentIndividualBusinessRecord(agentInfo);
                                }
                            }
                        } else {
                            this.businessErrorValidation = this.label.Business_Error_Validation;
                        }
                    } else {
                        if (this.agentId) {
                            if (this.isTempApis) {
                                this.updateAgentIndividualBusinessRecord({
                                    ...agentInfo,
                                    Id: this.agentId
                                });
                            } else if (this.isAgentChange) {
                                this.updateAgentIndividualBusinessRecord({
                                    ...agentInfo,
                                    Id: this.agentId
                                });
                            } else if (this.isAddressChange === true && this.editTempRecord === false) {
                                this.updateAgentIndividualBusinessRecord({
                                    ...agentInfo,
                                    Temp_Type__c: this.label.Agent_Business_Option,
                                    Type__c: "Agent",
                                    Phone__c: phoneNumber,
                                    Agent__c: this.agentId,
                                    Business_Filing__c: this.filingId,
                                    Change_Type__c: "Edited"
                                });
                            }
                            else if (this.isAddressChange === true && this.editTempRecord === true) {
                                this.updateAgentIndividualBusinessRecord({
                                    ...agentInfo,
                                    Temp_Type__c: this.label.Agent_Business_Option,
                                    Type__c: "Agent",
                                    Phone__c: phoneNumber,
                                    Id: this.agentId
                                });
                            } else {
                                this.updateAgentIndividualBusinessRecord({
                                    ...agentInfo,
                                    Id: this.agentId
                                });
                            }
                        } else {
                            if (this.isTempApis || this.isAgentChange) {
                                agentInfo = {
                                    ...agentInfo,
                                    Temp_Type__c: this.principal.Type__c,
                                    Phone__c: phoneNumber,
                                    Business_Filing__c: this.filingId,
                                    Change_Type__c: 'Created'
                                }
                                this.insertAgentIndividualBusinessRecord(agentInfo,true);
                            } else {
                                this.insertAgentIndividualBusinessRecord(agentInfo);
                            }
                        }
                    }
                } else {
                    this.businessErrorValidation = this.label.Business_Error_Validation;
                }
            }
        } else if (this.agentId) {
            let phoneNumber = this.agentBusinessPhoneNumber.split("-").join("");
            agentInfo = {
                Name__c: this.addAgentRecordData.Name__c,
                Type__c: this.addAgentRecordData.Type__c,
                Business_ID__c: this.addAgentRecordData.Business_ID__c,
                Email__c: this.agentBusinessEmailAddress,
                Agent_Phone__c: phoneNumber,
                Agent_Account_ID__c: this.accountId,Account__c: this.addAgentRecordData.Account__c
            };
            if (this.hasEditAddressValidate() && isInputsCorrect && this.agentBusinessEmailAddress === this.agentBusinessConfirmEmailAddress) {
                if (this.editInfoDetails) {
                    let editbusinessAddress = this.template.querySelector('c-brs_address.editBusinessAddress');
                    let editMailingAddress = this.template.querySelector('c-brs_address.editMailingAddress');
                    if (editbusinessAddress) {
                        var baddress = JSON.parse(JSON.stringify(editbusinessAddress.getdata()));
                        agentInfo = {
                            ...agentInfo,
                            Business_Street_Address_1__c: baddress.street,
                            Business_Street_Address_2__c: baddress.unit,
                            Business_City__c: baddress.city,
                            Business_State__c: baddress.state,
                            Business_Zip_Code__c: baddress.zip,
                            Business_Country__c: this.label.United_States,
                        };
                    }
                    if (editMailingAddress) {
                        var maddress = JSON.parse(JSON.stringify(editMailingAddress.getdata()));
                        agentInfo = {
                            ...agentInfo,
                            Mailing_Street_Address_1__c: maddress.street,
                            Mailing_Street_Address_2__c: maddress.unit,
                            Mailing_City__c: maddress.city,
                            Mailing_State__c: maddress.state,
                            Mailing_Zip_Code__c: maddress.zip,
                            Mailing_Country__c: this.label.United_States
                        };
                    }
                }
                else {
                    agentInfo = {
                        ...agentInfo,
                        Business_Street_Address_1__c: this.addAgentRecordData.Business_Street_Address_1__c,
                        Business_Street_Address_2__c: this.addAgentRecordData.Business_Street_Address_2__c ? this.addAgentRecordData.Business_Street_Address_2__c:"",
                        Business_City__c: this.addAgentRecordData.Business_City__c,
                        Business_State__c: this.addAgentRecordData.Business_State__c,
                        Business_Zip_Code__c: this.addAgentRecordData.Business_Zip_Code__c,
                        Business_Country__c: this.label.United_States                       
                    };
                    if(this.showMailingAddress){
                        agentInfo = {
                            ...agentInfo,
                            Mailing_Street_Address_1__c: this.addAgentRecordData.Mailing_Street_Address_1__c,
                            Mailing_Street_Address_2__c: this.addAgentRecordData.Mailing_Street_Address_2__c ? this.addAgentRecordData.Mailing_Street_Address_2__c :"",
                            Mailing_City__c: this.addAgentRecordData.Mailing_City__c,
                            Mailing_State__c: this.addAgentRecordData.Mailing_State__c,
                            Mailing_Zip_Code__c: this.addAgentRecordData.Mailing_Zip_Code__c,
                            Mailing_Country__c: this.label.United_States
                        } 
                    }
                }
                if (this.isTempApis && this.editTempRecord === false) {
                    this.updateAgentIndividualBusinessRecord({
                        ...agentInfo,
                        Temp_Type__c: this.label.Agent_Business_Option,
                        Type__c: "Agent",
                        Phone__c: phoneNumber,
                        Change_Type__c: "Edited",
                        Agent__c: this.originalAgentId,
                        Business_Filing__c: this.filingId,
                        Account__c: this.addAgentRecordData.Agent_Account_ID__c
                    });
                } else if (this.editTempRecord === true && this.isTempApis) {
                    this.updateAgentIndividualBusinessRecord({
                        ...agentInfo,
                        Temp_Type__c: this.label.Agent_Business_Option,
                        Type__c: "Agent",
                        Phone__c: phoneNumber,
                        Id: this.agentId
                    });
                } else if (this.isAgentChange) {
                    this.updateAgentIndividualBusinessRecord({
                        ...agentInfo,
                        Temp_Type__c: this.label.Agent_Business_Option,
                        Phone__c: phoneNumber,
                        Type__c: "Agent",
                        Id: this.getAgentDetailsData.Id
                    });
                } else if (this.isAddressChange === true && this.editTempRecord) {
                    this.updateAgentIndividualBusinessRecord({
                        ...agentInfo,
                        Temp_Type__c: this.label.Agent_Business_Option,
                        Type__c: "Agent",
                        Phone__c: phoneNumber,
                        Change_Type__c: "Edited",
                        Id: this.agentId,
                        Business_Filing__c: this.filingId
                    });
                } else if (this.isAddressChange === true && !this.editTempRecord) {
                    this.updateAgentIndividualBusinessRecord({
                        ...agentInfo,
                        Temp_Type__c: this.label.Agent_Business_Option,
                        Type__c: "Agent",
                        Phone__c: phoneNumber,
                        Change_Type__c: "Edited",
                        Agent__c: this.agentId,
                        Business_Filing__c: this.filingId,
                        Account__c: this.addAgentRecordData.Agent_Account_ID__c
                    });
                }
                 else {
                    this.updateAgentIndividualBusinessRecord({
                        ...agentInfo,
                        Id: this.getAgentDetailsData.Id
                    });
                }
            }
        }
    }
    createTempAgentOriginalRecord(agent) {
        upsertTempRecord({ tempRec: agent }).then((data) => {
            this.isLoading = false;
        }).catch((error) => {
            this.isLoading = false;
            ComponentErrorLoging(this.compName, "createTempAgentOriginalRecord", "", "", "Medium", error.message);
        });
    }
    formatPhoneNumber(number) {
        let phoneNumber = "";      
        if (number) {
            const convertNumberType = isNaN(number) ? number.toString() : number;
            if (convertNumberType.length > 2) { phoneNumber += convertNumberType.substr(0, 3) + "-"; }
            if (convertNumberType.length > 5) { phoneNumber += convertNumberType.substr(3, 3) + "-"; }
            if (convertNumberType.length > 9) { phoneNumber += convertNumberType.substr(6); }
        }
        return phoneNumber;
    }
    clearAllFields() {
        this.AgentFirstName = "";this.AgentLastName = "";this.AgentEmail = "";this.editBusinessId = "";this.AgentConfirmEmail = "";this.AgentPhone = "";this.hasAddressChanged = false;
        this.businessErrorValidation = "";this.hidecheckbox = true;this.selectedAgentOption = "";this.businessAddressFields = {...this.initialAddressFields}; this.residenceAddressFields = {...this.initialAddressFields};
        this.mailingAddressFields = {...this.initialAddressFields};this.showAddressFormWhenAnyFieldMiss = false;
    }
    onCTAddressChange(){this.businessErrorValidation = "";}
    getFullBusinessAddress(agent,naNotNeeded) {
        var agentBusinessAddress = [];
        if (agent.Business_Street_Address_1__c) {
            agentBusinessAddress.push(agent.Business_Street_Address_1__c);
        }
        if (agent.Business_Street_Address_2__c) {
             agentBusinessAddress.push(agent.Business_Street_Address_2__c);
        }
        if (agent.Business_City__c) {
            agentBusinessAddress.push(agent.Business_City__c);
        }
        if (agent.Business_State__c) {
            agentBusinessAddress.push(agent.Business_State__c);
        }
        if (agent.Business_Zip_Code__c) {
            agentBusinessAddress.push(agent.Business_Zip_Code__c);
        }
        if (agent.Business_InternationalAddress__c) {
            agentBusinessAddress.push(agent.Business_InternationalAddress__c);
        }
        if (agentBusinessAddress.length > 0 && agent.Business_Country__c) {
            agentBusinessAddress.push(agent.Business_Country__c);
        }
        if(agentBusinessAddress.length === 0 && !naNotNeeded){
            agentBusinessAddress.push(this.label.not_applicable);
        }
        agentBusinessAddress = this.removeSpacesFromArray(agentBusinessAddress);
        return agentBusinessAddress.join(", ");
    }
    getFullResidenceAddress(agent) {
        var agentBusinessAddress = [];
        if (agent.Residence_Street_Address_1__c) {
            agentBusinessAddress.push(agent.Residence_Street_Address_1__c);
        }
        if (agent.Residence_Street_Address_2__c) {
            agentBusinessAddress.push(agent.Residence_Street_Address_2__c);
        }
        if (agent.Residence_City__c) {
            agentBusinessAddress.push(agent.Residence_City__c);
        }
        if (agent.Residence_State__c) {
            agentBusinessAddress.push(agent.Residence_State__c);
        }
        if (agent.Residence_Zip_Code__c) {
            agentBusinessAddress.push(agent.Residence_Zip_Code__c);
        }
        if (agentBusinessAddress.length > 0 && agent.Residence_Country__c) {
            agentBusinessAddress.push(agent.Residence_Country__c);
        }
        if(agentBusinessAddress.length === 0){
            agentBusinessAddress.push(this.label.not_applicable);
        }   
        agentBusinessAddress = this.removeSpacesFromArray(agentBusinessAddress);     
        return agentBusinessAddress.join(", ");
    }
    getFullMailingAddress(agent) {
        return getMailingAddress(agent);
    }
    removeSpacesFromArray(address){
        return address.filter((str) => { return /\S/.test(str); });
    }
    clearBusinessFields() {
        this.searchKey = "";
        this.principalList = undefined;
        this.agentBusinessEmailAddress = "";
        this.agentBusinessConfirmEmailAddress = "";
        this.agentBusinessPhoneNumber = "";
    }
    deleteSecretary() {
        this.secretaryRecord = false;
        this.addAgentPopupBtn = true;
        this.closeAddAgentMainPopup();
        this.clearAllFields();
        this.clearBusinessFields();
    }
    deleteAgent(event) {
        var id = event.currentTarget.dataset.id;
        this.isLoading = true;
        if (this.isAgentChange || this.isTempApis) {
            this.deleteChangeAgentDataRecord(id);
        } else {
            this.deleteChangeAgentDataRecord(id)
        }
    }
    deleteChangeAgentDataRecord(agentRecordId) {
        if (this.isTempApis || this.isAgentChange) {
            deleteTempRecord({ sId: this.filingId }).then((data) => {
                this.showTempValue = false;
                this.deleteAgentRecordInfo();
                this.getAgentRecords();
                this.FirstReportName = true;
                this.editTempRecord = false;
                this.checkAgentChanged = false;
                this.isAgentChangeFlow = false;
                this.isAgentChanged = false;
            }).catch((error) => {
                this.isLoading = false;
                ComponentErrorLoging(this.compName, "deleteChangeAgentDataRecord", "", "", "Medium", error.message);
            });
        } else {
            deleteAgentRecord({ sId: agentRecordId }).then((data) => {
                this.deleteAgentRecordInfo();
            }).catch((error) => {
                this.isLoading = false;
                ComponentErrorLoging(this.compName, "deleteChangeAgentDataRecord", "", "", "Medium", error.message);
            });
        }
    }
    deleteAgentRecordInfo() {
        this.isLoading = false;
        this.getAgentDetailsData = undefined;
        this.addAgentRecordData = undefined;
        this.changeAgentName = false;
        this.FirstReportName = false;
        this.closeAddAgentMainPopup();
        this.clearAllFields();
        this.clearBusinessFields();
        this.agentRecord = false;
        this.secretaryRecord = false;
        this.addAgentPopupBtn = true;
        this.agentId = "";
    }
    handleClickeventForEditInfo() {
        this.editInfoDetails = true;
        this.editAddInfoBtn = false;
        if(!this.agentId){
            this.agentBusinessHeader = this.label.Agent_New_Business;
        }
        if((this.selectedPrincipalAddressId && this.selectedPrincipalAddressId.Business_State__c === this.label.CT) || ((this.isTempApis || this.isAddressChange || this.isAgentChange) && !this.selectedPrincipalAddressId && this.addAgentRecordData && this.addAgentRecordData.Business_State__c === this.label.CT)){
            this.setEditBusinessAddressFields();
        }else{
            this.businessAddressFields = {
                ...this.initialAddressFields,
                addressState: this.label.CT
            }
        }
        if (this.showMailingAddress) {
            if ((this.selectedPrincipalAddressId && this.selectedPrincipalAddressId.Mailing_State__c === this.label.CT) || ((this.isTempApis || this.isAddressChange || this.isAgentChange) && !this.selectedPrincipalAddressId && this.addAgentRecordData && this.addAgentRecordData.Mailing_State__c === this.label.CT)) {
                this.setEditMailingAddressFields();
            } else {
                this.mailingAddressFields = {
                    ...this.initialAddressFields,
                    addressState: this.label.CT
                }
            }
        }
    }
    setEditBusinessAddressFields() {
        if(this.selectedPrincipalAddressId){
            this.businessAddressFields = {
                addressStreet: this.selectedPrincipalAddressId.Business_Street_Address_1__c,
                addressUnit: this.selectedPrincipalAddressId.Business_Street_Address_2__c,
                addressCity: this.selectedPrincipalAddressId.Business_City__c,
                addressState: this.label.CT,
                addressZip: this.selectedPrincipalAddressId.Business_Zip_Code__c
            }
        }else {
            this.businessAddressFields = {
                addressStreet: this.addAgentRecordData.Business_Street_Address_1__c,
                addressUnit: this.addAgentRecordData.Business_Street_Address_2__c,
                addressCity: this.addAgentRecordData.Business_City__c,
                addressState: this.label.CT,
                addressZip: this.addAgentRecordData.Business_Zip_Code__c
            }
        }
    };
    setEditMailingAddressFields() {
        if(this.selectedPrincipalAddressId){
            this.mailingAddressFields = {
                addressStreet: this.selectedPrincipalAddressId.Mailing_Street_Address_1__c,
                addressUnit: this.selectedPrincipalAddressId.Mailing_Street_Address_2__c,
                addressCity: this.selectedPrincipalAddressId.Mailing_City__c,
                addressState: this.label.CT,
                addressZip: this.selectedPrincipalAddressId.Mailing_Zip_Code__c
            }
        }else  {
            this.mailingAddressFields = {
                addressStreet: this.addAgentRecordData.Mailing_Street_Address_1__c,
                addressUnit: this.addAgentRecordData.Mailing_Street_Address_2__c,
                addressCity: this.addAgentRecordData.Mailing_City__c,
                addressState: this.label.CT,
                addressZip: this.addAgentRecordData.Mailing_Zip_Code__c
            }
        }
    };
    handleClickeventForCancelInfo() {
        this.editInfoDetails = false;
        this.editAddInfoBtn = true;
        if(!this.agentId){
            this.agentBusinessHeader = this.label.Agent_Business;
        }
    }
    editAgentData() {
        this.errorMessageForSearch = "";
        this.selectedPrincipalAddressId = "";
        this.getAgentDetailsButton();
        this.editBusinessId = this.addAgentRecordData.businessId;
        this.isEditedAddressFields = false;
        this.validateEditData(this.addAgentRecordData); 
        this.showAddressFormWhenAnyFieldMiss = false;       
    }
    validateEditData(data) {
        this.showUpdateButton = true;
        if (this.isTempApis) {
            this.showPleaseNote = false;
            this.agentId = data.Id;
            if (data.Temp_Type__c == this.label.Agent_Individual_Option || data.Type__c == this.label.Agent_Individual_Option) {
                this.showBackButton = false;
                this.addAgentMainPopup = true;
                this.modalOpenOrClose(true);
                this.addAgentDataIndividual = true;
                this.readonlyAgentDetails = data.FirstName__c && data.LastName__c;
                this.label.Manual_Add_Individual_Agent = this.label.agent_annual_header;
                this.label.Agent_fields_Mandatory = this.label.agent_annual_subheader;
                this.setIndividualDetails(data);
                this.setEditBusinessAddess(data);
                this.setEditResidenceAddess(data);
                this.setEditMailingAddess(data);
            } else {
                this.agentBusinessHeader = this.label.agent_annual_header1
                this.setBusinessDetails(data);
                this.showUpdateButton = true;
                this.label.Agent_fields_Mandatory = this.label.agent_annual_subheader;
            }
        } else if (this.isAgentChange) {
            this.showPleaseNote = this.editTempRecord;           
            this.agentId = data.Id;
            if (data.Type__c == this.label.Agent_Business_Option || data.Temp_Type__c == this.label.Agent_Business_Option) {
                this.agentBusinessHeader = Agent_Business;
                this.label.Agent_fields_Mandatory = Agent_fields_Mandatory;
                this.setBusinessDetails(data);
                this.showUpdateButton = true;
            } else {
                this.showBackButton = false;
                this.addAgentMainPopup = true;
                this.modalOpenOrClose(true);
                this.addAgentDataIndividual = false;
                this.addAgentDataIndividual = true;
                this.label.Manual_Add_Individual_Agent = Manual_Add_Individual_Agent;
                this.label.Agent_fields_Mandatory = Agent_fields_Mandatory;
                this.setIndividualDetails(data);
                this.setEditBusinessAddess(data);
                this.setEditResidenceAddess(data);
                this.setEditMailingAddess(data);
            }
        } else if (this.isAddressChange == true) {
            this.showPleaseNote = false;
            this.agentId = data.Id;
            if (data.Type__c == this.label.Agent_Business_Option || data.Temp_Type__c == this.label.Agent_Business_Option) {
                this.setBusinessDetails(data);
                this.showUpdateButton = true;
                this.hasTable(true);
                this.agentBusinessHeader = this.label.agent_annual_header1;
            } else {
                this.showBackButton = false;
                this.addAgentMainPopup = true;
                this.modalOpenOrClose(true);
                this.addAgentDataIndividual = false;
                this.individualBusinessAddress = true;
                this.label.Manual_Add_Individual_Agent = this.label.agent_annual_header;
                this.setIndividualDetails(data);
                this.setEditBusinessAddess(data);
                this.setEditResidenceAddess(data);
                this.setEditMailingAddess(data);
            }
            this.label.Agent_fields_Mandatory = this.label.agent_annual_subheader;
        } else {
            this.showBackButton = false;
            if (data.Type__c == this.label.Agent_Business_Option || data.Temp_Type__c == this.label.Agent_Business_Option) {
                this.addAgentMainPopup = true;                
                this.modalOpenOrClose(true);
                this.searchAgentBusiness = true;
                this.searchKey = "";
                this.setEditBusinessAddess(data);
                this.setEditMailingAddess(data);
                this.agentBusinessEmailAddress = data.Email__c;
                this.agentBusinessConfirmEmailAddress = data.Email__c;
                this.agentBusinessPhoneNumber = data.Agent_Phone__n;
                this.showUpdateButton = true;
                setTimeout(() => {
                    this.hasTable(true);
                }, 400);
                const mailingAddress = this.getFullMailingAddress(this.getAgentDetailsData);
                const businessAddress = this.getFullBusinessAddress(this.getAgentDetailsData);
                this.principalList = [{
                    checked: true,
                    Name: this.getAgentDetailsData.Name__c,
                    AccountNumber: this.addAgentRecordData.businessId,
                    Business_Address_1__c: businessAddress,
                    Mailing_Address_1__c: mailingAddress
                }];
                this.searchAgentResult = [{
                    Business_ID__r: this.addAgentRecordData.businessId,
                    Name__c: this.getAgentDetailsData.Name__c,
                    Business_address__c: businessAddress,
                    Mailing_address__c: mailingAddress
                }];
                this.selectedPrincipalAddressId = {
                    ...this.addAgentRecordData
                };
                this.principal = {
                    ...this.principal,
                    ...this.selectedPrincipalAddressId,
                    Business_ID__r: this.addAgentRecordData.businessId,
                }
            } else {
                this.addAgentMainPopup = true;
                this.modalOpenOrClose(true);
                this.addAgentDataIndividual = true;
                this.setIndividualDetails(data);
                this.setEditBusinessAddess(data);
                this.setEditResidenceAddess(data);
                this.setEditMailingAddess(data);
            }
        }
        this.modalFocusTrap();
    }
    setBusinessDetails(data) {
        this.searchAgentResult = {
            ...data,
            Business_ID__r: data.businessId,
            Name__c: data.Name__c,
            Business_address__c: this.getFullBusinessAddress(data,true),
            Mailing_address__c: this.getFullMailingAddress(data)
        }
        this.addAgentMainPopup = true;
        this.modalOpenOrClose(true);
        this.showBackButton = false;
        this.addAgentData = false;
        this.addAgentDataIndividual = false;
        this.individualBusinessAddress = false;
        this.searchAgentBusiness = false;
        this.addBusinessAgentInfo = true;
        setTimeout(() => { this.hasTable(true); }, 400);
        this.selectedAgentOption = data.Type__c;
        this.editAddInfoBtn = true;
        this.editInfoDetails = false;
        this.businessErrorValidation = "";
        this.setEditBusinessAddess(data);
        this.setEditMailingAddess(data);
        this.agentBusinessEmailAddress = data.Email__c;
        this.agentBusinessConfirmEmailAddress = data.Email__c;
        this.agentBusinessPhoneNumber = data.Agent_Phone__n;
    }
    setIndividualDetails(data) {
        this.selectedAgentOption = data.Type__c;
        this.AgentFirstName = data.FirstName__c;
        this.AgentLastName = data.LastName__c;
        this.AgentPhone = data.Agent_Phone__n;
        this.phone = data.Agent_Phone__n
        this.email = data.Email__c;
        this.name = data.FirstName__c + " " + data.LastName__c;
        this.AgentEmail = data.Email__c;
        this.AgentConfirmEmail = data.Email__c;
    }
    setEditBusinessAddess(data) {
        this.businessAddressFields = {
            addressStreet: data.Business_Street_Address_1__c,
            addressUnit: data.Business_Street_Address_2__c,
            addressCity: data.Business_City__c,
            addressState: data.Business_State__c,
            addressZip: data.Business_Zip_Code__c,
            addressInternational: data.Business_InternationalAddress__c,
            addressCountry: data.Business_Country__c
        }
    }
    setEditResidenceAddess(data) {
        this.residenceAddressFields = {
            addressStreet: data.Residence_Street_Address_1__c,
            addressUnit: data.Residence_Street_Address_2__c,
            addressCity: data.Residence_City__c,
            addressState: data.Residence_State__c,
            addressZip: data.Residence_Zip_Code__c
        }
    }
    setEditMailingAddess(data) {
        this.mailingAddressFields = {
            addressStreet: data.Mailing_Street_Address_1__c,
            addressUnit: data.Mailing_Street_Address_2__c,
            addressCity: data.Mailing_City__c,
            addressState: data.Mailing_State__c,
            addressZip: data.Mailing_Zip_Code__c
        }
    }
    hasTable(hasTable) {
        var modal = this.template.querySelector(".slds-modal");
        if (modal) {
            if (hasTable) {
                modal.classList.remove("slds-modal_small");
                modal.classList.add("slds-modal_large");
            } else {
                modal.classList.remove("slds-modal_large");
                modal.classList.add("slds-modal_small");
            }
        }
    }
    handleSecretaryStateAgent() {
        this.isLoading = true;
        var agent = {
            Type__c: this.selectedAgentOption,
            Name__c: Secretary_Of_State,
            Business_City__c: Secretary_Of_State_City,
            Business_Street_Address_1__c: Secretary_Of_State_Street,
            Business_Zip_Code__c: Secretary_Of_State_ZipCode,
            Business_State__c: Secretary_Of_State_StateValue,
            Business_Country__c: this.label.United_States
        }
        this.addAgentRecordData = {
            Residence_Address__c: Secretary_Of_State_Address
        }
        if (this.isTempApis || this.isAgentChange) {
            agent = {
                ...agent,
                Type__c: 'Agent',
                Temp_Type__c: this.selectedAgentOption,
                //Account__c: this.accountId,
                Business_Filing__c: this.filingId,
                Business_ID__c: this.accountId,
                Change_Type__c: "Created"
            }
            this.createTempSecretaryAgentRecord(agent);
        }
        else {
            agent = {
                ...agent,
                //Agent_Account_ID__c: this.accountId,
                Business_ID__c: this.accountId
            }
            this.createSecretaryAgentRecord(agent);
        }
    }
    createTempSecretaryAgentRecord(agent) {
        this.isLoading = true;
        upsertTempRecord({ tempRec: agent }).then((data) => {
            this.selectedPrincipalAddressId = "";
            this.getAgentDetailsData = data;
            this.isLoading = false;
            this.showTempValue = true;
            this.isAgentChanged = true;
            this.isAgentChangeFlow = true;
            this.checkAgentChanged = true;
            this.FirstReportName = false;
            this.isFlowReport = false;
            this.clearAllFields();
            this.changeAgentName = false;
            this.closeAddAgentMainPopup();
            this.agentRecord = false;
            this.secretaryRecord = true;
            this.changeAgentRecord = false;
            this.showAgentErrorMessage = false;
            this.AgentChangeError = false;
            if (this.isAgentChange || this.isTempApis) {
                this.createOriginalDeleteTempRecord();
            }
        }).catch((error) => {
            this.isLoading = false;
            ComponentErrorLoging(this.compName, "createTempAgentRecord", "", "", "Medium", error.message);
        });
    }
    createSecretaryAgentRecord(agent) {
        this.isLoading = true;
        insertAgentRecord({ agentRec: agent }).then((data) => {
            this.getAgentDetailsData = data;
            this.isLoading = false;
            this.clearAllFields();
            this.closeAddAgentMainPopup();
            this.secretaryRecord = true;
            this.agentRecord = false;
            this.showAgentErrorMessage = false;
            this.AgentChangeError = false;
        }).catch((error) => {
            this.isLoading = false;
            ComponentErrorLoging(this.compName, "createSecAgentRecord", "", "", "Medium", error.message);
        });
    }
    getTempAgentRecords() {
        this.isLoading = true;
        getTempRecordsonLoad({ sId: this.accountId, type: 'Agent', filingId: this.filingId })
            .then(account => {
                this.isLoading = false;
                if(account && account.length){
                    let agentData = account[0];
                    if(agentData.Name__c && agentData.Name__c.toLowerCase() === this.label.Secretary_Of_State.toLowerCase()){
                        this.agentRecord = false;
                        this.secretaryRecord = true;
                        this.getAgentDetailsData = agentData;
                        if(this.isTempApis){
                            this.isFlowReport = false;
                        }
                    }else{
                        this.getAgentDetailsData = agentData;
                        this.fetchAndEditAgentCardDetails(this.getAgentDetailsData)
                        this.agentRecord = true;
                        this.secretaryRecord = false;
                    }
                }else {
                    this.getAgentDetailsData = undefined;                    
                    this.agentRecord = false;
                }              
                this.FirstReportName = false;
                this.changeAgentName = false;
                this.editTempRecord = true;
                if(this.isTempApis){
                    this.isAgentChangeFlow = false;
                }
                if(this.isAgentChange || this.isAddressChange){
                    this.isAgentChangeFlow = true;
                    this.checkAgentChanged = true;
                }
            }).catch((error) => {
                this.isLoading = false;
                ComponentErrorLoging(this.compName, "getTempAgentRecords", "", "", "Medium", error.message);
            });
    }
    getAgentRecords() {
        this.isLoading = true;
        getAgentRecordsonLoad({ sId: this.accountId })
            .then(account => {
                this.isLoading = false;
                if (account && Object.keys(account).length > 0) {                    
                    this.getAgentDetailsData = account;
                    this.originalAgentId = account.Id;
                    this.agentId = account.Id;     
                    this.showTempValue = false;
                    this.isAgentChanged = false;   
                    if(this.isTempApis){
                        this.firstAndAnnualFlowBtns = true;
                        this.domesticForigenFlowBtns = false;
                    }
                    if(this.isAgentChange){
                        this.firstAndAnnualFlowBtns = false;
                        this.domesticForigenFlowBtns = false;
                    }
                    if(account.Name__c && account.Name__c.toLowerCase() === this.label.Secretary_Of_State.toLowerCase()){
                        this.secretaryRecord = true;
                        this.agentRecord = false;
                        if(this.isTempApis || this.isAgentChange || this.isAddressChange){
                            this.isFlowReport = true;
                        }
                        return;
                    }
                    let formatedPhNumner = this.formatPhoneNumber(this.getAgentDetailsData.Agent_Phone__c);
                    if (this.getAgentDetailsData.Type__c === this.label.Agent_Business_Option) {
                        let agentBusinessId = Object.assign({}, this.getAgentDetailsData.Agent_Account_ID__r)
                        this.addAgentRecordData = {
                            ...this.getAgentDetailsData,
                            businessId: agentBusinessId.AccountNumber,
                            Agent_Phone__n: formatedPhNumner,
                            Business_Address__c: this.getFullBusinessAddress(this.getAgentDetailsData),
                            Mailing_Address__c: this.getFullMailingAddress(this.getAgentDetailsData),
                            Mailing_Address__div: this.showMailingAddress,
                            showBusinessId: true,
                            isIndividual: false
                        }
                    } else {
                        this.addAgentRecordData = {
                            ...this.getAgentDetailsData,
                            Agent_Phone__n: formatedPhNumner,
                            businessId: "",
                            Business_Address__c: this.getFullBusinessAddress(this.getAgentDetailsData),
                            Mailing_Address__c: this.getFullMailingAddress(this.getAgentDetailsData),
                            Residence_Address__c: this.getFullResidenceAddress(this.getAgentDetailsData),
                            Mailing_Address__div: this.showMailingAddress,
                            Residence_Street__div: true,
                            showBusinessId: false,
                            isIndividual: false
                        }
                    }
                    this.agentRecord = true;
                }else {
                    this.agentRecord = false;       
                    if(this.isAddressChange || this.isAgentResignation){                                     
                        this.getAgentDetailsData = true;
                    }else{
                        this.getAgentDetailsData = false;
                        this.FirstReportName = false;
                        this.changeAgentName = false;
                    }
                }
            }).catch((error) => {
                this.isLoading = false;
                ComponentErrorLoging(this.compName, "getAgentRecordsonLoad", "", "", "Medium", error.message);
            });
    }
    handleChangeAgentPopup() {
        this.changegentMainPopup = true;
        this.modalOpenOrClose(true);
        this.readonlyAgentDetails = false;
        this.onLoadAgentRecords();
        this.modalFocusTrap();
    }
    goToIndividualBusinessOptions() {
        this.readonlyAgentDetails = false;
        this.changegentMainPopup = false;
        this.modalOpenOrClose(false);
        this.handleAddAgentPopup();    
    }
    closeConfirmChangeAgent() {
        this.changeAgentName = true;
        this.changeAgentRecord = false;
        this.changegentMainPopup = false;
        this.modalOpenOrClose(false);
        this.readonlyAgentDetails = false;
    }
    closeConfirmChangeAgentKeyPress(event){
        if(event.keyCode === 13 || event.keyCode == 32){
            this.closeConfirmChangeAgent();
        }
    }
    onLoadAgentRecords() {
        if (this.isAgentChanged == false) {
            this.getAgentRecords();
        } else {
            this.getTempAgentRecords();
        }
    }
    modalOpenOrClose(modalOpened) {
        showOrHideBodyScroll(modalOpened);
    }
    hasPrincipalOfficeAddress() {
        let hasTempAddress = false;
        if(this.isTempApis && this.tempHistory){
            let accTempRecValue = JSON.parse(JSON.stringify(this.tempHistory));
            hasTempAddress = accTempRecValue && 
                ((accTempRecValue.Billing_Country_New__c && accTempRecValue.BillingStreet_New__c && accTempRecValue.Billing_City_New__c && accTempRecValue.BillingState_New__c && accTempRecValue.BillingPostalCode_New__c) 
                || (accTempRecValue.Principle_Office_International_Address_N__c && accTempRecValue.Billing_Country_New__c));
            this.hasTempAddress = hasTempAddress;
        }        
        let accRecValue = JSON.parse(JSON.stringify(this.accountrecord));
        this.showPrincipalCheckbox = (accRecValue && 
        ((accRecValue.BillingCountry && accRecValue.BillingStreet && accRecValue.BillingCity && accRecValue.BillingState && accRecValue.BillingPostalCode) 
        || (accRecValue.Principle_Office_International_Address__c && accRecValue.BillingCountry)) || hasTempAddress);
    }
    modalFocusTrap(){
        setTimeout(() => {
            focusTrap(this.template);
        }, 250);
    }

    checkBusinessLinkage(){
        let isBusinessLinked = true;
        if (this.getAgentDetailsData && (this.getAgentDetailsData.Temp_Type__c == this.label.Agent_Business_Option || this.getAgentDetailsData.Type__c == this.label.Agent_Business_Option)){
            isBusinessLinked = (this.getAgentDetailsData.Agent_Account_ID__c || this.getAgentDetailsData.Account__c || (this.searchAgentResult && this.searchAgentResult.Business_ID__r)) ? true : false;
        }
        return isBusinessLinked;
    } 
}
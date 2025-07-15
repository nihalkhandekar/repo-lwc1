import { LightningElement, track, wire, api } from 'lwc';
import { fireEvent, registerListener } from 'c/commonPubSub';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
    FlowNavigationBackEvent
} from 'lightning/flowSupport';
import { CurrentPageReference } from "lightning/navigation";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import getAccountRecords from '@salesforce/apex/brs_contactDetailPage.getAccountRecords';
import updatePrincipalRecord from '@salesforce/apex/brs_contactDetailPage.updatePrincipalRecord';
import deletePrincipalRecord from '@salesforce/apex/brs_contactDetailPage.deletePrincipalRecord';
import getPrincipalRecordsonLoad from '@salesforce/apex/brs_contactDetailPage.getPrincipalRecordsonLoad';
import getAllRecordsonLoad from '@salesforce/apex/brs_contactDetailPage.getAllRecordsonLoad';
import insertPrincipalRecord from '@salesforce/apex/brs_contactDetailPage.insertPrincipalRecord';
import upsertTempRecord from '@salesforce/apex/BRS_Utility.upsertTempRecord';
import getTempRecordsonLoad from '@salesforce/apex/brs_contactDetailPage.getTempRecordsonLoad';
import deleteRecords from '@salesforce/apex/BOS_Utility.deleteRecords';
import Add_Principal from '@salesforce/label/c.Add_Principal';
import brs_principalPopup_Edit from '@salesforce/label/c.brs_principalPopup_Edit';
import Remove from '@salesforce/label/c.Remove';
import Delete from '@salesforce/label/c.Delete';
import brs_Add_Principal from '@salesforce/label/c.brs_Add_Principal';
import brs_Add_More from '@salesforce/label/c.brs_Add_More';
import brs_Principal_Descripation from '@salesforce/label/c.brs_Principal_Descripation';
import Next from '@salesforce/label/c.Next';
import Business_ID from '@salesforce/label/c.Business_AELI';
import brs_Individual_Principal from '@salesforce/label/c.brs_Individual_Principal';
import Individual_comparable from '@salesforce/label/c.Individual_comparable';
import { ComponentErrorLoging } from "c/formUtility";
import fields_Mandatory from '@salesforce/label/c.fields_Mandatory';
import Back from '@salesforce/label/c.Back';
import Title from '@salesforce/label/c.Title';
import Email_Address from '@salesforce/label/c.Email_Address';
import Name from '@salesforce/label/c.Name';
import Confirm from '@salesforce/label/c.Confirm';
import brs_Business_Address from '@salesforce/label/c.brs_Business_Address';
import brs_Residence_Address from '@salesforce/label/c.brs_Residence_Address';
import brs_Business_Principal from '@salesforce/label/c.brs_Business_Principal';
import brs_Busiess_Descripation from '@salesforce/label/c.brs_Busiess_Descripation';
import ADD_MANUALLY from '@salesforce/label/c.ADD_MANUALLY';
import Search_Result from '@salesforce/label/c.Search_Result';
import Yes from '@salesforce/label/c.YesComparable';
import No_Result from '@salesforce/label/c.No_Result';
import Princial_Manaully_Business from '@salesforce/label/c.Princial_Manaully_Business';
import Principal_Manaully_Business_Descripation from '@salesforce/label/c.Principal_Manaully_Business_Descripation';
import brs_Business_Principal_Details from '@salesforce/label/c.brs_Business_Principal_Details';
import { emailPattern,focusTrap } from "c/appUtility";
import GenericInput_Invalid_Email from "@salesforce/label/c.GenericInput_Invalid_Email";
import Selection_Required from '@salesforce/label/c.Selection_Required';
import pleaseSelectMssg from '@salesforce/label/c.brs_Add_Incorporator_SelectType';
import brs_DoYouHaveBusinessAddress from '@salesforce/label/c.brs_DoYouHaveBusinessAddress';
import Domestic from '@salesforce/label/c.Domestic';
import United_States from '@salesforce/label/c.United_States';
import No_Principals_Error from '@salesforce/label/c.No_Principals_Error';
import Same_As_Principal_Address from '@salesforce/label/c.Same_As_Principal_Address';
import Same_As_Business_Address from '@salesforce/label/c.Same_As_Business_Address';
import getAgentRecordsonLoad from '@salesforce/apex/brs_contactDetailPage.getAgentRecordsonLoad';
import Secretary_Of_State from '@salesforce/label/c.Secretary_Of_State';
import Assign_Agent_As_Principal from '@salesforce/label/c.Assign_Agent_As_Principal';
import Is_This_Principal_Also_Agent from '@salesforce/label/c.Is_This_Principal_Also_Agent';
import Designation from '@salesforce/label/c.Designation';
import Officer from '@salesforce/label/c.Officer';
import Director from '@salesforce/label/c.Director';
import None from '@salesforce/label/c.None';
import principal_confirmation_question from '@salesforce/label/c.principal_confirmation_question';
import principal_confirmation_text from '@salesforce/label/c.principal_confirmation_text';
import principal_annual_confirmation_text from '@salesforce/label/c.principal_annual_confirmation_text';
import Cancel_Label from '@salesforce/label/c.Cancel_Label';
import go_to_summary from '@salesforce/label/c.go_to_summary';
import annualreport_flow_name from '@salesforce/label/c.annualreport_flow_name';
import firstreport_flow_name from '@salesforce/label/c.firstreport_flow_name';
import delete_principal_confirm from '@salesforce/label/c.delete_principal_confirm';
import delete_principal_confirm_desc from '@salesforce/label/c.delete_principal_confirm_desc';
import interim_error_msg from '@salesforce/label/c.interim_error_msg';
import brs_maintenance_interim from '@salesforce/label/c.brs_maintenance_interim';
import loading_brs from '@salesforce/label/c.loading_brs';
import Page_Is_Loading from '@salesforce/label/c.Page_Is_Loading';
import modal_close from '@salesforce/label/c.modal_close';
import Show_Principal_details from '@salesforce/label/c.Show_Principal_details';
import principal_modal_heading from '@salesforce/label/c.principal_modal_heading';
import confirmation_title from '@salesforce/label/c.confirmation_title';
import aria_delete_confirmation from '@salesforce/label/c.aria_delete_confirmation';
import Title_Required from '@salesforce/label/c.Title_Required';
import First_Name_Required from '@salesforce/label/c.First_Name_Required';
import Last_Name_Required from '@salesforce/label/c.Last_Name_Required';
import AddressUnit_Apt from '@salesforce/label/c.AddressUnit_Apt';
import Business_Name_Required from '@salesforce/label/c.Business_Name_Required';
import { NavigationMixin } from 'lightning/navigation';
import brs_FIlingLandingPage from "@salesforce/label/c.brs_FIlingLandingPage";
import not_applicable from '@salesforce/label/c.not_applicable';
import brs_AddPrincipalErrorMessage1 from "@salesforce/label/c.brs_AddPrincipalErrorMessage1";
import brs_AddPrincipalErrorMessage2 from "@salesforce/label/c.brs_AddPrincipalErrorMessage2";
import First_Name_Placeholder from '@salesforce/label/c.First_Name_Placeholder';
import Last_Name_Placeholder from '@salesforce/label/c.Last_Name_Placeholder';
import title_placeholder from '@salesforce/label/c.title_placeholder';
import EmailPlaceHolder from '@salesforce/label/c.EmailPlaceHolder';
import business_name_placeholder from '@salesforce/label/c.business_name_placeholder';
import Foreign_Label_Comparable from '@salesforce/label/c.Foreign_Label_Comparable';
import Label_Stock_Comparable from '@salesforce/label/c.Label_Stock_Comparable';
import Label_NonStock_Comparable from '@salesforce/label/c.Label_NonStock_Comparable';
import B_Corp_Comparable from '@salesforce/label/c.B_Corp_Comparable';
import Individual from '@salesforce/label/c.Individual';
import SelectanOptionPlaceholder from '@salesforce/label/c.SelectanOptionPlaceholder';
import maxCount from '@salesforce/label/c.brs_Principal_max'; 
import Principal_Information_missing_message from '@salesforce/label/c.Principal_Information_missing_message';
import BRS_Member from '@salesforce/label/c.BRS_Member';
import BRS_Managing_Member from '@salesforce/label/c.BRS_Managing_Member';
import BRS_Manager from '@salesforce/label/c.BRS_Manager';
import Domestic_Label_Comparable from '@salesforce/label/c.Domestic_Label_Comparable';
import Limited_Partnership_Comparable from '@salesforce/label/c.Limited_Partnership_Comparable';
export default class Brs_addPrincipal extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;
    @api accountrecord;
    @api source = "Worker Portal";
    @api isGoToSummary = false;
    @api goToDashBoardPage = false;
    @api showSummaryButton = false;
    @track addIcon = assetFolder + "/icons/add-circle-outline.svg";
    @track editIcon = assetFolder + "/icons/edit-blue.svg";
    @track deleteIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track closeIcon = assetFolder + "/icons/close-outline-blue.svg";
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track arrowIcon = assetFolder + "/icons/chevron-right-blue.svg";
    @track showAddPrincipalPopup = false;
    @track showSecondScreen = false;
    @track showZeroScreen = false;
    @track showFirstScreen = false;
    @track showThirdScreen = false;
    @track showFourthScreen = false;
    @track searchKey = "";
    @track accountId;
    @track selectedPrincipalAddressId;
    @api principalList = [];
    @api principalListData = [];
    @track noPrincipalList = false;
    @track isLoading = false;
    @track spinner = false
    @track hideAddPrincipalButton = false;
    @track copyPrincipalAddressCheck = false;
    @track copyBusinessAddressCheck = false;
    @track compName = "brs_addPrincipal";
    @track isIndividualFlow = false;
    @track showErrorMessage = false;
    @track editMode = false;
    @track showPrincipalError = false;
    @track emailPattern = emailPattern;
    @track showTitle;
    @track agentData;
    @track isAgentSecretaryOfState = false;
    @api showConfirmationModal = false;
    @api filingYear;
    @api filingId;
    @api flowName = "";
    @api isAgentTempType;
    @api tempHistory;
    @track hasTempAddress = false;
    @track isTempApis = false;
    @track isAnnualFlow = false;
    @track enableInputs = false;
    @track isFirstFlow = false;
    @track isInterim = false;
    @track showNoChangeErrorMessage = false;
    @track showDeleteConfirmation = false;
    @track isPrincipalChanged = false;
    @track designationOfficerOptions = [{
        label: Officer,
        value: "Officer"
    }];
    @track designationDirectorOptions = [{
        label: Director,
        value: Director
    }];
    @track showDesignationCheckBoxes = false;
    @track noConfirmation = false;
    @track agentAsPrincipalTableData = [];
    @track individualPrincipalTableData = [];
    @track businessPrincipalTableData = [];
    get getIsDesignationOfficerChecked() {
        if (this.principal.isDesignationOfficerChecked) {
            return ["Officer"];
        }
        return "";
    }

    get getIsDesignationDirectorChecked() {
        if (this.principal.isDesignationDirectorChecked) {
            return [Director];
        }
        return "";
    }

    @track principalOfficeAddressCheckboxOptions = [{
        label: Same_As_Principal_Address,
        value: Same_As_Principal_Address
    }];
    @track businessAddressCheckboxOptions = [{
        label: Same_As_Business_Address,
        value: Same_As_Business_Address,
        isDisabled: true
    }];
    @track selectedRadio;
    @api
    get businessRadioOptions() {
        return this._businessRadioOptions;
    }
    set businessRadioOptions(opt) {
        this._businessRadioOptions = JSON.parse(opt);
    }

    @api
    get agentYesNoOptions() {
        return this._agentYesNoOptions;
    }
    set agentYesNoOptions(opt) {
        this._agentYesNoOptions = JSON.parse(opt);
    }

    @api
    get principalOptions() {
        return this._principalOptions;
    }
    set principalOptions(opt) {
        this._principalOptions = JSON.parse(opt);
    }

    @track selectedBusinessDecision = "";
    @track showHasBusinessAddressError = false;
    @track hasBusinessAddress = true;
    @track showCopyPrincipalAddressCheckbox = false;
    @track noBusinessOption = false;
    @track hideIndividualSecondScreenBack = false;
    @track showBusinessAddressForm = false;
    @track errorMessage;

    get isBusinessAddressChecked() {
        if (this.copyBusinessAddressCheck) {
            return [Same_As_Business_Address];
        }
        return "";
    }

    get isPrincipalAddressChecked() {
        if (this.copyPrincipalAddressCheck) {
            return [Same_As_Principal_Address];
        }
        return "";
    }

    get getIsAnnualOrInterimFlow() {
        return this.isAnnualFlow || this.isInterim;
    }

    label = {
        Limited_Partnership_Comparable,
        Domestic_Label_Comparable,
        Add_Principal,
        brs_principalPopup_Edit,
        Delete,
        Remove,
        Title,
        Email_Address,
        Name,
        brs_Add_Principal,
        brs_Add_More,
        brs_Principal_Descripation,
        Next,
        brs_Individual_Principal,
        fields_Mandatory,
        Back,
        Confirm,
        brs_Business_Address,
        brs_Residence_Address,
        brs_Business_Principal,
        brs_Busiess_Descripation,
        ADD_MANUALLY,
        Search_Result,
        No_Result,
        Princial_Manaully_Business,
        Principal_Manaully_Business_Descripation,
        brs_Business_Principal_Details,
        GenericInput_Invalid_Email,
        Selection_Required,
        brs_DoYouHaveBusinessAddress,
        Domestic,
        No_Principals_Error,
        Assign_Agent_As_Principal,
        Is_This_Principal_Also_Agent,
        pleaseSelectMssg,
        Designation,
        Officer,
        Director,
        None,
        principal_confirmation_question,
        principal_confirmation_text,
        Cancel_Label,
        go_to_summary,
        principal_annual_confirmation_text,
        annualreport_flow_name,
        firstreport_flow_name,
        delete_principal_confirm,
        delete_principal_confirm_desc,
        interim_error_msg,
        brs_maintenance_interim,
        Business_ID,
        loading_brs,
        Page_Is_Loading,
        modal_close,
        Show_Principal_details,
        principal_modal_heading,
        confirmation_title,
        aria_delete_confirmation,
        Title_Required,
        First_Name_Required,
        Last_Name_Required,
        AddressUnit_Apt,
        Business_Name_Required,
        brs_FIlingLandingPage,
        brs_AddPrincipalErrorMessage1,
        brs_AddPrincipalErrorMessage2,
        not_applicable,
        First_Name_Placeholder,
        Last_Name_Placeholder,
        title_placeholder,
        EmailPlaceHolder,
        business_name_placeholder,
        Individual_comparable,
        Foreign_Label_Comparable,
        Label_Stock_Comparable,
        Label_NonStock_Comparable,
        B_Corp_Comparable,
        Individual,
        SelectanOptionPlaceholder,
        Principal_Information_missing_message
    }

    @track initialData = {
        Principal_Type__c: "",
        Principal_Type__c_Error: false,
        FirstName__c: "",
        LastName__c: "",
        Email__c: "",
        Principal_Title__c: "",
        Business_Name__c: "",
        Id: "",
        Principal_Account_ID__c: "",
        Business_City__c: "",
        Business_Country__c: United_States,
        Business_Street_Address_1__c: "",
        Business_Street_Address_2__c: "",
        Business_Zip_Code__c: "",
        Business_InternationalAddress__c: "",
        Business_Address__c: "",
        Business_State__c: "",
        Residence_City__c: "",
        Residence_Country__c: United_States,
        Residence_Street_Address_1__c: "",
        Residence_Street_Address_2__c: "",
        Residence_Zip_Code__c: "",
        Residence_InternationalAddress__c: "",
        Residence_State__c: "",
        AccountNumber: "",
        hasAgentAsPrincipal: "",
        hasAgentAsPrincipalError: false,
        isDesignationOfficerChecked: false,
        isDesignationDirectorChecked: false,
        showDisignationError: false,
        Designation__c: "",
        isTempPrincipal: false
    }

    @api principal = {
        ...this.initialData
    };

    @track initialAddressFields = {
        addressStreet: "",
        addressUnit: "",
        addressCity: "",
        addressState: "",
        addressZip: "",
        addressInternational: ""
    }

    @api businessAddressFields = {
        ...this.initialAddressFields
    }

    @api residenceAddressFields = {
        ...this.initialAddressFields
    }

    handleBusinessAdressRadioCheck(event) {
        const selectedValue = event.detail.value;
        this.selectedBusinessDecision = selectedValue;
        this.hasBusinessAddress = selectedValue === Yes;
        this.showHasBusinessAddressError = false;
    }



    setBusinessAddressFields() {
        this.businessAddressFields = {
            addressStreet: this.principal.Business_Street_Address_1__c,
            addressUnit: this.principal.Business_Street_Address_2__c,
            addressCity: this.principal.Business_City__c,
            addressState: this.principal.Business_State__c,
            addressZip: this.principal.Business_Zip_Code__c,
            addressInternational: this.principal.Business_InternationalAddress__c,
            addressCountry: this.principal.Business_Country__c
        }
    };

    setResidenceAddressFields() {
        this.residenceAddressFields = {
            addressStreet: this.principal.Residence_Street_Address_1__c,
            addressUnit: this.principal.Residence_Street_Address_2__c,
            addressCity: this.principal.Residence_City__c,
            addressState: this.principal.Residence_State__c,
            addressZip: this.principal.Residence_Zip_Code__c,
            addressInternational: this.principal.Residence_InternationalAddress__c,
            addressCountry: this.principal.Residence_Country__c
        }
    };

    get hasPrincipals() {
        return this.principalListData.length > 0;
    };

    get isNameDisable() {
        return this.isAnnualFlow && this.editMode && !this.enableInputs;
    }

    checkPrincipalLength() {
        
        let maxCountInt = parseInt(maxCount);
        this.hideAddPrincipalButton = this.principalListData.length === maxCountInt || this.principalListData.length > maxCountInt;
    };

    get TitleOptions() {
        return [
            { label: BRS_Member, value: 'Member' },
            { label: BRS_Manager, value: 'Manager' },
            { label: BRS_Managing_Member, value: 'Managing Member' }
        ]
    }

    connectedCallback() {
        this.isAnnualFlow = this.flowName === this.label.annualreport_flow_name;
        this.isInterim = this.flowName === this.label.brs_maintenance_interim;
        this.isFirstFlow = this.flowName === this.label.firstreport_flow_name;
        this.isTempApis = (this.flowName === this.label.firstreport_flow_name || this.isAnnualFlow || this.isInterim);

        if (this.accountrecord) {
            var accRecValue = JSON.parse(JSON.stringify(this.accountrecord));
            if (accRecValue) {
                this.accountId = accRecValue.Id;
                if (accRecValue.Citizenship__c == this.label.Domestic_Label_Comparable && accRecValue.Business_Type__c === "LLC") {
                    this.showTitle = true;
                } else {
                    this.showTitle = false;
                }
                if (this.isAnnualFlow) {
                    this.showSummaryButton = true;
                    this.label = {
                        ...this.label,
                        principal_annual_confirmation_text: `${this.label.principal_annual_confirmation_text} (${this.filingYear})`
                    }
                } 
                if ((this.isAnnualFlow && [this.label.B_Corp_Comparable,this.label.Label_Stock_Comparable, this.label.Label_NonStock_Comparable].includes(accRecValue.Business_Type__c)) || (this.isTempApis && !this.isAnnualFlow) || (accRecValue.Citizenship__c == this.label.Foreign_Label_Comparable && [this.label.Label_Stock_Comparable, this.label.Label_NonStock_Comparable].includes(accRecValue.Business_Type__c))) {
                    this.showDesignationCheckBoxes = accRecValue.Business_Type__c !== "LLC";
                }
                if([this.label.B_Corp_Comparable,this.label.Label_Stock_Comparable, this.label.Label_NonStock_Comparable].includes(accRecValue.Business_Type__c)){
                    this.noBusinessOption = true;
                    this.hideIndividualSecondScreenBack = true;
                }
                this.getAgentDetails();
                this.hasPrincipalOfficeAddress();
            }
        }

        if (!this.pageRef) {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
        }
        //get original principals in interim flow
        //get temp and original principal in Annual report flow
        this.getAllPrincipals();

        if (this.principalListData.length > 0) {
            this.showConfirmationModal = false;
        }
        registerListener('flowvalidation', this.handleNotification, this);
    }

    @api
    validate() {
        if(this.principalListData.length > 0 && (this.isFirstFlow || this.isAnnualFlow) && this.isAnyMandatoryFieldMissing()){
            this.showNoChangeErrorMessage = true;
            this.errorMessage = this.label.Principal_Information_missing_message;
            fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid: false }
            });
            return {
                isValid: false,
                errorMessage: ""
            };
        }else if (this.principalListData.length > 0 && (!this.isTempApis || this.noConfirmation)) {
            this.showErrorMessage = false;
            this.goToDashBoardPage=false;
            fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid: true }
            });
            return { isValid: true };
        } else if (this.isInterim && this.principalListData.length > 0 && !this.isPrincipalChanged) {
            this.showNoChangeErrorMessage = true;
            this.errorMessage = this.label.interim_error_msg;
            fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid: false }
            });
            return {
                isValid: false,
                errorMessage: ""
            };
        } else if (this.principalListData.length > 0 && this.isTempApis) {
            this.showErrorMessage = false;
            this.showNoChangeErrorMessage = false;
            this.showConfirmationModal = true;
            this.modalFocusTrap();
            this.goToDashBoardPage=false;
            fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid: true }
            });
            return { isValid: true };
        } else {
            this.showErrorMessage = true;
            fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid: false }
            });
            return {
                isValid: false,
                errorMessage: ""
            };
        }
    }

    isAnyMandatoryFieldMissing() {
        let hasMissingField = [];
        this.principalListData = this.principalListData.map((principal) => {
            let hasError;
                let title = principal.Title__c || principal.Principal_Title__c;
                if (principal.Principal_Type__c === this.label.Individual_comparable) {
                    let firstName = principal.FirstName__c;
                    let lastName = principal.LastName__c;
                    let residenceAddress = (principal.Residence_Street_Address_1__c && principal.Residence_City__c && principal.Residence_State__c && principal.Residence_Zip_Code__c) || (principal.Residence_InternationalAddress__c);
                    let designation = this.showDesignationCheckBoxes ? principal.Designation__c : true;
                    hasError = !firstName || !lastName || !title || !residenceAddress || !designation;
                } else {
                    let businessName = principal.Name__c;
                    let businessAddress = (principal.Business_Street_Address_1__c && principal.Business_City__c && principal.Business_State__c && principal.Business_Zip_Code__c) || (principal.Business_InternationalAddress__c);
                    hasError = !title || !businessName || !businessAddress;
                }
                if(hasError){
                    hasMissingField.push(hasError);
                }
                return{
                    ...principal,
                    cardClassName: hasError ? "principal-list has-error": "principal-list"
                }            
        });
        return hasMissingField.length > 0;
    }

    getAgentDetails() {
        this.isLoading = true;
        if (this.isTempApis && this.isAgentTempType) {
            getTempRecordsonLoad({ sId: this.accountId, type: "Agent", filingId: this.filingId }).then((data) => {
                if (data) {
                    this.agentData = {
                        ...data[0],
                        Type__c: data[0].Temp_Type__c,
                        Agent_Account_ID__r: data[0].Account__r,
                        Agent_Account_ID__c: data[0].Account__c
                    };
                    this.isAgentSecretaryOfState = (data[0].Name__c === Secretary_Of_State);
                } else {
                    this.isAgentSecretaryOfState = true;
                }
                this.isLoading = false;
            }).catch((error) => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "getAgent",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        } else {
            getAgentRecordsonLoad({ sId: this.accountId }).then((data) => {
                if (data) {
                    this.agentData = data;
                    this.isAgentSecretaryOfState = data.Name__c === Secretary_Of_State;
                } else {
                    this.isAgentSecretaryOfState = true;
                }
                this.isLoading = false;
            }).catch((error) => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "getAgent",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        }
    }

    setAgentDetails() {
        const data = this.agentData;
        if (data) {
            this.principal = {
                ...this.principal,
                Email__c: data.Email__c,
                Principal_Type__c: data.Type__c,
                hasBusinessAddress: data.Business_Country__c ? true : false,
                Business_Street_Address_1__c: data.Business_Street_Address_1__c,
                Business_Street_Address_2__c: data.Business_Street_Address_2__c ? data.Business_Street_Address_2__c : "",
                Business_City__c: data.Business_City__c,
                Business_State__c: data.Business_State__c,
                Business_Country__c: data.Business_Country__c,
                Business_Zip_Code__c: data.Business_Zip_Code__c ? data.Business_Zip_Code__c : "",
                Business_InternationalAddress__c: data.Business_InternationalAddress__c
            }
            this.principal = {
                ...this.principal,
                Business_Address_1__c: this.getFullBusinessAddress(this.principal)
            }

            if (data.Type__c === this.label.Individual_comparable) {
                this.isIndividualFlow = true;
                this.principal = {
                    ...this.principal,
                    Name__c: data.FirstName__c + " " + data.LastName__c,
                    FirstName__c: data.FirstName__c,
                    LastName__c: data.LastName__c,
                    Residence_Street_Address_1__c: data.Residence_Street_Address_1__c,
                    Residence_Street_Address_2__c: data.Residence_Street_Address_2__c ? data.Residence_Street_Address_2__c : "",
                    Residence_City__c: data.Residence_City__c,
                    Residence_Country__c: data.Residence_Country__c,
                    Residence_State__c: data.Residence_State__c,
                    Residence_Zip_Code__c: data.Residence_Zip_Code__c ? data.Residence_Zip_Code__c : ""
                }
                this.principal = {
                    ...this.principal,
                    Residence_Address_1__c: this.getFullResidenceAddress(this.principal)
                }
            } else {
                this.isIndividualFlow = false;
                this.principal = {
                    ...this.principal,
                    Name__c: data.Name__c,
                    Business_Name__c: data.Name__c,
                    AccountNumber: data.Agent_Account_ID__r ? data.Agent_Account_ID__r.AccountNumber : ""
                }
            }
        }
    }

    handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid == true) {
            this.showErrorMessage = false;
            this.showNoChangeErrorMessage = false;
        }
        else {
            if (this.principalListData.length > 0 && (this.isFirstFlow || this.isAnnualFlow) && this.isAnyMandatoryFieldMissing()) {
                this.showNoChangeErrorMessage = true;
                this.errorMessage = this.label.Principal_Information_missing_message;
            } else if (this.isInterim && this.principalListData.length > 0) {
                this.showNoChangeErrorMessage = true;
                this.errorMessage = this.label.interim_error_msg;
            } else {
                this.showErrorMessage = true;
            }
        }
    }

    handleAddPrincipalPopupClose(event){
        if (event.keyCode === 13 || event.keyCode == 32) {
            this.showAddPrincipalPopup = false;
            document.body.style.overflow = '';
            this.resetForm();
        }
    }

    handleAddPrincipalPopup() {
        this.showAddPrincipalPopup = !this.showAddPrincipalPopup;
        if (this.showAddPrincipalPopup) {
            document.body.style.overflow = 'hidden';
            this.modalFocusTrap();
        } else {
            document.body.style.overflow = '';
        }
        this.resetForm();
        if (this.hasAddedAgentAsPrincipal) {
            this.showZeroScreen = this.showAddPrincipalPopup;
            this.showFirstScreen = false;
        } else if(this.noBusinessOption){
            this.isIndividualFlow = true;
            this.hideIndividualSecondScreenBack = true;
            this.showFirstScreen = false;
            this.showSecondScreen = this.showAddPrincipalPopup;
            this.showZeroScreen = false;           
            this.principal = {
                ...this.principal,
                Principal_Type__c: this.label.Individual
            }
        } else {
            this.showFirstScreen = this.showAddPrincipalPopup;
            this.showZeroScreen = false;
        }
    }

    gotoAgentOptionsScreen() {
        this.showZeroScreen = true;
        this.showFirstScreen = false;
        this.hasTable(false);
        this.modalFocusTrap();
    }

    // Adding agent as principal radio selection
    onAgentAsPrincipalRadioCheck(event) {
        this.principal = {
            ...this.initialData,
            hasAgentAsPrincipal: event.detail.value
        }
        this.selectedPrincipalAddressId = "";
        this.principalList = undefined;
        this.searchKey = "";
    }

    get showAgentDetails() {
        const agentScreen = this.principal.hasAgentAsPrincipal;
        return agentScreen === "Yes";
    }

    get hasAddedAgentAsPrincipal() {
        if (this.isInterim) {
            return false;
        } else if (this.noBusinessOption) {
            return this.principalListData.filter(principal => principal.Created_From_Agent__c).length === 0 && !this.isAgentSecretaryOfState && this.agentData && this.agentData.Type__c === this.label.Individual_comparable;
        } else {
            return this.principalListData.filter(principal => principal.Created_From_Agent__c).length === 0 && !this.isAgentSecretaryOfState;
        }
    }

    // If user selected Yes for agent, we will show agent details. No case,we will show principal options
    gotoPrincipalOptionsOrAgent() {
        if (this.principal.hasAgentAsPrincipal) {
            if (this.noBusinessOption && !this.showAgentDetails) {
                this.isIndividualFlow = true;
                this.showFirstScreen = false;
                this.showSecondScreen = true;
                this.hideIndividualSecondScreenBack = false;
                this.principal = {
                    ...this.principal,
                    Principal_Type__c: this.label.Individual
                }
            } else {
                this.showFirstScreen = true;
                if (this.showAgentDetails) {
                    this.hasTable(true);
                    this.setAgentDetails();
                }
            }
            this.showZeroScreen = false;
            this.modalFocusTrap();
        }
        this.principal = {
            ...this.principal,
            hasAgentAsPrincipalError: !this.principal.hasAgentAsPrincipal
        }
    }

    gotoFirstScreen() {
        if(this.noBusinessOption){
            this.showZeroScreen = true;
            this.showFirstScreen = false;
            this.showSecondScreen = false;
        }else {
            this.showFirstScreen = true;
            this.showSecondScreen = false;
        }        
        this.hasTable(false);
        this.modalFocusTrap();
    }

    gotoSecondScreen() {
        if (this.validateFirstScreen()) {
            this.showFirstScreen = false;
            this.showSecondScreen = true;
            this.showThirdScreen = false;
            this.showFourthScreen = false;
            if (this.isIndividualFlow) {
                this.hasTable(false);
            } else {
                this.hasTable(true);
            }
            this.modalFocusTrap();
        }
    }

    gotoThirdScreen() {
        if (this.validateSecondScreen()) {
            this.hasTable(false);
            if (this.showSecondScreen && !this.editMode) {
                this.principal = {
                    ...this.principal,
                    Business_Name__c: "",
                    Business_Street_Address_1__c: "",
                    Business_Street_Address_2__c: "",
                    Business_City__c: "",
                    Business_State__c: "",
                    Business_Zip_Code__c: "",
                    Business_Country__c: "",
                    Business_InternationalAddress__c: ""
                };
                this.setBusinessAddressFields();
                this.copyPrincipalAddressCheck = false;
            }
            if (this.showSecondScreen) {
                this.showHasBusinessAddressError = false;
            }
            if (this.editMode && this.isIndividualFlow && !this.showFourthScreen) {
                this.showThirdScreen = false;
                this.showFourthScreen = true;
                this.showSecondScreen = false;
                this.hasTable(true);
            } else if (this.editMode && this.isIndividualFlow) {
                this.showThirdScreen = false;
                this.showFourthScreen = false;
                this.showSecondScreen = true;
            } else {
                this.showThirdScreen = true;
                this.showFourthScreen = false;
                this.showSecondScreen = false;
            }
            this.selectedPrincipalAddressId = "";
            this.principalList = undefined;
            this.searchKey = "";
            this.showPrincipalError = false;
            this.showBusinessAddressForm = false;
            this.modalFocusTrap();
        }
    }

    hasTable(hasTable) {
        if (hasTable) {
            this.template.querySelector(".slds-modal").classList.remove("slds-modal_small");
            this.template.querySelector(".slds-modal").classList.add("slds-modal_large");
        } else {
            this.template.querySelector(".slds-modal").classList.remove("slds-modal_large");
            this.template.querySelector(".slds-modal").classList.add("slds-modal_small");
        }
    }

    gotoFourthScreen() {
        if (this.validateThirdScreen()) {
            this.showSecondScreen = false;
            this.showThirdScreen = false;
            this.showFourthScreen = true;
            var manualAddressEle = this.template.querySelector("c-brs_address.manualAddress");
            if (this.selectedPrincipalAddressId === "" && manualAddressEle) {
                var manualAddress = JSON.parse(JSON.stringify(manualAddressEle.getdata()));
                this.principal = {
                    ...this.principal,
                    Business_City__c: manualAddress.city,
                    Business_State__c: manualAddress.state,
                    Business_Street_Address_1__c: manualAddress.street,
                    Business_Street_Address_2__c: manualAddress.unit,
                    Business_Zip_Code__c: manualAddress.zip,
                    Business_InternationalAddress__c: manualAddress.internationalAddress,
                    Business_Country__c: manualAddress.country
                };
                this.principal = {
                    ...this.principal,
                    Business_Address_1__c: this.getFullBusinessAddress(this.principal)
                };
                this.setBusinessAddressFields();
            } else{
                if(this.editMode && !this.isIndividualFlow){
                    this.showBusinessAddressForm = !((this.principal.Business_Street_Address_1__c && this.principal.Business_City__c && this.principal.Business_State__c && this.principal.Business_Zip_Code__c) || (this.principal.Business_InternationalAddress__c));
                } 
            }
            this.hasTable(true);
            this.modalFocusTrap();
        }
    }

    validateFirstScreen() {
        if (this.principal.Principal_Type__c !== "") {
            this.principal = {
                ...this.principal,
                Principal_Type__c_Error: false
            }
            return true;
        } else {
            this.principal = {
                ...this.principal,
                Principal_Type__c_Error: true
            }
            return false;
        }
    }

    validateSecondScreen() {
        if (this.principal.Principal_Type__c === this.label.Individual_comparable) {
            if (this.showFourthScreen !== true) {
                let inputs = this.template.querySelectorAll('.principal-input');
                let combobox = this.template.querySelectorAll('.principal-combobox');
                inputs.forEach(field => {
                    field.reportValidity();
                });
                combobox[0].reportValidity();
                // Validate designation for first report
                const hasDisignatorError = this.validateDesignation();
                return !hasDisignatorError && this.principal.FirstName__c.trim() !== "" && this.principal.LastName__c.trim() !== "" && this.principal.Principal_Title__c !== "" && this.principal.Principal_Title__c !== undefined && !this.validateEmail();
            } else {
                return true;
            }
        } else {
            return true;
        }
    }

    validateThirdScreen() {
        if (this.isIndividualFlow) {
            const hasBusinessQuestionSelected = this.selectedBusinessDecision !== ""
            this.showHasBusinessAddressError = !hasBusinessQuestionSelected;
            return hasBusinessQuestionSelected;
        } else {
            if (this.showSecondScreen) {
                const hasPrincipal = this.selectedPrincipalAddressId !== "";
                this.showPrincipalError = !hasPrincipal;
                return hasPrincipal;
            }
            if (this.showThirdScreen) {
                const inputs = this.template.querySelectorAll('.principal-input');
                inputs[0].reportValidity();
                const manualAddressEle = this.template.querySelector("c-brs_address.manualAddress");
                const mValidate = manualAddressEle.validateaddress();
                return (this.principal.Business_Name__c !== "" && mValidate);
            }
        }
    }

    hasAllAddressFields() {
        const resAddress = this.template.querySelector("c-brs_address.residentialAddress");
        const rValidate = resAddress.validateaddress()
        let bValidate = true;
        if (this.hasBusinessAddress) {
            const businessAddress = this.template.querySelector("c-brs_address.busniessAddress");
            bValidate = businessAddress.validateaddress();
        }
        const raddress = JSON.parse(JSON.stringify(resAddress.getdata()));
        return (bValidate && rValidate);
    }


    onPrincipalRadioCheck(event) {
        this.principal = {
            ...this.initialData
        }
        this.selectedPrincipalAddressId = "";
        this.principalList = undefined;
        this.searchKey = "";
        // if coming from agent screen. retaining agent radio value.
        if (!this.showAgentDetails) {
            this.principal = {
                ...this.principal,
                hasAgentAsPrincipal: "No"
            }
        }
        this.principal = {
            ...this.principal,
            Principal_Type__c: event.detail.value
        }
        this.isIndividual();
    }

    isIndividual() {
        this.isIndividualFlow = (this.principal.Principal_Type__c === this.label.Individual_comparable);
    }

    handleFirstName(event) {
        this.principal = {
            ...this.principal,
            FirstName__c: event.target.value
        }
    }

    handleBlur(event){
        this.principal = {
            ...this.principal,
            [event.target.getAttribute('data-id')]: event.target.value.trim()
        }
    }

    handleLastName(event) {
        this.principal = {
            ...this.principal,
            LastName__c: event.target.value
        }
    }
    onTitleChange(event) {
        this.principal = {
            ...this.principal,
            Principal_Title__c: event.detail.value
        }
    }
    onEmailChange(event) {
        this.principal = {
            ...this.principal,
            Email__c: event.detail.value.trim().toLowerCase()
        }
    }

    //show/hide copy principal office address checkbox
    hasPrincipalOfficeAddress() {
        let hasTempAddress = false;
        if(this.isTempApis && !this.isInterim && this.tempHistory){
            let accTempRecValue = JSON.parse(JSON.stringify(this.tempHistory));
            hasTempAddress = accTempRecValue && 
                ((accTempRecValue.Billing_Country_New__c && accTempRecValue.BillingStreet_New__c && accTempRecValue.Billing_City_New__c && accTempRecValue.BillingState_New__c && accTempRecValue.BillingPostalCode_New__c) 
                || (accTempRecValue.Principle_Office_International_Address_N__c && accTempRecValue.Billing_Country_New__c));
            this.hasTempAddress = hasTempAddress;
        }        
        let accRecValue = JSON.parse(JSON.stringify(this.accountrecord));
        this.showCopyPrincipalAddressCheckbox = (accRecValue && 
        ((accRecValue.BillingCountry && accRecValue.BillingStreet && accRecValue.BillingCity && accRecValue.BillingState && accRecValue.BillingPostalCode) 
        || (accRecValue.Principle_Office_International_Address__c && accRecValue.BillingCountry)) || hasTempAddress);
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
            this.principal = {
                ...this.principal,
                Business_Street_Address_1__c,
                Business_Street_Address_2__c,
                Business_City__c,
                Business_State__c,
                Business_Zip_Code__c,
                Business_Country__c,
                Business_InternationalAddress__c
            }

        } else {
            this.copyPrincipalAddressCheck = false;
            this.principal = {
                ...this.principal,
                Business_Street_Address_1__c: "",
                Business_Street_Address_2__c: "",
                Business_City__c: "",
                Business_State__c: "",
                Business_Zip_Code__c: "",
                Business_InternationalAddress__c: "",
                Business_Country__c: ""
            }
        }
        this.setBusinessAddressFields();
    }

    onCopyBusinessAddressCheck(event) {
        var businessAddress = this.template.querySelector("c-brs_address.busniessAddress");
        var baddress = JSON.parse(JSON.stringify(businessAddress.getdata()));

        if (!this.copyBusinessAddressCheck) {
            this.copyBusinessAddressCheck = true;
            this.principal = {
                ...this.principal,
                Residence_Street_Address_1__c: baddress.street,
                Residence_Street_Address_2__c: baddress.unit ? baddress.unit : "",
                Residence_City__c: baddress.city,
                Residence_State__c: baddress.state,
                Residence_Zip_Code__c: baddress.zip,
                Residence_InternationalAddress__c: baddress.internationalAddress,
                Residence_Country__c: baddress.country
            }

        } else {
            this.copyBusinessAddressCheck = false;
            this.principal = {
                ...this.principal,
                Residence_Street_Address_1__c: "",
                Residence_Street_Address_2__c: "",
                Residence_City__c: "",
                Residence_State__c: "",
                Residence_Zip_Code__c: "",
                Residence_InternationalAddress__c: "",
                Residence_Country__c: ""
            };
        }

        this.setResidenceAddressFields();
    }

    getAllPrincipals() {
        this.isLoading = true;
        this.showErrorMessage = false;
        this.showNoChangeErrorMessage = false;
        if (this.isAnnualFlow || this.isInterim) {
            let payload = { sId: this.accountId, filingId: this.filingId };
            // getting all temp and original principals for annual flow
            getAllRecordsonLoad(payload).then((data) => {
                const tempPrincipals = data.tempRecListToSend.map((principal) => {
                    let modifled = {
                        ...principal,
                        isTempPrincipal: true,
                        Principal_Type__c: principal.Temp_Type__c,
                        Principal_Title__c: principal.Title__c,
                        Principal_Account_ID__r: principal.Account__r
                    }
                    return modifled;
                });
                const principals = [...data.l_PrincipalRec, ...tempPrincipals];
                this.modifyAllPrincipalsData(principals);
                if (this.isInterim && data.isPrincipalChanged) {
                    this.isPrincipalChanged = data.isPrincipalChanged;
                }
            }).catch((error) => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "getAllRecordsonLoad",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        } else if (this.isTempApis) {
            getTempRecordsonLoad({ sId: this.accountId, type: "Principal", filingId: this.filingId }).then((data) => {
                const principals = data.map((principal) => {
                    let modifled = {
                        ...principal,
                        Principal_Type__c: principal.Temp_Type__c,
                        Principal_Title__c: principal.Title__c,
                        Principal_Account_ID__r: principal.Account__r
                    }
                    return modifled;
                })
                this.modifyAllPrincipalsData(principals);
            }).catch((error) => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "getAllTempPrincipals",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });

        } else {
            getPrincipalRecordsonLoad({ sId: this.accountId }).then((data) => {
                this.modifyAllPrincipalsData(data);
            }).catch((error) => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "getAllPrincipals",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        }
    }

    capitalizeTitle(value){
        if(value && this.showTitle){
            let titleArray = value.split(" ");
            titleArray = titleArray.map((title)=>{
                return title.charAt(0).toUpperCase() + title.slice(1).toLowerCase();
            });
            return titleArray.join(" ");
        }else {
             return value;
        }
    }

    modifyAllPrincipalsData(data) {
        this.isLoading = false;
        this.principalListData = data.map((principal) => {
            var modifyPrincipal;
            if (principal.Principal_Type__c === this.label.Individual_comparable) {
                modifyPrincipal = {
                    ...principal,
                    isIndividual: true,
                    Principal_Title__c: this.capitalizeTitle(principal.Principal_Title__c),
                    Designation__c: principal.Designation__c ? principal.Designation__c.replace(";","/"):"",
                    hasEmail: principal.Email__c && principal.Email__c !== "",
                    hasBusinessAddress: this.hasBusinessValues(principal),
                    Business_Address_1__c: this.getFullBusinessAddress(principal),
                    Residence_Address_1__c: this.getFullResidenceAddress(principal),
                    cardClassName:"principal-list"
                }
            } else {
                modifyPrincipal = {
                    ...principal,
                    Principal_Title__c: this.capitalizeTitle(principal.Principal_Title__c), 
                    hasEmail: principal.Email__c && principal.Email__c !== "",
                    hasBusinessAddress: true,
                    isIndividual: false,
                    Business_Address_1__c: this.getFullBusinessAddress(principal),
                    cardClassName:"principal-list"
                }
            }
            return modifyPrincipal;

        });
        this.checkPrincipalLength();
        const selectedEvent = new CustomEvent("addprincipal", {
            detail: this.principalListData
        });
        this.dispatchEvent(selectedEvent);
    }

    hasBusinessValues(principal) {
        return (principal.Business_Zip_Code__c && principal.Business_Zip_Code__c !== "") || (principal.Business_InternationalAddress__c && principal.Business_InternationalAddress__c !== "");
    }

    getFullBusinessAddress(principal) {
        const addressArray = [];
        if (principal.Business_Street_Address_1__c) {
            addressArray.push(principal.Business_Street_Address_1__c);
        }
        if (principal.Business_Street_Address_2__c) {
            addressArray.push(principal.Business_Street_Address_2__c);
        }
        if (principal.Business_Street_Address_3__c) {
            addressArray.push(principal.Business_Street_Address_3__c);
        }
        if (principal.Business_City__c) {
            addressArray.push(principal.Business_City__c);
        }
        if (principal.Business_State__c) {
            addressArray.push(principal.Business_State__c);
        }
        if (principal.Business_Zip_Code__c) {
            addressArray.push(principal.Business_Zip_Code__c);
        }
        if (principal.Business_InternationalAddress__c) {
            addressArray.push(principal.Business_InternationalAddress__c);
        }
        if (principal.Business_Country__c) {
            addressArray.push(principal.Business_Country__c);
        }
        return addressArray.join(", ");
    }

    getFullResidenceAddress(principal) {
        const addressArray = [];
        if (principal.Residence_Street_Address_1__c) {
                addressArray.push(principal.Residence_Street_Address_1__c);
              }
        if (principal.Residence_Street_Address_2__c) {
            addressArray.push(principal.Residence_Street_Address_2__c);
        }
        if (principal.Residence_Street_Address_3__c) {
            addressArray.push(principal.Residence_Street_Address_3__c);
        }
        if (principal.Residence_City__c) {
            addressArray.push(principal.Residence_City__c);
        }
        if (principal.Residence_State__c) {
            addressArray.push(principal.Residence_State__c);
        }
        if (principal.Residence_Zip_Code__c) {
            addressArray.push(principal.Residence_Zip_Code__c);
        }
        if (principal.Residence_InternationalAddress__c) {
            addressArray.push(principal.Residence_InternationalAddress__c);
        }
        if (principal.Residence_Country__c) {
            addressArray.push(principal.Residence_Country__c);
        }
        return addressArray.join(", ");
    }

    handleSearchBusiness(event) {
        this.selectedPrincipalAddressId = "";
        this.showPrincipalError = false;
        this.searchKey = event.detail;
    }

    handleGetResults(event) {
        this.principalList = event.detail;
    }

    onPrincipalListRadioCheck(event) {
        var selected = event.detail;
        this.selectedRadio = selected.Id;
        this.showPrincipalError = false;
        const BillingCity = selected.BillingCity ? selected.BillingCity : "";
        const BillingState = selected.BillingState ? selected.BillingState : "";
        const BillingPostalCode = selected.BillingPostalCode ? selected.BillingPostalCode : "";
        const BillingCountry = selected.BillingCountry ? selected.BillingCountry : "";
        const BillingStreet = selected.BillingStreet ? selected.BillingStreet : "";
        const BillingUnit = selected.Billing_Unit__c ? selected.Billing_Unit__c : "";
        const BillingInternational = selected.Principle_Office_International_Address__c ? selected.Principle_Office_International_Address__c:"";
        this.selectedPrincipalAddressId = {
            ...selected,
            Business_ID__c: selected.Id,
            BillingCity,
            BillingState,
            BillingPostalCode,
            BillingCountry,
            BillingStreet,
            BillingUnit,
            BillingInternational
        };
        const showBusinessAddress = !((BillingStreet && BillingCity && BillingState && BillingCountry && BillingPostalCode) || (BillingCountry && BillingInternational));
        this.showBusinessAddressForm = showBusinessAddress;
        if(showBusinessAddress){
            this.businessAddressFields = {
                addressStreet: BillingStreet,
                addressUnit: BillingUnit,
                addressCity: BillingCity,
                addressState: BillingState,
                addressZip: BillingPostalCode,
                addressInternational: BillingInternational,
                addressCountry: BillingCountry
            }
        }
        this.principal = {
            ...this.principal,
            Name__c: selected.Name,
            AccountNumber: selected.AccountNumber,
            Business_Address_1__c: selected.Business_Address_1__c
        };
    }

    onBusinessNameChange(event) {
        this.principal = {
            ...this.principal,
            Business_Name__c: event.target.value
        }
    }

    submitIndividualPrincipalForm() {
        if (this.hasAllAddressFields()) {
            this.spinner = true;
            var principal;
            if (this.hasBusinessAddress) {
                var businessAddress = this.template.querySelector("c-brs_address.busniessAddress");
                var baddress = JSON.parse(JSON.stringify(businessAddress.getdata()));
                principal = {
                    Business_City__c: baddress.city,
                    Business_Street_Address_1__c: baddress.street,
                    Business_Street_Address_2__c: baddress.unit ? baddress.unit : "",
                    Business_Zip_Code__c: baddress.zip,
                    Business_State__c: baddress.state,
                    Business_Country__c: baddress.country,
                    Business_InternationalAddress__c: baddress.internationalAddress
                }
            }
            var resAddress = this.template.querySelector("c-brs_address.residentialAddress");
            if (resAddress) {
                var raddress = JSON.parse(JSON.stringify(resAddress.getdata()));
                principal = {
                    ...principal,
                    Principal_Title__c: this.principal.Principal_Title__c,
                    FirstName__c: this.principal.FirstName__c,
                    LastName__c: this.principal.LastName__c,
                    Name__c: this.principal.FirstName__c + " " + this.principal.LastName__c,
                    Email__c: this.principal.Email__c,
                    Principal_Type__c: this.principal.Principal_Type__c,
                    Residence_City__c: raddress.city,
                    Residence_Street_Address_1__c: raddress.street,
                    Residence_Street_Address_2__c: raddress.unit ? raddress.unit : "",
                    Residence_Zip_Code__c: raddress.zip,
                    Residence_State__c: raddress.state,
                    Residence_Country__c: raddress.country,
                    Residence_InternationalAddress__c: raddress.internationalAddress,
                    Principal_Account_ID__c: this.accountId,
                    Business_ID__c: this.accountId
                }
            }
            if (this.isAnnualFlow && !this.principal.isTempPrincipal && this.principal.Id) {
                principal = {
                    ...principal,
                    Principal__c: this.principal.Id
                }
                this.createPrincipalRecord(principal);
            } else if (this.principal.Id) {
                this.updateExistingPrincipalRecord({
                    ...principal,
                    Id: this.principal.Id
                });
            } else {
                this.createPrincipalRecord(principal);
            }

        }
    }

    editPrincipal(event) {
        this.resetForm();
        this.editMode = true;
        var index = event.currentTarget.dataset.name;
        this.isIndividualFlow = this.principalListData[index].Principal_Type__c === this.label.Individual_comparable;
        this.principal = {
            ...this.initialData,
            ...this.principalListData[index]
        }
        this.showAddPrincipalPopup = !this.showAddPrincipalPopup;
        document.body.style.overflow = 'hidden';

        if (this.isIndividualFlow) {
            this.hasBusinessAddress = this.principal.Business_Zip_Code__c !== "" || this.principal.Business_InternationalAddress__c !== "";
            this.setBusinessAddressFields();
            this.setResidenceAddressFields();
            this.showFirstScreen = false;
            this.showSecondScreen = true;
            this.setDesignationCheckBoxCheck();
            this.businessAddressCheckboxOptions = [{
                ...this.businessAddressCheckboxOptions[0],
                isChecked: false,
                isDisabled: false
            }];
            if(this.isAnnualFlow){
                this.enableInputs = !this.principal.FirstName__c || !this.principal.LastName__c;
            }
        } else {
            this.setBusinessAddressFields();
            if (this.principal.Business_Name__c) {
                this.showFirstScreen = false;
                this.showSecondScreen = false;
                this.showThirdScreen = true;
            } else {
                this.showFirstScreen = false;
                this.showSecondScreen = true;
                const principalData = this.principalListData[index];

                this.selectedPrincipalAddressId = {
                    ...principalData,
                    BillingCity: principalData.Business_City__c,
                    BillingStreet: principalData.Business_Street_Address_1__c,
                    BillingPostalCode: principalData.Business_Zip_Code__c,
                    BillingState: principalData.Business_State__c,
                    BillingCountry: principalData.Business_Country__c,
                    BillingUnit: principalData.Business_Street_Address_2__c,
                    BillingInternational : principalData.Business_InternationalAddress__c
                };
                const AccountNumber = principalData.Principal_Account_ID__r ? principalData.Principal_Account_ID__r.AccountNumber :"";
                this.principal = {
                    ...this.principal,
                    Name__c: principalData.Name__c,
                    AccountNumber,
                    Business_Address_1__c: this.getFullBusinessAddress(principalData)
                }
                this.principalList = [{
                    checked: true,
                    Name: principalData.Name__c,
                    AccountNumber,
                    Business_Address_1__c: this.getFullBusinessAddress(principalData)
                }];
                setTimeout(() => {
                    this.hasTable(true);
                }, 400);
            }
            if(this.isAnnualFlow){
                this.enableInputs = !this.principal.Name__c && !this.principal.Business_Name__c
            }
        }
        this.modalFocusTrap();
    }

    setDesignationCheckBoxCheck() {
        if (this.principal.Designation__c) {
            const isDesignationOfficerChecked = this.principal.Designation__c.includes(this.label.Officer)
            const isDesignationDirectorChecked = this.principal.Designation__c.includes(this.label.Director);
            this.principal = {
                ...this.principal,
                isDesignationOfficerChecked,
                isDesignationDirectorChecked
            }
        }
    }

    isTitleAndEmailValidate() {
        const combobox = this.template.querySelectorAll('.principal-combobox');
        combobox[0].reportValidity();
        let businessAddressFilled = true;
        if(this.showBusinessAddressForm) {
            const manualAddressEle = this.template.querySelector("c-brs_address.manualAddress");
            businessAddressFilled = manualAddressEle.validateaddress();
            if(businessAddressFilled){
                var manualAddress = JSON.parse(JSON.stringify(manualAddressEle.getdata()));
                this.selectedPrincipalAddressId = {
                    ...this.selectedPrincipalAddressId,
                    BillingStreet:manualAddress.street,
                    BillingUnit:manualAddress.unit,
                    BillingCity:manualAddress.city,
                    BillingPostalCode:manualAddress.zip,
                    BillingState:manualAddress.state,
                    BillingCountry:manualAddress.country,
                    BillingInternational: manualAddress.internationalAddress
                }
            }
        }
        return !this.validateEmail() && this.principal.Principal_Title__c !== "" && this.principal.Principal_Title__c!== undefined && businessAddressFilled;
    }

    validateEmail() {
        let emailError = false;
        const email = this.template.querySelectorAll('.principal-email');
        if (email) {
            if (this.principal.Email__c !== "" && !this.principal.Email__c.match(this.emailPattern)) {
                email[0].setCustomValidity(this.label.GenericInput_Invalid_Email);
                email[0].reportValidity();
                emailError = true;
            } else {
                email[0].setCustomValidity("");
                email[0].reportValidity();
            }
        }
        return emailError;
    }

    submitBusinessPrincipalForm() {
        if (this.isTitleAndEmailValidate()) {
            this.spinner = true;
            var principal;
            if (this.selectedPrincipalAddressId) {
                principal = {
                    Principal_Title__c: this.principal.Principal_Title__c,
                    Email__c: this.principal.Email__c,
                    Principal_Type__c: this.principal.Principal_Type__c,
                    Name__c: this.principal.Name__c,
                    Business_ID__c: this.accountId,
                    Business_City__c: this.selectedPrincipalAddressId.BillingCity,
                    Business_Street_Address_1__c: this.selectedPrincipalAddressId.BillingStreet,
                    Business_Street_Address_2__c: this.selectedPrincipalAddressId.BillingUnit,
                    Business_Zip_Code__c: this.selectedPrincipalAddressId.BillingPostalCode,
                    Business_InternationalAddress__c: this.selectedPrincipalAddressId.BillingInternational,
                    Business_State__c: this.selectedPrincipalAddressId.BillingState,
                    Business_Country__c: this.selectedPrincipalAddressId.BillingCountry,
                    Principal_Account_ID__c: this.selectedPrincipalAddressId.Business_ID__c
                };
            } else {
                principal = {
                    Principal_Type__c: this.principal.Principal_Type__c,
                    Business_Name__c: this.principal.Business_Name__c,
                    Name__c: this.principal.Business_Name__c,
                    Business_City__c: this.principal.Business_City__c,
                    Business_State__c: this.principal.Business_State__c,
                    Business_Street_Address_1__c: this.principal.Business_Street_Address_1__c,
                    Business_Street_Address_2__c: this.principal.Business_Street_Address_2__c,
                    Business_Zip_Code__c: this.principal.Business_Zip_Code__c,
                    Business_InternationalAddress__c: this.principal.Business_InternationalAddress__c,
                    Business_Country__c: this.principal.Business_Country__c,
                    Principal_Title__c: this.principal.Principal_Title__c,
                    Email__c: this.principal.Email__c,
                    Business_ID__c: this.accountId,
                    Principal_Account_ID__c: this.accountId
                }
            }
            if (this.isAnnualFlow && !this.principal.isTempPrincipal && this.principal.Id) {
                principal = {
                    ...principal,
                    Principal__c: this.principal.Id
                }
                this.createPrincipalRecord(principal);
            } else if (this.principal.Id) {
                principal = {
                    ...principal,
                    Id: this.principal.Id
                };
                this.updateExistingPrincipalRecord(principal);
            } else {
                this.createPrincipalRecord(principal);
            }
        }
    }

    validateDesignation() {
        //Validating Disignation only for first report
        let hasDisignatorError = false;
        if (this.showDesignationCheckBoxes && !this.principal.isDesignationOfficerChecked && !this.principal.isDesignationDirectorChecked) {
            this.principal = {
                ...this.principal,
                showDisignationError: true
            }
            hasDisignatorError = true;
        }
        return hasDisignatorError;
    }

    validateAgentDetails() {
        if (this.isIndividualFlow) {
            var hasDisignatorError = this.validateDesignation();
        }
        //Title validation
        let titleError = false;
        if (!this.principal.Principal_Title__c) {
            const combobox = this.template.querySelectorAll('.principal-combobox');
            combobox[0].reportValidity();
            titleError = true;
        }

        return !hasDisignatorError && !titleError;

    }

    get getDesignationValueForTable() {
        return this.getDesignationValue("/");
    }

    getDesignationValue(separator) {
        let designation = "";
        if (this.principal.isDesignationOfficerChecked) {
            designation += "Officer";
        }
        if (designation !== "" && this.principal.isDesignationDirectorChecked) {
            designation += separator;
        }
        if (this.principal.isDesignationDirectorChecked) {
            designation += Director;
        }
        return designation;
    }

    submitAgenDetails() {
        if (this.validateAgentDetails()) {
            this.spinner = true;
            var principal = {
                Created_From_Agent__c: true,
                Principal_Title__c: this.principal.Principal_Title__c,
                Principal_Type__c: this.principal.Principal_Type__c,
                Principal_Account_ID__c: this.principal.Principal_Type__c === this.label.Individual_comparable ? this.accountId: this.agentData.Agent_Account_ID__c,
                Business_ID__c: this.accountId,
                Business_City__c: this.principal.Business_City__c,
                Business_State__c: this.principal.Business_State__c,
                Business_Street_Address_1__c: this.principal.Business_Street_Address_1__c,
                Business_Street_Address_2__c: this.principal.Business_Street_Address_2__c,
                Business_Zip_Code__c: this.principal.Business_Zip_Code__c,
                Business_InternationalAddress__c: this.principal.Business_InternationalAddress__c,
                Business_Country__c: this.principal.Business_Country__c,
                Email__c: this.principal.Email__c
            }
            if (this.principal.Principal_Type__c === this.label.Individual_comparable) {
                principal = {
                    ...principal,
                    FirstName__c: this.principal.FirstName__c,
                    LastName__c: this.principal.LastName__c,
                    Residence_City__c: this.principal.Residence_City__c,
                    Residence_Street_Address_1__c: this.principal.Residence_Street_Address_1__c,
                    Residence_Street_Address_2__c: this.principal.Residence_Street_Address_2__c,
                    Residence_Zip_Code__c: this.principal.Residence_Zip_Code__c,
                    Residence_State__c: this.principal.Residence_State__c,
                    Residence_Country__c: this.principal.Residence_Country__c,
                    Residence_InternationalAddress__c: this.principal.Residence_InternationalAddress__c,
                    Name__c: this.principal.FirstName__c + " " + this.principal.LastName__c,
                }
            } else {
                principal = {
                    ...principal,
                    Name__c: this.principal.Name__c
                }
            }
            this.createPrincipalRecord(principal);
        }
    }

    updateExistingPrincipalRecord(principal) {
        if (this.isTempApis) {
            const designation = this.getDesignationValue(";");
            delete principal.Principal_Account_ID__c;
            delete principal.Principal_Type__c;
            delete principal.Principal_Title__c;
            principal = {
                ...principal,
                Type__c: "Principal",
                Temp_Type__c: this.principal.Principal_Type__c,
                Title__c: this.principal.Principal_Title__c,
                Designation__c: designation,
                Account__c: this.accountId
            };

            upsertTempRecord({ tempRec: principal }).then((data) => {
                this.spinner = false;
                this.showAddPrincipalPopup = false;
                document.body.style.overflow = '';
                this.resetForm();
                this.getAllPrincipals();
            }).catch((error) => {
                this.spinner = false;
                ComponentErrorLoging(
                    this.compName,
                    "updateExistingTempPrincipalRecord",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });

        } else {
            const designation = this.getDesignationValue(";");
            updatePrincipalRecord({ principalRec: {...principal, Designation__c: designation} }).then((data) => {
                this.spinner = false;
                this.showAddPrincipalPopup = false;
                document.body.style.overflow = '';
                this.resetForm();
                this.getAllPrincipals();
            }).catch((error) => {
                this.spinner = false;
                ComponentErrorLoging(
                    this.compName,
                    "updateExistingPrincipalRecord",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        }

    }

    createPrincipalRecord(principal) {
        if (this.isTempApis) {
            const designation = this.getDesignationValue(";");
            delete principal.Principal_Type__c;
            delete principal.Principal_Title__c;
            principal = {
                ...principal,
                Type__c: "Principal",
                Temp_Type__c: this.principal.Principal_Type__c,
                Title__c: this.principal.Principal_Title__c,
                Designation__c: designation,
                Account__c: this.principal.Principal_Type__c === this.label.Individual_comparable ? this.accountId:  principal.Principal_Account_ID__c,
                Business_ID__c: this.accountId,
                Business_Filing__c: this.filingId,
                Change_Type__c: principal.Principal__c ? "Edited" : "Created"
            }

            upsertTempRecord({ tempRec: principal }).then((data) => {
                this.spinner = false;
                this.showAddPrincipalPopup = false;
                document.body.style.overflow = '';
                this.resetForm();
                this.getAllPrincipals();
            }).catch((error) => {
                this.spinner = false;
                ComponentErrorLoging(
                    this.compName,
                    "insertPrincipalTempRecord",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        } else {
            const designation = this.getDesignationValue(";");
            insertPrincipalRecord({ principalRec: { ...principal, Designation__c: designation}}).then((data) => {
                this.spinner = false;
                this.showAddPrincipalPopup = false;
                document.body.style.overflow = '';
                this.resetForm();
                this.getAllPrincipals();
            }).catch((error) => {
                this.spinner = false;
                ComponentErrorLoging(
                    this.compName,
                    "createPrincipalRecord",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        }

    }


    // showing confirmation popup for annual flow
    onShowDeleteConfirmation(event) {
        var id = event.currentTarget.dataset.id;
        const index = event.currentTarget.dataset.name;
        let removePrincipal = this.principalListData[index];
        if (removePrincipal.Principal_Type__c === this.label.Individual_comparable) {
            removePrincipal = {
                ...removePrincipal,
                isIndividual: true,
                hasEmail: removePrincipal.Email__c && removePrincipal.Email__c !== "",
                hasBusinessAddress: this.hasBusinessValues(removePrincipal),
                Business_Address_1__c: this.getFullBusinessAddress(removePrincipal),
                Residence_Address_1__c: this.getFullResidenceAddress(removePrincipal)
            }
        } else {
            removePrincipal = {
                ...removePrincipal,
                hasEmail: removePrincipal.Email__c && removePrincipal.Email__c !== "",
                hasBusinessAddress: true,
                isIndividual: false,
                Business_Address_1__c: this.getFullBusinessAddress(removePrincipal)
            }
        }
        this.principal = {
            ...this.principal,
            ...removePrincipal
        }
        this.showHideDeletePrincipal("show");
    }

    showHideDeletePrincipal(status) {
        if (status === "show") {
            document.body.style.overflow = 'hidden';
            this.showDeleteConfirmation = true;
            this.modalFocusTrap();
        } else {
            document.body.style.overflow = '';
            this.showDeleteConfirmation = false;
            this.principal = {
                ...this.initialData
            };
        }
    }

    showHideDeletePrincipalKeyPress(event){
        if (event.keyCode === 13 || event.keyCode == 32) {
            document.body.style.overflow = '';
            this.showDeleteConfirmation = false;
            this.principal = {
                ...this.initialData
            };
        }
    }

    deletePrincipal(event) {
        this.isLoading = true;
        var id = event.currentTarget.dataset.id;
        if ((this.isAnnualFlow || this.isInterim) && !this.principal.isTempPrincipal) {
            let principal = {
                Type__c: "Principal",
                Change_Type__c: "Deleted",
                Principal__c: id,
                Principal_ID_Information__c: id,
                Account__c: this.accountId,
                Business_ID__c: this.accountId,
                Business_Filing__c: this.filingId
            };
            upsertTempRecord({ tempRec: principal }).then((data) => {
                this.spinner = false;
                this.showHideDeletePrincipal("hide");
                this.getAllPrincipals();
            }).catch((error) => {
                this.spinner = false;
                ComponentErrorLoging(
                    this.compName,
                    "upsertTempRecord",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        } else if (this.isTempApis) {
            let temp = [{
                Id: id,
                sobjectType: "Temp_History__c",
                Change_Type__c: "Deleted"
            }];
            deleteRecords({ objects: temp }).then((data) => {
                if (this.isAnnualFlow || this.isInterim) {
                    this.showHideDeletePrincipal("hide");
                }
                this.isLoading = false;
                this.getAllPrincipals();
            }).catch((error) => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "deleteTempPrincipal",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        } else {
            deletePrincipalRecord({ sId: id }).then((data) => {
                this.isLoading = false;
                this.getAllPrincipals();
            }).catch((error) => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "deletePrincipal",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        }
    }

    resetForm() {
        this.showZeroScreen = false;
        this.showFirstScreen = true;
        this.showSecondScreen = false;
        this.showThirdScreen = false;
        this.showFourthScreen = false;
        this.showPrincipalError = false;
        this.showHasBusinessAddressError = false;
        this.selectedBusinessDecision = "";
        this.editMode = false;
        this.principal = {
            ...this.initialData
        };
        this.selectedPrincipalAddressId = "";
        this.showBusinessAddressForm = false;
        this.principalList = undefined;
        this.searchKey = "";
        this.noPrincipalList = false;
        this.copyPrincipalAddressCheck = false;
        this.copyBusinessAddressCheck = false;
        this.businessAddressFields = {
            ...this.initialAddressFields
        };
        this.residenceAddressFields = {
            ...this.initialAddressFields
        }
        this.businessAddressCheckboxOptions = [{
            ...this.businessAddressCheckboxOptions[0],
            isChecked: false,
            isDisabled: true
        }];
    }

    onAccordianClick(event) {
        var index = Number(event.currentTarget.dataset.name);
        this.principalListData = this.principalListData.map((principal, i) => {
            return {
                ...principal,
                showDetails: principal.showDetails ? false : (i === index)
            }
        })
    }

    //First report Designation checkbox check
    onDesignationOfficerCheck(e) {
        const checked = !this.principal.isDesignationOfficerChecked;
        let title = checked ? "" : this.principal.Principal_Title__c;
        if (!checked && this.principal.isDesignationDirectorChecked) {
            title = this.label.Director;
        }
        this.principal = {
            ...this.principal,
            isDesignationOfficerChecked: checked,
            showDisignationError: false,
            Principal_Title__c: title
        }
    }

    onDesignationDirectorCheck() {
        let title = "";
        const checked = !this.principal.isDesignationDirectorChecked;
        if (checked && !this.principal.isDesignationOfficerChecked) {
            title = this.label.Director;
            const titleComboBox = this.template.querySelectorAll('.principal-title');
            if (titleComboBox) {
                setTimeout(() => {
                    titleComboBox[0].reportValidity();
                }, 50);
            }
        }
        this.principal = {
            ...this.principal,
            isDesignationDirectorChecked: checked,
            showDisignationError: false,
            Principal_Title__c: title
        }
    }

    closeConfirmationModal() {
        this.showConfirmationModal = false;
    }

    closeConfirmationModalKeyPress(event) {
        if (event.keyCode === 13 || event.keyCode == 32) {
            this.showConfirmationModal = false;
        }
    }

    goToSummaryPage() {
        this.showConfirmationModal = false;
        const attributeChangeEvent = new FlowAttributeChangeEvent('showConfirmationModal', false);
        this.dispatchEvent(attributeChangeEvent);
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }

    /**
    * @function goToSearchBusiness - method written for handlick Back button click
    * @param none
    */
    handleBack() {
        if (this.goToDashBoardPage) {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: this.label.brs_FIlingLandingPage
                },
            });
        } else {
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        }
    }

    // Redirect to summary page for annual flow
    goToSummaryPageWithOutConfirmation() {
        if(this.isAnnualFlow || this.isFirstFlow){
            if(!this.isAnyMandatoryFieldMissing()){
                this.gotoNextScreen();
            } else {
                this.showNoChangeErrorMessage = true;
                this.errorMessage = this.label.Principal_Information_missing_message;
            }
        } else{
            this.gotoNextScreen();
        }
    }

    gotoNextScreen(){
        this.noConfirmation = true;
        this.isGoToSummary = true;
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }

    //get agent as principal table view data
    get getAgentPrincipalColumns() {
        let tablecolumns;
        if (this.isIndividualFlow) {
            tablecolumns = [{
                label: this.label.Name,
                fieldName: 'Name__c',
                sortable: false
            },
            {
                label: this.label.Email_Address,
                fieldName: 'Email__c',
                sortable: false
            },
            {
                label: this.label.brs_Business_Address,
                fieldName: 'Business_Address_1__c',
                sortable: false
            },
            {
                label: this.label.brs_Residence_Address,
                fieldName: 'Residence_Address_1__c',
                sortable: false
            }
            ];
        } else {
            tablecolumns = [{
                label: this.label.Business_ID,
                fieldName: 'AccountNumber',
                sortable: false
            },
            {
                label: this.label.Name,
                fieldName: 'Name__c',
                sortable: false
            },
            {
                label: this.label.brs_Business_Address,
                fieldName: 'Business_Address_1__c',
                sortable: false
            }
            ];
        }
        if (!this.principal.hasBusinessAddress) {
            this.agentAsPrincipalTableData = [{ ...this.principal, Business_Address_1__c: this.label.None }]
        } else {
            this.agentAsPrincipalTableData = [{ ...this.principal }]
        }
        return tablecolumns;
    }

    //get individual principal table view data
    get getIndividualPrincipalColumns() {
        let tablecolumns = [{
            label: this.label.Name,
            fieldName: 'Name__c',
            sortable: false
        },
        {
            label: this.label.Designation,
            fieldName: 'Designation__c',
            sortable: false
        },
        {
            label: this.label.Title,
            fieldName: 'Principal_Title__c',
            sortable: false
        },
        {
            label: this.label.Email_Address,
            fieldName: 'Email__c',
            sortable: false
        }
        ];
        if (!this.showDesignationCheckBoxes) {
            tablecolumns.splice(1, 1);
        }
        this.individualPrincipalTableData = [{
            ...this.principal,
            Name__c: `${this.principal.FirstName__c} ${this.principal.LastName__c}`,
            Designation__c: this.getDesignationValue("/")
        }];
        return tablecolumns;
    }

    //get business principal table view data
    get getBusinessPrincipalColumns() {
        let tablecolumns = [{
            label: this.label.Business_ID,
            fieldName: 'AccountNumber',
            sortable: false
        },
        {
            label: this.label.Name,
            fieldName: 'Name__c',
            sortable: false
        },
        {
            label: this.label.brs_Business_Address,
            fieldName: 'Business_Address_1__c',
            sortable: false
        }
        ];
        if (this.selectedPrincipalAddressId) {
            this.businessPrincipalTableData = [{
                ...this.principal
            }];
        } else {
            this.businessPrincipalTableData = [{
                ...this.principal,
                AccountNumber: this.label.not_applicable,
                Name__c: this.principal.Business_Name__c
            }];
        }
        return tablecolumns;
    }

    //Disable or enable copy business address checkbox based on Business address fields
    onBusinessAddressChange(event) {
        const address = JSON.parse(JSON.stringify(event.detail));
        let isDisabled = true;
        this.copyBusinessAddressCheck = false;
        if ((address.street && address.city && address.state && address.zip &&
            (address.zip.length === 5 || address.zip.length === 10)) ||
            (address.internationalAddress !== "" && address.country !== "")) {
            isDisabled = false;
        }
        this.businessAddressCheckboxOptions = [{
            ...this.businessAddressCheckboxOptions[0],
            isChecked: false,
            isDisabled
        }];
    }
    modalFocusTrap(){
        setTimeout(() => {
            focusTrap(this.template);
        }, 250);
    }
}
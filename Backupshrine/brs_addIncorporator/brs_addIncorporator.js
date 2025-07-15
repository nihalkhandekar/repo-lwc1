import { LightningElement, track, wire, api } from 'lwc';
import { fireEvent, registerListener } from 'c/commonPubSub';
import { CurrentPageReference } from "lightning/navigation";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import updateIncorporatorRecord from '@salesforce/apex/brs_contactDetailPage.updateIncorporatorRecord';
import deleteIncorporatorRecord from '@salesforce/apex/brs_contactDetailPage.deleteIncorporatorRecord';
import getIncorporatorRecordsonLoad from '@salesforce/apex/brs_contactDetailPage.getIncorporatorRecordsonLoad';
import insertIncorporatorRecord from '@salesforce/apex/brs_contactDetailPage.insertIncorporatorRecord';
import { emailPattern } from "c/appUtility";
import { focusTrap } from "c/appUtility";
import { ComponentErrorLoging } from "c/formUtility";
import GenericInput_Invalid_Email from "@salesforce/label/c.GenericInput_Invalid_Email";
import brs_Add_Incorporator from '@salesforce/label/c.brs_Add_Incorporator';
import brs_Add_Incorporator_ErrorMsg from '@salesforce/label/c.brs_Add_Incorporator_ErrorMsg';
import brs_Add_Incorporator_OptionSelectionDesc from '@salesforce/label/c.brs_Add_Incorporator_OptionSelectionDesc';
import brs_Add_Incorporator_SelectType from '@salesforce/label/c.brs_Add_Incorporator_SelectType';
import brs_Add_Incorporator_Manually from '@salesforce/label/c.brs_Add_Incorporator_Manually';
import fields_Mandatory from '@salesforce/label/c.fields_Mandatory';
import brs_Add_More from '@salesforce/label/c.brs_Add_More';
import Name from '@salesforce/label/c.Name';
import Email_Address from '@salesforce/label/c.Email_Address';
import Edit from '@salesforce/label/c.Edit';
import Remove from '@salesforce/label/c.Remove'
import Next from '@salesforce/label/c.Next';
import Confirm from '@salesforce/label/c.Confirm';
import Back from '@salesforce/label/c.Back';
import Individual from '@salesforce/label/c.Individual';
import business from '@salesforce/label/c.business';
import businessProfile_Incorporator from '@salesforce/label/c.businessProfile_Incorporator';
import Agent_Individual_Option from '@salesforce/label/c.Individual';
import Business_Name_Required from '@salesforce/label/c.Business_Name_Required';
import First_Name_Required from '@salesforce/label/c.First_Name_Required';
import Last_Name_Required from '@salesforce/label/c.Last_Name_Required';
import Label_Address from '@salesforce/label/c.Label_Address';
import Show_incorporator_details from '@salesforce/label/c.Show_incorporator_details'; 
import modal_close from '@salesforce/label/c.modal_close';
import brs_InterimNotice_PrincipalScreenPrincipalOptions from '@salesforce/label/c.brs_InterimNotice_PrincipalScreenPrincipalOptions';
import AccountRecordType_Business from '@salesforce/label/c.AccountRecordType_Business';
import brs_InterimNotice_PrincipalScreenPrincipalOptions2 from '@salesforce/label/c.brs_InterimNotice_PrincipalScreenPrincipalOptions2';
import Individual_Label from '@salesforce/label/c.Individual_Label';
import Individual_Label_text from '@salesforce/label/c.Individual_Label_text';
import brs_PrincipalType_Business from "@salesforce/label/c.brs_PrincipalType_Business";
import First_Name_Placeholder from '@salesforce/label/c.First_Name_Placeholder';
import Last_Name_Placeholder from '@salesforce/label/c.Last_Name_Placeholder';
import EmailPlaceHolder from '@salesforce/label/c.EmailPlaceHolder';
import business_name_placeholder from '@salesforce/label/c.business_name_placeholder';
import Incorporator_modal from '@salesforce/label/c.Incorporator_modal';
import Business_Comparable from '@salesforce/label/c.Business_Comparable';
import AddressUnit_Apt from '@salesforce/label/c.AddressUnit_Apt';

export default class Brs_addIncorporator extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @api source = "Worker Portal";
    @track addIcon = assetFolder + "/icons/add-circle-outline.svg";
    @track editIcon = assetFolder + "/icons/edit-blue.svg";
    @track deleteIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track closeIcon = assetFolder + "/icons/close-outline-blue.svg";
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track arrowIcon = assetFolder + "/icons/chevron-right-blue.svg";
    @track compName = "brs_addIncorporator";
    @api accountrecord;
    @api incorporatorListData = [];
    @track isLoading = false;
    @track spinner = false;
    @track showErrorMessage = false;
    @track showAddIncorporatorPopup = false;
    @track isIndividualFlow = false;
    @track showFirstScreen = false;
    @track showSecondScreen = false;
    @track editMode = false;
    @track accountId;
    @track hideAddButton = false;
    @track emailPattern = emailPattern;
    label = {
        brs_Add_Incorporator,
        brs_Add_Incorporator_ErrorMsg,
        brs_Add_Incorporator_OptionSelectionDesc,
        brs_Add_Incorporator_SelectType,
        brs_Add_Incorporator_Manually,
        fields_Mandatory,
        brs_Add_More,
        Name,
        Email_Address,
        Edit,
        Remove,
        Next,
        Confirm,
        Back,
        Individual,
        business,
        GenericInput_Invalid_Email,
        businessProfile_Incorporator,
        Agent_Individual_Option,
        Business_Name_Required,
        First_Name_Required,
        Last_Name_Required,
        Label_Address,
        Show_incorporator_details,
        modal_close,
        brs_InterimNotice_PrincipalScreenPrincipalOptions,
        AccountRecordType_Business,
        brs_PrincipalType_Business,
        Individual_Label_text,
        First_Name_Placeholder,
        Last_Name_Placeholder,
        EmailPlaceHolder,
        business_name_placeholder,
        Incorporator_modal,
		AddressUnit_Apt
    }
    @track initialData = {
        Email: "",
        Id: "",
        Type__c: "",
        FirstName: "",
        LastName: "",
        Business_Name__c: "",
        Residence_City__c: "",
        Residence_Country__c: "",
        Residence_Street_Address_1__c: "",
        Residence_Street_Address_2__c: "",
        Residence_Zip_Code__c: "",
        Residence_State__c: "",
        Residence_InternationalAddress__c: ""
    }

    @api initialAddressFields = {
        addressStreet: "",
        addressUnit: "",
        addressCity: "",
        addressState: "",
        addressZip: "",
        addressInternational: "",
        addressCountry: ""
    }

    @api businessAddressFields = {
        ...this.initialAddressFields
    }

    @api incorporator = {
        ...this.initialData
    };

    get incorporatorOptions() {
      //  return [
      //      { label: '<p class="smallBold">'++'</p><p class="smaller">A person associated with and acting on behalf of your business.</p>', value: "Individual" , id:"Individual" },
     //       { label: '<p class="smallBold">Business</p><p class="smaller">A business entity associated with and acting on behalf of your business.</p>', value: "Business", id:"Business" }
      //  ];


      return [{
        label: `<p class='smallBold'>${Individual_Label_text}</p><p class='smaller'>${this.label.brs_InterimNotice_PrincipalScreenPrincipalOptions}</p>`,
        value: Individual_Label,
        id: Individual_Label,
        translatedLabel: Individual_Label_text
    },
    {
        label: `<p class='smallBold'>${this.label.AccountRecordType_Business}</p><p class='smaller'>${brs_InterimNotice_PrincipalScreenPrincipalOptions2}</p>`,
         value: Business_Comparable
         , id:Business_Comparable 
         ,translatedLabel: AccountRecordType_Business
    }
    ];
    }

    get hasIncorporators() {
        return this.incorporatorListData.length > 0;
    };


    checkIncorporatorLength() {
        this.hideAddButton = this.incorporatorListData.length === 200 || this.incorporatorListData.length > 200;
    };

    connectedCallback() {
        if (this.accountrecord) {
            var accRecValue = JSON.parse(JSON.stringify(this.accountrecord));
            if (accRecValue) {
                this.accountId = accRecValue.Id;
            }
        }
        if (!this.pageRef) {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
        }
        registerListener('flowvalidation', this.handleNotification, this);
        this.getAllIncorporators(true);
    }


    @api
    validate() {
        if (this.incorporatorListData.length > 0) {
            this.showErrorMessage = false;
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

    handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid == true) {
            this.showErrorMessage = false;
        }
        else {
            this.showErrorMessage = true;
        }
    }

    // show hide popup
    handleAddPopup() {
        this.showAddIncorporatorPopup = !this.showAddIncorporatorPopup;
        if (this.showAddIncorporatorPopup) {
            document.body.style.overflow = 'hidden';
            this.modalFocusTrap();
        } else {
            document.body.style.overflow = '';
        }
        this.resetForm();
    }

    // Radio button check
    onRadioCheck(event) {
        this.incorporator = {
            ...this.initialData,
            Type__c: event.detail.value
        }
        this.isIndividual();
    }

    // Show next screens based on selected type
    isIndividual() {
        this.isIndividualFlow = (this.incorporator.Type__c === this.label.Agent_Individual_Option);
    }

    getFullBusinessAddress(incorporator) {
        const addressArray = [];
        if (incorporator.Residence_Street_Address_1__c) {
                addressArray.push(incorporator.Residence_Street_Address_1__c);
              }
        if (incorporator.Residence_Street_Address_2__c) {
            addressArray.push(incorporator.Residence_Street_Address_2__c);
        }
        if (incorporator.Residence_Street_Address_3__c) {
            addressArray.push(incorporator.Residence_Street_Address_3__c);
        }
        if (incorporator.Residence_City__c) {
            addressArray.push(incorporator.Residence_City__c);
        }
        if (incorporator.Residence_State__c) {
            addressArray.push(incorporator.Residence_State__c);
        }
        if (incorporator.Residence_Zip_Code__c) {
            addressArray.push(incorporator.Residence_Zip_Code__c);
        }
        if (incorporator.Residence_InternationalAddress__c) {
            addressArray.push(incorporator.Residence_InternationalAddress__c);
        }
        if (incorporator.Residence_Country__c) {
            addressArray.push(incorporator.Residence_Country__c);
        }
        return addressArray.join(", ");
    }

    gotoFirstScreen() {
        this.showFirstScreen = true;
        this.modalFocusTrap();
        this.showSecondScreen = false;
        let businessAddress = this.template.querySelector("c-brs_address.businessAddress"); 
        if(businessAddress){
            var baddress = JSON.parse(JSON.stringify(businessAddress.getdata()));
            this.incorporator = {
                ...this.incorporator,
                Residence_City__c: baddress.city,
                Residence_Country__c: baddress.country,
                Residence_Street_Address_1__c: baddress.street,
                Residence_Street_Address_2__c: baddress.unit ? baddress.unit : "",
                Residence_Zip_Code__c: baddress.zip,
                Residence_State__c: baddress.state,
                Residence_InternationalAddress__c: baddress.internationalAddress
            }
            this.setBusinessAddressFields();
        }
    }

    gotoSecondScreen() {
        if (this.validateFirstScreen()) {
            this.showFirstScreen = false;
            this.showSecondScreen = true;
            this.modalFocusTrap();
        }
    }

    validateFirstScreen() {
        if (this.incorporator.Type__c !== "") {
            this.incorporator = {
                ...this.incorporator,
                Type__c_Error: false
            }
            return true;
        } else {
            this.incorporator = {
                ...this.incorporator,
                Type__c_Error: true
            }
            return false;
        }
    }

    validateSecondScreen() {
        const businessAddress = this.template.querySelector("c-brs_address.businessAddress");
        const businessAddressValid = businessAddress.validateaddress();

        const inputs = this.template.querySelectorAll('.incorporator-input');
        inputs.forEach(field => {
            field.reportValidity();
        });

        let emailError = false;
        if (this.incorporator.Email !== "" && this.hasEmailError()) {           
            emailError = true;
        }

        let isNameOrBusinessNameFilled;
        if (this.isIndividualFlow) {
            isNameOrBusinessNameFilled = this.incorporator.FirstName !== "" && this.incorporator.LastName !== "";
        } else {
            isNameOrBusinessNameFilled = this.incorporator.Business_Name__c !== "";
        }
        return (businessAddressValid && isNameOrBusinessNameFilled && !emailError);
    }

    hasEmailError(){
        let emailError = false;
        const email = this.template.querySelectorAll('.incorporator-email');
        if(email){              
            emailError = this.incorporator.Email !== "" && !this.incorporator.Email.match(this.emailPattern);
            let errorMeg = emailError ? this.label.GenericInput_Invalid_Email:"";
            email[0].setCustomValidity(errorMeg);
            email[0].reportValidity();
        }
        return emailError;
    }

    onEmailChange(event) {
        this.incorporator = {
            ...this.incorporator,
            Email: event.detail.value.trim().toLowerCase()
        }
    }

    handleFirstName(event) {
        this.incorporator = {
            ...this.incorporator,
            FirstName: event.detail.value
        }
    }
    handleLastName(event) {
        this.incorporator = {
            ...this.incorporator,
            LastName: event.detail.value
        }
    }

    onBusinessNameChange(event) {
        this.incorporator = {
            ...this.incorporator,
            Business_Name__c: event.detail.value
        }
    }

    handleBlur(event){
        this.incorporator = {
            ...this.incorporator,
            [event.target.getAttribute('data-id')]: event.target.value.trim()
        }
    }

    setBusinessAddressFields() {
        this.businessAddressFields = {
            addressStreet: this.incorporator.Residence_Street_Address_1__c,
            addressUnit: this.incorporator.Residence_Street_Address_2__c,
            addressCity: this.incorporator.Residence_City__c,
            addressState: this.incorporator.Residence_State__c,
            addressZip: this.incorporator.Residence_Zip_Code__c,
            addressInternational:this.incorporator.Residence_InternationalAddress__c,
            addressCountry: this.incorporator.Residence_Country__c
        }
    };

    onAddMoreIncorporator(e) {
        this.submitIncorporatorForm(e, true);
    }

    submitIncorporatorForm(e, showPopup) {
        if (this.validateSecondScreen()) {
            this.spinner = true;
            var businessAddress = this.template.querySelector("c-brs_address.businessAddress");
            var baddress = JSON.parse(JSON.stringify(businessAddress.getdata()));
            let incorporator = {
                AccountId: this.accountId,
                Email: this.incorporator.Email,
                Type__c: this.incorporator.Type__c,
                Residence_City__c: baddress.city,
                Residence_Country__c: baddress.country,
                Residence_Street_Address_1__c: baddress.street,
                Residence_Street_Address_2__c: baddress.unit ? baddress.unit : "",
                Residence_Zip_Code__c: baddress.zip,
                Residence_State__c: baddress.state,
                Residence_InternationalAddress__c: baddress.internationalAddress
            }
            if (this.isIndividualFlow) {
                incorporator = {
                    ...incorporator,
                    FirstName: this.incorporator.FirstName,
                    LastName: this.incorporator.LastName
                }
            } else {
                incorporator = {
                    ...incorporator,
                    Business_Name__c: this.incorporator.Business_Name__c,
                    LastName: this.incorporator.Business_Name__c
                }
            }
            if (this.incorporator.Id) {
                incorporator = {
                    ...incorporator,
                    Id: this.incorporator.Id
                }
                this.updateIndivialIncorporator(incorporator);
            } else {
                this.createIndivialIncorporator(incorporator, showPopup);
            }
        }
    }

    createIndivialIncorporator(incorporator, showPopup) {
        insertIncorporatorRecord({ incorpRec: incorporator }).then((data) => {
            this.spinner = false;
            if (!showPopup) {
                this.showAddIncorporatorPopup = false;
                document.body.style.overflow = '';
                this.resetForm();
            } else {
                this.incorporator = {
                    ...this.initialData,
                    Residence_Street_Address_1__c: "",
                    Type__c: this.incorporator.Type__c
                };
                this.businessAddressFields = {
                    addressStreet: "",
                    addressUnit: "",
                    addressCity: "",
                    addressState: "",
                    addressZip: "",
                    addressInternational: "",
                    addressCountry: ""
                }
            }
            this.getAllIncorporators();
        }).catch((error) => {
            this.spinner = false;
            ComponentErrorLoging(
                this.compName,
                "createIncorporatorRecord",
                "",
                "",
                "Medium",
                error.message
            );
        });
    }

    updateIndivialIncorporator(incorporator) {
        updateIncorporatorRecord({ incorpRec: incorporator }).then((data) => {
            this.spinner = false;
            this.showAddIncorporatorPopup = false;
            document.body.style.overflow = '';
            this.resetForm();
            this.getAllIncorporators();
        }).catch((error) => {
            this.spinner = false;
            ComponentErrorLoging(
                this.compName,
                "updateIncorporatorRecord",
                "",
                "",
                "Medium",
                error.message
            );
        });
    }

    getAllIncorporators(noValidate) {
        this.isLoading = true;
        getIncorporatorRecordsonLoad({ sId: this.accountId }).then((data) => {
            this.isLoading = false;
            this.incorporatorListData = data.map((incorporator) => {
                let modifyIncorporator;
                if (incorporator.Type__c === this.label.Agent_Individual_Option) {
                    modifyIncorporator = {
                        ...incorporator,
                        isIndividual: true,
                        Business_Address_1__c: this.getFullBusinessAddress(incorporator)
                    }
                } else {
                    modifyIncorporator = {
                        ...incorporator,
                        isIndividual: false,
                        Business_Address_1__c: this.getFullBusinessAddress(incorporator)
                    }
                }
                return modifyIncorporator;
            });
            this.checkIncorporatorLength();
            if (!noValidate) {
                this.validate();
            }
        }).catch((error) => {
            this.isLoading = false;
            ComponentErrorLoging(
                this.compName,
                "getAllIncorporators",
                "",
                "",
                "Medium",
                error.message
            );
        });
    }

    editIncorporator(event) {
        this.resetForm();
        this.editMode = true;
        this.showAddIncorporatorPopup = true;
        this.showFirstScreen = false;
        this.showSecondScreen = true;
        var index = event.currentTarget.dataset.name;
        this.incorporator.Type__c = this.incorporatorListData[index].Type__c;
        this.isIndividual();
        this.incorporator = {
            ...this.initialData,
            ...this.incorporatorListData[index]
        }
        this.setBusinessAddressFields();
        document.body.style.overflow = 'hidden';
        this.modalFocusTrap();
    }

    deleteIncorporator(event) {
        this.isLoading = true;
        var id = event.currentTarget.dataset.id;

        deleteIncorporatorRecord({ sId: id }).then((data) => {
            this.isLoading = false;
            this.getAllIncorporators(true);
        }).catch((error) => {
            this.isLoading = false;
            ComponentErrorLoging(
                this.compName,
                "deleteIncorporator",
                "",
                "",
                "Medium",
                error.message
            );
        });
    }

    onAccordianClick(event) {
        var index = Number(event.currentTarget.dataset.name);
        this.incorporatorListData = this.incorporatorListData.map((incorporator, i) => {
            return {
                ...incorporator,
                showDetails: incorporator.showDetails ? false : (i === index)
            }
        })
    }


    resetForm() {
        this.showFirstScreen = true;
        this.showSecondScreen = false;
        this.incorporator = {
            ...this.initialData
        };
        this.businessAddressFields = {
            ...this.initialAddressFields
        }
        this.editMode = false;
    }

    modalFocusTrap(){
        setTimeout(() => {
            focusTrap(this.template);
        }, 250);
    }

    handleAddPopupClose(event){
        if (event.keyCode === 13 || event.keyCode == 32) {
            this.handleAddPopup()
        }
    }
}
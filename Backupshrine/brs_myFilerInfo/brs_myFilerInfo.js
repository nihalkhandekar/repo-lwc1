import { LightningElement, track } from 'lwc';
import AddressUnit_Apt from "@salesforce/label/c.AddressUnit_Apt";
import my_filer_info_scholar from "@salesforce/label/c.my_filer_info_scholar";
import save from "@salesforce/label/c.save";
import Edit from "@salesforce/label/c.Edit";
import Remove from "@salesforce/label/c.Remove";
import my_filer_info from "@salesforce/label/c.my_filer_info";
import my_filer_info_subheading from "@salesforce/label/c.my_filer_info_subheading";
import filer_name from "@salesforce/label/c.filer_name";
import filer_address from "@salesforce/label/c.filer_address";
import filer_message_alert from "@salesforce/label/c.brs_filer_alert_message";
import Toast_Message from "@salesforce/label/c.brs_toast_delete_message";
import assetFolder from '@salesforce/resourceUrl/CT_Assets';
import getContactInfo from '@salesforce/apex/brs_myFilerInfoController.getContactInfo';
import saveContactInfo from '@salesforce/apex/brs_myFilerInfoController.saveContactInfo';
import { ComponentErrorLoging } from "c/formUtility";
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Brs_myFilerInfo extends LightningElement {
    @track filerName;
    @track filerAddressFields = {};
    @track source = "Worker Portal";
    @track scholarContent = my_filer_info_scholar;
    @track locationIcon = assetFolder + "/icons/location-passive.svg";
    @track editIcon = assetFolder + "/icons/edit-blue.svg";
@track removeIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track showInfo = false;
    @track fullAddress;
    @track isLoading = false;
    @track iaAddressRequired = false;
    label = {
        AddressUnit_Apt,
        save,
        Edit,
        Remove,
        my_filer_info,
        my_filer_info_subheading,
        filer_name,
        filer_address   
    }    

    connectedCallback() {
        this.isLoading = true;
        getContactInfo()
            .then(result => {
                if (result) {
                    this.filerName = result.organization;
                    this.filerAddressFields = {
                        addressStreet: result.street ? result.street.split(",")[0]: "",
                        addressUnit: result.street ? result.street.split(",")[1]: "",
                        addressCity: result.city,
                        addressState: result.state,
                        addressZip: result.zip,
                        addressCountryFormat: result.addressFormat,
                        addressInternational: result.internationalAddr,
                        addressCountry: result.country
                    }
                    this.fullAddress = this.getMemberFullAddress(this.filerAddressFields);
                    if(this.filerName || this.fullAddress){
                        this.showInfo = true;
                    }
                }
                this.isLoading = false;
                console.log('result: ' + JSON.stringify(result));
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    'brs_myFilerInfo',
                    "getContactInfo",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            })
    }
    onNameChange(event) {
        this.filerName = event.target.value;
    }

    onNameBlur(event) {
        this.filerName = event.target.value.trim();
    }
    saveFilerInfo() {
        this.isLoading = true;
        const address = this.template.querySelector("c-brs_address.mailingAddressOrganisation");
        const { city, state, zip, street, unit, country, internationalAddress, countryFormat } = JSON.parse(JSON.stringify(address.getdata()));
        const updatedStreet = unit!='' ?`${street}, ${unit}`:`${street}`;
        console.log('street', street)
        const contactDetails = {
            organization: this.filerName,
            street: updatedStreet,
            state,
            city,
            country,
            zip,
            internationalAddr: internationalAddress,
            addressFormat: countryFormat
        }
        this.filerAddressFields = {
            addressStreet: street,
            addressUnit: unit,
            addressCity: city,
            addressState: state,
            addressZip: zip,
            addressCountryFormat: countryFormat,
            addressInternational: internationalAddress,
            addressCountry: country
        }
        saveContactInfo({ conInfo: JSON.stringify(contactDetails) }).then((data) => {
            console.log('data save succesful');
            this.fullAddress = this.getMemberFullAddress(this.filerAddressFields),
            this.showInfo = true;
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
            ComponentErrorLoging(
                'brs_myFilerInfo',
                "saveContactInfo",
                "",
                "",
                "Medium",
                error.message
            );
        })
    }
    handleEdit() {
        this.showInfo = false;
    }
// Method to show a confirmation dialog
    async showConfirmationDialog() {
        const result = await LightningConfirm.open({
            title: 'Remove filer',
            message: filer_message_alert,
            variant: 'headerless'
        });

        if (result) {
            const contactDetailsNull = {
                organization: null,
                street: null,
                state: null,
                city: null,
                country: null,
                zip: null,
                internationalAddr: null,
                addressFormat: null
            }
            
            await saveContactInfo({ conInfo: JSON.stringify(contactDetailsNull) }).then((data) => {
                Object.keys(this.filerAddressFields).forEach(key => this.filerAddressFields[key] = null);
                this.fullAddress = this.getMemberFullAddress(this.filerAddressFields),
                this.filerName = null;
                this.showInfo = false;
                this.isLoading = false;
              
                // Show a success toast message
                const event = new ShowToastEvent({
                    message: Toast_Message,
                    variant: 'success'
                });
                this.dispatchEvent(event);

            }).catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    'brs_myFilerInfo',
                    "saveContactInfo",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            })
        }
    }

    handleAddressChange(event) {
        // this.filerAddressFields = JSON.parse(JSON.stringify(event.detail));
        // console.log(JSON.parse(JSON.stringify(this.filerAddressFields)));
    }
    getMemberFullAddress(address) {
        const addressArray = [];
        if (address.addressStreet) {
            addressArray.push(address.addressStreet);
        }
        if (address.addressUnit) {
            addressArray.push(address.addressUnit);
        }
        if (address.addressCity) {
            addressArray.push(address.addressCity);
        }
        if (address.addressState) {
            addressArray.push(address.addressState);
        }
        if (address.addressZip) {
            addressArray.push(address.addressZip);
        }
        if (address.addressCountry) {
            addressArray.push(address.addressCountry);
        }
        return addressArray.join(", ");
    }
}
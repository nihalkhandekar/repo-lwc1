import { LightningElement, track, api } from 'lwc';
import brsAssetFolder from "@salesforce/resourceUrl/BRS_Assets";
import general_information from '@salesforce/label/c.general_information';
import filing_numberNew from '@salesforce/label/c.filing_numberNew';
import Business_AELI from '@salesforce/label/c.Business_AELI';
import business_name from '@salesforce/label/c.business_name';
import Date from '@salesforce/label/c.Date';
import Business_Details from '@salesforce/label/c.Business_Details';
import Filing_date_and_time from '@salesforce/label/c.Filing_date_and_time';
import State_Country_to from '@salesforce/label/c.State_Country_to';
import Business_type from '@salesforce/label/c.Business_type';
import Terminating from '@salesforce/label/c.Terminating';
import Merger_Label from '@salesforce/label/c.Merger_Label';
import Domestication_Label from '@salesforce/label/c.Domestication_Label';
import Conversion_Label from '@salesforce/label/c.Conversion_Label';
import Domestications from '@salesforce/label/c.Domestications';
import Domesticated from '@salesforce/label/c.Domesticated';
import Converted from '@salesforce/label/c.Converted';
import Domesticating from '@salesforce/label/c.Domesticating';
import Conversions from '@salesforce/label/c.Conversions';
import Converting from '@salesforce/label/c.Converting';
import Mergers from '@salesforce/label/c.Mergers';
import Domestication_Comparable from "@salesforce/label/c.Domestication_Comparable";
import Conversion_Comparable from "@salesforce/label/c.Conversion_Comparable";

export default class Brs_conversionOrMergerOrDomesticationDetails extends LightningElement {
    @api details;
    @api scholerContent;
    @track arrowUpIcon = brsAssetFolder + "/icons/arrow-up.svg";
    @track arrowDownIcon = brsAssetFolder + "/icons/arrow-down.svg";
    @track isMerger = false;
    @track isDomesticated = false;
    @track secondCardHeading;
    @track thirdCardHeading;
    @track type;
    @track pageHeading;
    @track label = {
        general_information,
        filing_numberNew,
        Business_AELI,
        business_name,
        Date,
        Business_Details,
        Filing_date_and_time,
        State_Country_to,
        Business_type,
        Terminating,
        Merger_Label,
        Domestication_Label,
        Conversion_Label,
        Domestications,
        Domesticated,
        Converted,
        Domesticating,
        Conversions,
        Converting,
        Mergers,
        Domestication_Comparable,
        Conversion_Comparable
    }
    @track tablecolumns = [
        {
            label: this.label.Business_AELI,
            fieldName: 'changingbusinessId'
        },
        {
            label: this.label.business_name,
            fieldName: 'changingbusinessName'
        },
        {
            label: this.label.Date,
            fieldName: 'changingbusinessDate'
        }
    ];
    @track tabledata;


    connectedCallback() {
        this.isMerger = this.details.filingType === this.label.Merger_Label;
        this.isDomesticated = this.details.filingType === this.label.Domestication_Label;
        this.tabledata = this.details.mergedAccountList;
        this.setHeading();
    }

    setHeading() {
        switch (this.details.filingType) {
            case this.label.Domestication_Comparable:
                this.pageHeading = this.label.Domestications;
                this.secondCardHeading = this.label.Domesticated;
                this.thirdCardHeading = this.label.Domesticating;
                break;
            case this.label.Conversion_Comparable:
                this.pageHeading = this.label.Conversions;
                this.secondCardHeading = this.label.Converted;
                this.thirdCardHeading = this.label.Converting;
                break;
            default:
                this.pageHeading = this.label.Mergers;
                break;

        }
    }
}
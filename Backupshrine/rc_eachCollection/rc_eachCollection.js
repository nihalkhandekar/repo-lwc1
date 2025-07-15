import { LightningElement, track, api } from 'lwc';
import getCollectionResources from "@salesforce/apex/CollectionController.getCollectionResources";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import rc_results_for from '@salesforce/label/c.rc_results_for';
import rc_Resources from '@salesforce/label/c.rc_Resources';
import rc_Show_More_Results from '@salesforce/label/c.rc_Show_More_Results';
import rc_Media from '@salesforce/label/c.rc_Media';
import rc_Show_More_Media from '@salesforce/label/c.rc_Show_More_Media';

export default class Rc_eachCollection extends LightningElement {
    @track NoDataCard = false;
    @track collectionsList = [];
    @track collections = [];
    @track blueEdit = assetFolder + "/icons/edit.svg";
    @track chevronRight = assetFolder + "/icons/chevronRightOrange.svg";
    @track showLengthLimit = false;
    @track openModal;
    @track spinner = false;
    label ={
        rc_results_for,
        rc_Resources,
        rc_Show_More_Results,
        rc_Media,
        rc_Show_More_Media
    };
	
    connectedCallback() {
        this.getAllResources();
    }

    getAllResources() {
        this.spinner = true;
        getCollectionResources()
        .then(result => {
            this.allResults = JSON.parse(result);
            this.resources = this.allResults.resources;
            this.media = this.allResults.media;
            this.spinner = false;
        })
        .catch((err) => {
            this.spinner = false;
        });
    }
}
import {
    LightningElement,
    track,
    api
} from 'lwc';

import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import getAllCollections from "@salesforce/apex/CollectionController.getAllCollections";
import isGuestUser from '@salesforce/user/isGuest';
import rc_Manage_Collections from "@salesforce/label/c.rc_Manage_Collections";
import myCollections from "@salesforce/label/c.myCollections";
import rc_resource from "@salesforce/label/c.rc_resource";
import { NavigationMixin } from 'lightning/navigation';
import rc_resource_s from "@salesforce/label/c.rc_resource_s";
import { ComponentErrorLoging } from "c/formUtility";
import myCollectionsContent from "@salesforce/label/c.myCollectionsContent";


export default class Rc_myCollection extends NavigationMixin(LightningElement) {
    @track NoDataCard = false;
    @track showData = false;
    @track blueArrow = assetFolder + "/icons/RC/arrow-forward-outline.svg";
    @track collectionsList = [];
    @track collections = [];
    @track isLoggedIn = false;
    @track showModal = false;
    @track spinner=false;
	label = {
        rc_Manage_Collections,
        myCollections,
        rc_resource,
        rc_resource_s,
        myCollectionsContent
    };
    connectedCallback() {
        if (isGuestUser) {
            this.isLoggedIn = false;
            this.NoDataCard = true;
        } else {
            this.spinner = true;
            this.isLoggedIn = true;
            getAllCollections()
                .then(result => {
                    result = JSON.parse(result);
                    if (result.length) {
                        this.NoDataCard = false;
                        result.forEach(element => {
                            this.collectionsList.push({
                                "listName": element.collection.Name,
                                "listLength": element.folders.length,
                                "listId": element.collection.Id 
                            })
                        })
                    } else {
                        this.NoDataCard = true;
                    }
                    this.spinner = false;
                })
                .catch((err) => {
					this.spinner = false;
                    ComponentErrorLoging("rc_myCollection", 'getAllCollections', '', '', 'High', error.message);
                });
        }
    }
    
    NavigateToCollectionKey(event) {
        if (event.keyCode == 13) {
            this.NavigateToCollection(event);
        }
    }
    NavigateToCollection(event) {
        if (this.isLoggedIn) {
            let collectionid = event.currentTarget.dataset.id;
            this.spinner=true;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "mycollections__c"
                },
                state: {
                    collectionid: collectionid
                }
            });
        } else {
            this.showModal = true;
        }
    }
    NavigateToAllCollections() {
        if (this.isLoggedIn) {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "mycollections__c"
                }
            });
        } else {
            this.showModal = true;
        }
    }
    handleModalClose() {
        this.showModal = false;
    }
}
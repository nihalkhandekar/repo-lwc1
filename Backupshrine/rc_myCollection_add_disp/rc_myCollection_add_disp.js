import {
    LightningElement,
    track
} from 'lwc';

import getAllCollections from "@salesforce/apex/CollectionController.getAllCollections";
import deleteCollection from "@salesforce/apex/CollectionController.deleteCollection";
import getCollectionResources from "@salesforce/apex/CollectionController.getCollectionResources";
import isGuestUser from '@salesforce/user/isGuest';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import startNewCollection from '@salesforce/label/c.startNewCollection';
import myCollectionsContent from '@salesforce/label/c.myCollectionsContent';
import rc_Resource_Center from '@salesforce/label/c.rc_Resource_Center';
import Edit_btn from '@salesforce/label/c.Edit_btn';
import myCollections from '@salesforce/label/c.myCollections';
import rc_Media from '@salesforce/label/c.rc_Media';
import rc_Resources from '@salesforce/label/c.rc_Resources';
import rc_resource from '@salesforce/label/c.rc_resource';
import rc_Delete_Collection from '@salesforce/label/c.rc_Delete_Collection';
import { NavigationMixin } from 'lightning/navigation';
import rc_resource_s from "@salesforce/label/c.rc_resource_s";
import { ComponentErrorLoging } from "c/formUtility";
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';

export default class Rc_myCollection_add_disp extends NavigationMixin(LightningElement) {
    @track NoDataCard = false;
    @track collectionsList = [];
    @track fullCollectionsList = [];
    @track collections = [];
    @track singleObj = [];
    @track blueEdit = assetFolder + "/icons/edit.svg";
    @track chevronRight = assetFolder + "/icons/chevronRightOrange.svg";
    @track showLengthLimit = false;
    @track openModal;
    @track spinner = false;
    @track singleCollections = false;
    @track singleColId;
    @track singleColName;
    @track singleColLength = 0;
    @track cId;
    @track cName;
    @track hideMedia = false;
    @track hideResources = false;
    @track mainResult;
    @track language;
    @track param = 'language';
    @track showDelete = false;
    @track URLParams;
    @track collectionid;
    @track ForgeRock_End_URL;
    @track compName = 'Rc_myCollection_add_disp';
    label = {
        startNewCollection,
        myCollectionsContent,
        rc_Resource_Center,
        Edit_btn,
        myCollections,
        rc_Delete_Collection,
        rc_Media,
        rc_Resources,
        rc_resource,
		rc_resource_s
    };

    connectedCallback() {
        this.spinner = true;
        this.setURLParams();
        const labelName = metadataLabel;
        window.addEventListener("my-account-clicked", () => {
            this.navigateToAccount();
        });
        fetchInterfaceConfig({labelName})
            .then(result => {
                var parsedResult = JSON.parse(JSON.stringify(result));
                if(isGuestUser){
                    this.ForgeRock_End_URL = parsedResult.ForgeRock_End_URL__c
                    this.link = this.ForgeRock_End_URL;
                } else {
                    this.link = parsedResult.End_URL__c;
                }
                this.spinner = false;
            })
            .catch(error => {
                this.spinner = false;
                ComponentErrorLoging(this.compName, 'fetchInterfaceConfig', '', '', 'High', error.message);
            });
        this.getCollections();
    }

    setURLParams() {
        var url_string = document.location.href;
        var url = new URL(url_string);
        var arr = url_string.split("?");
        if (url_string.length > 1 && arr[1] !== "") {
            this.URLParams = url.searchParams;
            this.language = this.URLParams.get(this.param);
        }
    }

    navigateToAccount() {
        if (isGuestUser) {
            window.location.href = this.link+'&'+this.param+'='+this.language;
        } else {
            window.location.href = this.link;
        }
    }

    getCollections() {
        this.spinner = true;
        this.collections = [];
        this.collectionsList = [];
        getAllCollections()
            .then(result => {
                result = JSON.parse(result);
                if (result.length) {
                    this.NoDataCard = false;
                    this.fullCollectionsList = result;
                    result.forEach(element => {
                        this.collectionsList.push({
                            "listName": element.collection.Name,
                            "id": element.collection.Id,
                            "listLength": element.folders.length
                        })
                    })
                    this.setURLParams();
                    if (this.URLParams.get('collectionid')) {
                        this.collectionid = this.URLParams.get('collectionid');
                        this.NavigateToIndv(this.collectionid);
                    }
                } else {
                    this.NoDataCard = true;
                }
                this.spinner = false;
            })
            .catch((error) => {
                this.spinner = false;
                ComponentErrorLoging("rc_myCollection_add_disp", 'getAllCollections', '', '', 'High', error.message);
            });
    }

    afterAddCollection(event) {
        this.spinner = true;
        setTimeout(() => {
            this.getCollections();
            this.spinner = false;
        }, 100);
        if (this.collectionsList.length > 9) {
            this.showLengthLimit = true;
        }
    }
    HandleEdit(event) {
        this.singleColName=null;
        let id = event.detail.id;
        let name = event.detail.newname;
        this.singleColName = name;
        if (this.collectionsList && this.collectionsList.length) {
        this.collectionsList.forEach(element => {
            if (element.id === id) {
                element.listName = name;
            }
        });
        }
        if (this.fullCollectionsList && this.fullCollectionsList.length) {
        this.fullCollectionsList.forEach(element => {
            if (element.collection.Id === id) {
                element.collection.Name= this.singleColName;
            }
            });
        }

    }
    openEditCollectionKey(event) {
        if (event.keyCode == 13) {
            this.openEditCollection(event);
        }
    }
    openEditCollection(event) {
        this.cId = event.currentTarget.dataset.id;
        this.cName = event.currentTarget.dataset.name;
        this.openModal = true;
        this.showDelete = false;

    }
    openNewEditCollection() {
        this.cId = this.singleColId;
        this.cName = this.singleColName;
        this.openModal = true;
        this.showDelete = false;
    }
    deleteCollection() {
        this.showDelete = true;
        this.openModal = true;
    }
    handleDeleteCol() {
        deleteCollection({
                collectionId: this.singleColId
            }).then(result => {
                this.singleCollections = false;
                setTimeout(() => {
                    this.getCollections();
                }, 100);
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "mycollections__c"
                    }
                });
            })
            .catch(error => {
                ComponentErrorLoging("rc_myCollection_add_disp", 'deleteCollections', '', '', 'High', error.message);
            })
    }
    /**
     * @function showModal - method written to open Video Modal
     * @param {event} - event triggered
     */
    showModal() {
        if (this.collectionsList.length > 9) {
            this.showLengthLimit = true;
        }
        this.openModal = true;
        this.showDelete = false;
        this.cId = "";
        this.cName = "";
    }
    NavigateToIndvKey(event) {
        if (event.keyCode == 13) {
            this.NavigateToIndv(event);
        }
    }
    NavigateToIndv(event) {
        let indId;
        if(event.currentTarget && event.currentTarget.dataset && event.currentTarget.dataset.id) {
            indId = event.currentTarget.dataset.id;
        } else if(event) {
            indId = event;
        }
        this.singleColId = indId;
        this.fullCollectionsList.forEach(element => {
            if (element.collection.Id === indId) {
                this.singleObj = element.folders;
                this.singleColName = element.collection.Name;
                this.singleColLength = element.folders.length;
            }
        })
        this.getCollectionsDetails();
    }
    getCollectionsDetails() {
        this.spinner = true;
        getCollectionResources({
                collectionId: this.singleColId
            }).then(result => {
                this.mainResult = JSON.parse(result);
                this.singleCollections = true;
                this.sortCollectionsData();
                this.spinner = false;
                var url = new URL(document.location.href);
                var URLParams = url.searchParams;
                var cid = URLParams.get('collectionid');
                if (!cid) {
                    this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: {
                            name: "mycollections__c"
                        },
                        state: {
                            collectionid: this.singleColId
                        }
                    });
                }
                window.scrollTo({
                    top: 0,
                    behavior: "smooth"
                });
                this.spinner =  false;
            })
            .catch((error) => {
                this.spinner = false;
                ComponentErrorLoging("rc_myCollection_add_disp", 'getCollectionResources', '', '', 'High', error.message);
            });
    }
    sortCollectionsData() {
        this.resources = this.mainResult.Resource;
        this.media = this.mainResult.Media;
        let collectionData = [];
        this.fullCollectionsList.forEach(element => {
            collectionData.push({
                "value": element.collection.Name,
                "id": element.collection.Id,
                "label": element.collection.Name
            })
        })
        this.getSelectedHeart();
        if (this.resources && this.resources.length) {
        this.resources.forEach(element => {
            let tempPills = [];
            let count = 0;

            element.listDataCategories.forEach(el => {
                if (count < 2) {
                    tempPills.push(el);
                    count++;
                }
            });
            element.listDataCategories = tempPills;
        });
        this.resources.forEach(element => {
            element.collections = collectionData;
        });
        }
        if (this.media && this.media.length) {
        this.media.forEach(element => {
            element.collections = collectionData;
        });
        }
    }
    getSelectedHeart() {
        if (this.resources && this.resources.length) {
        this.resources.forEach(element => {
            element.listSavedCollection.forEach(collection => {
                if (collection.isSaved) {
                    element.isSaved = true
                }
            })
        });
        }
        if (this.media && this.media.length) {
            this.media.forEach(element => {
                element.listSavedCollection.forEach(collection => {
                    if (collection.isSaved) {
                        element.isSaved = true
                    }
                })
            });
        }
    }
    handleResourceRemoved(event) {
        this.singleColId = event.detail;
        setTimeout(() => {
            this.getCollectionsDetails();
          }, 100);
        setTimeout(() => {
            let colLength = 0;
            if(this.resources && this.media) {
                colLength = this.resources.length + this.media.length;
            } else if(this.resources) {
                colLength = this.resources.length;
            } else if(this.media) {
                colLength = this.media.length 
            } else {
                colLength = 0;
            }           
            this.singleColLength = colLength;
        }, 1000);
       
    }
    NavigateToRCLanding() {
        window.location = 'ResourceCenter';
    }

    /**
     * @function closeModal - method written to close Video Modal
     * @param {event} - event triggered
     */
    closeModal() {
        this.openModal = false;
    }
    handleFilterChange(event) {
        this.filterType = event.detail;
        let resourceString = rc_resource;
        let mediaString = rc_Media;
        this.filterType = this.filterType.toLowerCase();
        resourceString = resourceString.toLowerCase();
        mediaString = mediaString.toLowerCase();
        if (this.filterType === mediaString) {
            this.hideResources = true;
            this.hideMedia = false;
        } else if (this.filterType === resourceString) {
            this.hideMedia = true;
            this.hideResources = false;
        } else if (this.filterType === 'clearfilters') {
            this.hideMedia = false;
            this.hideResources = false;
        }
    }
    handleNewCollection(event) {
        this.newCollections = [];
        let newColList = event.detail;
        let tempRes = this.resources;
        this.newCollections = newColList;
        if (newColList.length) {
            tempRes.forEach(element => {
                element.collections = newColList;
            });
            this.resources = tempRes;
        }
    }
}
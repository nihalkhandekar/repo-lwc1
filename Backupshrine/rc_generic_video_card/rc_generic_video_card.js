import {
    LightningElement,
    api,
    track
} from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import setViewStatKnowledgeRecords from "@salesforce/apex/BOS_KnowledgeResources.setViewStatKnowledgeRecords";
import getAllCollections from "@salesforce/apex/CollectionController.getAllCollections";
import removeResource from "@salesforce/apex/CollectionController.removeResource";
import addResource from "@salesforce/apex/CollectionController.addResource";
import isGuestUser from '@salesforce/user/isGuest';
//import rc_Resource_Add_to_Collection_Msg from '@salesforce/label/c.rc_Resource_Add_to_Collection_Msg';
import rc_Close_Dialog from '@salesforce/label/c.rc_Close_Dialog';
import ResourceAdded from '@salesforce/label/c.ResourceAdded';
import Gotomycollections from '@salesforce/label/c.Gotomycollections';
import addToCollection from '@salesforce/label/c.addToCollection';
import rcNewCollection from '@salesforce/label/c.rcNewCollection';
import shareResources from '@salesforce/label/c.shareResources';
import { ComponentErrorLoging } from "c/formUtility";
import Copy_To_Clipboard from '@salesforce/label/c.Copy_To_Clipboard';
import Share_To_Email from '@salesforce/label/c.Share_To_Email';
import Share_To_Facebook from '@salesforce/label/c.Share_To_Facebook';
import SharePinterest from '@salesforce/label/c.SharePinterest';
import ShareLinkedIn from '@salesforce/label/c.ShareLinkedIn';
import ShareTwitter from '@salesforce/label/c.ShareTwitter';
import ResourceURLCopied from '@salesforce/label/c.ResourceURLCopied';

import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
export default class Rc_generic_video_card extends LightningElement {
    passiveHeartIcon = assetFolder + "/icons/RC/heart-passive.svg";
    activeHeartIcon = assetFolder + "/icons/RC/heart-active.svg";
    playIcon = assetFolder + "/icons/RC/play.svg";
    addIconOrange = assetFolder + "/icons/RC/blue-circle-plus.png";
    shareIcon = assetFolder + "/icons/RC/share-outline.svg";
    copyIcon = assetFolder + "/icons/RC/copy-outline.svg";
    emailIcon = assetFolder + "/icons/email-input.svg";
    facebookIcon = assetFolder + "/icons/RC/Facebook.svg";
    pinterestIcon = assetFolder + "/icons/RC/Pinterest.svg";
    linkedinIcon = assetFolder + "/icons/RC/LinkedIn.svg";
    twitterIcon = assetFolder + "/icons/RC/Twitter.svg";
    label = {
        addToCollection,
        rcNewCollection,
        //rc_Resource_Add_to_Collection_Msg,
        rc_Close_Dialog,
        Gotomycollections,
        ResourceAdded,
        shareResources,
        Copy_To_Clipboard,
        Share_To_Email,
        Share_To_Facebook,
        SharePinterest,
	    ShareLinkedIn,
	    ShareTwitter,
        ResourceURLCopied
    };
    @track updatedMedia = [];
    @track isFavorite = false;
    @track openModal;
    @track openColModal = false
    collectionsList = [];
    @track selectedCollection = [];
    @track currentArticleId;
    @track spinner = false;
    @track showLengthLimit = false;
    @track fullCollections = [];
    @track preSelectedCol = [];
    @track showLoginModal = false;
    @track rc = true;
    @track showToast = false;
    @track videoUrl; 
    @track deselectedId;
    @track showShareModal = false;
    @track currentShareUrl;
    @api collectionid;
    @api landingpage = false;
    @api resultspage;

    @api
    get media() {
        return this._media;
    }
    set media(value) {
        this._media = value;
        this.updatedMedia = this.media;
    }
    connectedCallback() {
        this.getCollectionInfo();
        this.updateThumbnail(); 
        document.addEventListener('keydown', function () {
            document.documentElement.classList.remove('mouseClick');
        });
        document.addEventListener('mousedown', function () {
            document.documentElement.classList.add('mouseClick');
        });
    }

    updateThumbnail() {
        this.media = JSON.parse(JSON.stringify(this.media));    
        this.media.forEach(element => {
            element.listSavedCollection.forEach(collection => {
                if (collection.isSaved) {
                    element.isSaved = true
                }
            })
            this.collectionsList = element.collections;
            var iframe_src = element.article.Resource_Title_URL__c;
            if(iframe_src) {
                if(iframe_src.match(/youtube\.com.*(\?v=|\/embed\/)(.{11})/)) {
                    var youtube_video_id = iframe_src.match(/youtube\.com.*(\?v=|\/embed\/)(.{11})/).pop();
                    if (youtube_video_id.length == 11) {
                        var video_thumbnail = '//img.youtube.com/vi/' + youtube_video_id + '/0.jpg';
                        element.imgSrc = video_thumbnail;
                    }
                }
                
            }
        });
        this.updatedMedia = this.media;
    }

    getCollectionInfo() {
        getAllCollections()
            .then(result => {
                result = JSON.parse(result);
                this.fullCollections = result;
            })
            .catch((error) => {
                ComponentErrorLoging("rc_generic_video_card", 'getAllCollections', '', '', 'High', error.message);
            });
    }
    handleAddResource(event) {
        try {
            this.selectedCollection = event.detail.result;
            this.spinner = true;
            let selectedIds = [];
            this.selectedCollection.forEach(element => {
                this.fullCollections.forEach(el => {
                    if (el.collection.Name === element) {
                        selectedIds.push(el.collection.Id)
                    }
                })
            })
            addResource({
                collectionIds: JSON.stringify(selectedIds),
                articleIds: this.currentArticleId
            }).then(result => {
                this.showToast = true;
                setTimeout(() => {
                    this.showToast = false;
                }, 6000);
                 this.getCollectionInfo();
                this.media = JSON.parse(JSON.stringify(this.media));
                this.media.forEach(element => {
                    if (element.article.Id === this.currentArticleId) {
                        element.isSaved = true;
                    }
                });
                this.updatedMedia = this.media;
                const resourceAddedEvent = new CustomEvent("resourceadd");
                this.dispatchEvent(resourceAddedEvent);
            }).catch((errpr) => {
                ComponentErrorLoging("rc_generic_video_card", 'addResource', '', '', 'High', error.message);
            });
            let alltitle = this.template.querySelectorAll('.slds-popover');
            if (alltitle.length) {
                alltitle.forEach(element => {
                    element.classList.remove("slds-show");
                    element.classList.add("slds-hide");
                });
            }
            this.spinner = false;
        } catch (error) {
            ComponentErrorLoging("rc_generic_video_card", 'handleAddResource', '', '', 'High', error.message);
        }
    }
        handleCollectionsPopupKey(event) {
        if (event.keyCode == 13) {
            this.handleCollectionsPopup(event);
        }
    }
    handleCollectionsPopup(event) {
        try {
            if (isGuestUser) {
                this.showLoginModal = true;
            } else {
                let id = event.currentTarget.dataset.id;
                if (id != this.currentArticleId) {
                    this.selectedCollection = [];
                }
                this.currentArticleId = id;
                this.preSelectedCol = [];
                let selectedCollectionsName = [];
                let selectedCollectionsId = [];
                this.fullCollections.forEach(ele => {
                    if (ele.folders.length) {
                        ele.folders.forEach(article => {
                            if (article.Knowledge__c === this.currentArticleId) {
                                selectedCollectionsId.push(article.Collection__c)
                            }
                        })
                    }
                });
                if (selectedCollectionsId.length) {
                    this.collectionsList.forEach(element => {
                        selectedCollectionsId.forEach(el => {
                            if (el === element.id) {
                                selectedCollectionsName.push(element.value)
                            }
                        })
                    })
                }
                // if (this.selectedCollection && this.selectedCollection.length) {
                //     this.preSelectedCol = this.selectedCollection;
                // } else {
                    this.preSelectedCol = selectedCollectionsName;
               // }

                let alltitle = this.template.querySelectorAll('.slds-popover');
                if (alltitle.length) {
                    alltitle.forEach(element => {
                        element.classList.remove("slds-show");
                        element.classList.add("slds-hide");
                    });
                }
                var temp;
                this.updatedMedia=JSON.parse(JSON.stringify(this.updatedMedia))
                this.updatedMedia.forEach(element => {
                    if(element.article.Id == event.currentTarget.dataset.id) {
                        temp = element.showpopup;
                        temp = !temp;
                        element.showpopup = temp;
                    } else {
                        element.showpopup = false;
                    }
                });
                let activeTitle = this.template.querySelector("[data-name='" + id + "']");
                if (temp) {
                    activeTitle.classList.add("slds-show");
                    activeTitle.classList.remove("slds-hide");
                } else {
                    activeTitle.classList.remove("slds-show");
                    activeTitle.classList.add("slds-hide");
                }
            }
        } catch (error) {
            ComponentErrorLoging("rc_generic_video_card", 'handleCollectionsPopup', '', '', 'High', error.message);
        }
    }
    handleDeSelect(event) {
        var name = event.detail.result;
        let id;
        let selectedColId = [];
        this.collectionsList.forEach(el => {
            if (name === el.label) {
                id = el.id
            }
        })
        selectedColId.push(id);
         this.deselectedId = id;
        this.spinner = true;
        removeResource({
            collectionIds: JSON.stringify(selectedColId),
            articleIds: this.currentArticleId,devicetype:FORM_FACTOR
        }).then(result => {
            setTimeout(() => {
                this.getCollectionInfo();
                this.spinner = false;
            }, 100);
           if ((this.collectionid ===  this.deselectedId)|| this.landingpage || this.resultspage) {
                const resourceAddedEvent = new CustomEvent("mediaremoved", {
                detail: id
            });
             this.dispatchEvent(resourceAddedEvent);
            }
        }).catch((error) => {
            ComponentErrorLoging("rc_generic_video_card", 'handleCollectionsPopup', '', '', 'High', error.message);
        });
        let alltitle = this.template.querySelectorAll('.slds-popover');
        if (alltitle.length) {
            alltitle.forEach(element => {
                element.classList.remove("slds-show");
                element.classList.add("slds-hide");
            });
        }
    }
    afterAddCollection(event) {
        let result = event.detail;
        let tempList = [];
        result = JSON.parse(result);
        result.forEach(element => {
            tempList.push({
                "value": element.collection.Name,
                "id": element.collection.Id,
                "label": element.collection.Name
            })
        })
        this.collectionsList = tempList;
        const resourceAddedEvent = new CustomEvent("resourceadd", {
            detail:{
                result: this.collectionsList,
                isResource: false
            }
        });
        this.dispatchEvent(resourceAddedEvent);
        this.getCollectionInfo();
    }
    /**
     * @function showModal - method written to open Video Modal
     * @param {event} - event triggered
     */
    showColModal() {
        this.openColModal = true;
        if (this.collectionsList.length > 9) {
            this.showLengthLimit = true;
        }
    }
    closeColModal() {
        this.openColModal = false;
    }
    /**
     * @function showModal - To update the view state whenever an article is clicked/viewed - to keep track for popular resources
     * @param {event} - event triggered
     */
    updateViewState(event) {
        let articleId = event.currentTarget.dataset.id;
        setViewStatKnowledgeRecords({
            knowledgeArticleID: articleId
        }).catch((error) => {
            ComponentErrorLoging("rc_generic_video_card", 'setViewStatKnowledgeRecords', '', '', 'High', error.message);
        });
    }
    /**
     * @function showModalKey - method written to open Video Modal
     * @param {event} - event triggered
     */
    showModalKey(event) {
        if (event.keyCode == 13) {
            this.showModal(event);
        }
    }
    /**
     * @function showModal - method written to open Video Modal
     * @param {event} - event triggered
     */
    showModal(event) {
        this.videoUrl = event.currentTarget.dataset.id; 
        this.openModal = true;
    }

    /**
     * @function closeModal - method written to close Video Modal
     * @param {event} - event triggered
     */
    closeModal() {
        this.openModal = false;
    }
    handleModalClose() {
        this.showLoginModal = false;
    }
    handleToastClose() {
        this.showToast = false;
    }

    openShareModalKey(event) {
        if (event.keyCode == 13) {
            this.openShareModal(event);
        }
    }
    openShareModal(event) {
        this.showShareModal = true;
        this.currentShareUrl = event.currentTarget.dataset.id;
        let resourceContainer = this.template.querySelector("[data-id= videoCard ]");

        if (resourceContainer) {
            resourceContainer.setAttribute("aria-hidden", true);
        }
        setTimeout(() => {
            let copyElement = this.template.querySelector("[data-id = copy ]");
            if (copyElement) {
                copyElement.setAttribute("tabindex", 0);
                copyElement.focus();
            }
        }, 0);
    }
    closeShareModal() {
        this.showShareModal = false;
        let resourceContainer = this.template.querySelector("[data-id= videoCard ]");
        if (resourceContainer) {
            resourceContainer.setAttribute("aria-hidden", false);
        }
    }
    copyToClipboardKey(event) {
        if (event.keyCode == 13) {
            this.copyToClipboard();
    }
    }
    copyToClipboard() {
        let resourceId = this.currentShareUrl;
        var dummy = document.createElement("textarea");
        document.body.appendChild(dummy);
        dummy.value = resourceId;
        dummy.select();
        document.execCommand("copy");
        document.body.removeChild(dummy);
        this.dispatchEvent(
            new ShowToastEvent({
                message: this.label.ResourceURLCopied,
                variant: 'info',
                duration: '300000',
                mode: 'pester'
            }),
        );
    }

    popupWindow(url, windowName, win, w, h) {
        this.closeShareModal();
        const y = win.top.outerHeight / 2 + win.top.screenY - ( h / 2);
        const x = win.top.outerWidth / 2 + win.top.screenX - ( w / 2);
        return win.open(url, windowName, `toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width=${w}, height=${h}, top=${y}, left=${x}`);
    }
    shareTofbKey(event) {
        if (event.keyCode == 13) {
            this.shareTofb();
        }
    }
    shareTofb() {
        this.popupWindow("https://www.facebook.com/sharer/sharer.php?u=" + this.currentShareUrl, 'facebook', window, 500, 400);
    }
    shareToPinKey(event) {
        if (event.keyCode == 13) {
            this.shareToPin();
        }
    }
    shareToPin() {
        this.popupWindow("https://in.pinterest.com/pin/create/button/?url=" + this.currentShareUrl + "&media=https://portal.ct.gov/Assets/Images/facebook-default_01.png", "Pinterest",  window, 500, 400);
    }
    shareToLinkedKey(event) {
        if (event.keyCode == 13) {
            this.shareToLinked();
        }
    }
    shareToLinked() {
        this.popupWindow("https://www.linkedin.com/sharing/share-offsite/?url=" + this.currentShareUrl, "Linkedin",  window, 500, 400);
    }
    shareTotwitterKey(event) {
        if (event.keyCode == 13) {
            this.shareTotwitter();
        }
    }
    shareTotwitter() {
        this.popupWindow("https://twitter.com/intent/tweet?url=" + this.currentShareUrl, "Twitter",  window, 500, 400);
    }
    shareToMailKey(event) {
        if (event.keyCode == 13) {
            this.shareToMail();
        }
    }
    shareToMail(){
        window.open("mailto:?body="+this.currentShareUrl);
       this.closeShareModal();
     }

    goToCollections() {
        window.location = "mycollections";
    }
}
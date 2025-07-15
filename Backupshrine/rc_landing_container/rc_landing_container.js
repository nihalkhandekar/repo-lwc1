import {
    LightningElement,
    track
} from 'lwc';
import getSearch from "@salesforce/apex/ResourceGlobalSearch.getSearch";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import getPopResource from "@salesforce/apex/BOS_KnowledgeResources.getFeaturedPopularArticleRecords";
import getMediaResource from "@salesforce/apex/BOS_KnowledgeResources.getMediaArticleRecords";
import getAllCollections from "@salesforce/apex/CollectionController.getAllCollections";
import getKnowledgeByTopicANDCategory from "@salesforce/apex/BOS_KnowledgeResources.getKnowledgeByTopicANDCategory";

import isGuestUser from '@salesforce/user/isGuest';

import rcPopularResources from '@salesforce/label/c.rcPopularResources';
import rcMediaResources from '@salesforce/label/c.rcMediaResources';
import showMore from '@salesforce/label/c.showMore';
import viewCollections from '@salesforce/label/c.viewCollections';
import rc_Resources from '@salesforce/label/c.rc_Resources';
import rc_resource from '@salesforce/label/c.rc_resource';
import rc_Media from '@salesforce/label/c.rc_Media';
import results_for from '@salesforce/label/c.results_for';
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import {
    NavigationMixin
} from 'lightning/navigation';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import showLangSelect from "@salesforce/label/c.showLangSelect";
import {ComponentErrorLoging} from "c/formUtility";

export default class Rc_landing_container extends NavigationMixin(LightningElement) {
    @track heartIcon = assetFolder + "/icons/RC/heart-addtocollection.svg";
    @track showMore = assetFolder + "/icons/RC/show-more.svg";
    @track resources;
    @track media;
    @track results = {};
    @track resultspage = false;
    @track homepage = true;
    @track collectionspage = false;
    @track hideResources = false;
    @track hideMedia = false;
    @track searchTerm;
    @track showAll = true;
    @track resLength = 0;
    @track categoryResult;
    @track resourceLength = 6;
    @track resourceLoadMore = false;
    @track mediaLength = 2;
    @track mediaLoadMore = false;
    @track allTopicsPage = false;
    @track Popresources = [];
    @track mediaResources = [];
    @track landingMedia = true;
    @track collectionsList = []
    @track newCollections = [];
    @track indTopicPage = false;
    @track showModal = false;
    @track language;
    @track param = 'language';
    @track showMyCollections = true;
    @track spinner = false;
    @track ForgeRock_End_URL;
    @track compName = 'Rc_landing_container';
    @track showMediaResources = true;
    @track showPopResources = true;
    @track showLanguageDropdown = true;
    label = {
        rcPopularResources,
        rcMediaResources,
        showMore,
        viewCollections,
        rc_Resources,
        rc_Media,
        results_for,
        showLangSelect
    };

    get activeClass() {
        return this.homepage ? 'homepage' : 'resultspage';
    }

    connectedCallback() {
        if(this.label.showLangSelect === 'true') {
            this.showLanguageDropdown = true;
        } else {
            this.showLanguageDropdown = false;
        }
        const labelName = metadataLabel;
        window.addEventListener("my-account-clicked", () => {
            this.navigateToAccount();
        });
        window.addEventListener('login-clicked', () => {
            this.navigateToAccount();  
        });
        this.handlePageLoad();
        this.spinner = true;
        fetchInterfaceConfig({labelName})
            .then(result => {
                var parsedResult = JSON.parse(JSON.stringify(result));
                if(isGuestUser){
                    this.setURLParams();
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
    }
    setURLParams() {
        var url_string = document.location.href;
        var url = new URL(url_string);
        var arr = url_string.split("?");
        if (url_string.length > 1 && arr[1] !== "") {
            var URLParams = url.searchParams;
            this.language = URLParams.get(this.param);
        }
    }
    navigateToAccount() {
        if (isGuestUser) {
            window.location.href = this.link+'&'+this.param+'='+this.language;
        } else {
            window.location.href = this.link;
        }
    }
    handlePageLoad(){
        if (isGuestUser) {
            this.setURLParams();
        }
        this.spinner = true;
        this.isGuestUserAccount = isGuestUser;
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        this.searchString = urlParams.get('search');
        this.searchId = urlParams.get('id');
        this.getCollectionInfo();
        if (this.searchString === 'alltopics') {
            this.collectionspage = false
            this.resultspage = false;
            this.homepage = false;
            this.allTopicsPage = true;
            // this.NavigateToAllTopics();
            this.spinner = false;
        } else if (this.searchId) {
            this.collectionspage = false
            this.resultspage = true;
            this.homepage = false;
            this.allTopicsPage = false;
            this.gotoTopic(this.searchId);
            this.spinner = false;
        } else if (this.searchString) {
            this.collectionspage = false
            this.resultspage = true;
            this.homepage = false;
            this.allTopicsPage = false;
            this.handleSearchRefresh();
            this.spinner = false;
        } else {
            this.getLandingPageResources();
            this.spinner = false;
        }
    }
    getLandingPageResources() {
        this.spinner = true;
        getPopResource({
            language: this.language
        }).then(result => {
            let tempresult = JSON.parse(result);
            this.Popresources = tempresult.Resource;
            this.Popresources.forEach(element => {
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
                this.Popresources.forEach(element => {
                    element.showpopup = false;
                    element.collections = this.collectionsList;
                });
                if (this.Popresources && this.Popresources.length) {
                    this.Popresources.forEach(element => {
                        element.listSavedCollection.forEach(collection => {
                            if (collection.isSaved) {
                                element.isSaved = true
                            }
                        })
                    });
                }
            this.spinner = false;
        }).catch(error => {
            this.spinner = false;
            ComponentErrorLoging(this.compName, 'getPopResource', '', '', 'High', error.message);
            window.location.reload();
        });
        
        getMediaResource({
            language: this.language
        }).then(result => {
                let tempresult = JSON.parse(result);
                this.mediaResources = tempresult.Media;
                this.mediaResources.forEach(element => {
                    element.showpopup = false;
                    element.collections = this.collectionsList;
                });
                if (this.mediaResources && this.mediaResources.length) {
                    this.mediaResources.forEach(element => {
                        element.listSavedCollection.forEach(collection => {
                            if (collection.isSaved) {
                                element.isSaved = true
                            }
                        })
                    });
                }
            this.spinner = false;
        }).catch(error => {
            this.spinner = false;
            ComponentErrorLoging(this.compName, 'getMediaResource', '', '', 'High', error.message);
        });
    }
    handleResourceRemoved(event) {
        // this.singleColId = event.detail;
        this.Popresources = [];
        this.mediaResources = [];
        this.media = [];
        this.resources = [];
        this.spinner = true;
        setTimeout(() => {
            this.handlePageLoad();
            this.spinner = true;
        }, 100);
        this.reloadMyCollections(this.Popresources);
        setTimeout(() => {
            this.spinner = false;
        },3000)
     
    }
    handleSearchRefresh() {
        this.searchTerm = this.searchString;
        this.spinner = true;
        getSearch({
            searchTerm: this.searchString,
            categoryFilters: '',
            language: this.language
        })
        .then(result => {
            result = JSON.parse(result);
            if (result) {
                this.results = result;
                this.updateResult();
            }
                this.spinner = false;
        })
        .catch(error => {
            this.spinner = false;
            ComponentErrorLoging(this.compName, 'getSearch', '', '', 'High', error.message);
            window.location.reload();
        });
    }

    handleSearch(event) {
        this.spinner = true;
        this.resources = null;
        this.media = null;
        this.results={};
        this.resourceLength = 6;
        this.mediaLength = 2;
        this.allTopicsPage = false;
        this.resultspage = false;
        if (event.detail) {
            this.results = event.detail.results;
            this.searchTerm = event.detail.searchTerm;
            this.searchId = '';
            this.indTopicPage = false;
        } else {
            this.results = event;
            this.searchTerm = this.searchString;
            this.searchId = this.searchId;
            this.indTopicPage = true;
        }
        this.homepage = false;
        this.updateResult();

        if(this.searchId) {
            var url = new URL(document.location.href);
            var URLParams = url.searchParams;
            var tid = URLParams.get('id');
        }
        if(this.searchId && !tid) {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "rclanding__c"
                },
                state: {
                    language: this.language,
                    search: this.searchTerm,
                    id: this.searchId
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "rclanding__c"
                },
                state: {
                    language: this.language,
                    search: this.searchTerm
                }
            });
        }
        setTimeout(() => {
            this.resultspage = true;
            var element = this.template.querySelector('c-rc_filters');
            element.resetFilter();
        }, 0);           
    }
    updateResult() {
        this.resources = null;
        this.media = null;
        if (this.results && (this.results.Resource && this.results.Media)) {
            this.resources = this.results.Resource;
            this.allResourcesCount = this.resources.length;
            this.media = this.results.Media;
            this.allMediaCount = this.media.length;
            if(this.hideResources) {
                this.resLength = this.media.length;   
            } else if(this.hideMedia) {
                this.resLength = this.resources.length;
            } else {
                this.resLength = this.resources.length + this.media.length;
            }
        } else if (this.results && this.results.Resource) {
            this.resources = this.results.Resource;
            this.allResourcesCount = this.resources.length;
            this.allMediaCount = 0;
            this.media = null;
            if(this.hideResources) {
                this.resLength = this.media.length;   
            } else if(this.hideMedia) {
                this.resLength = this.resources.length;
            } else {
                this.resLength = this.resources.length;
            } 
            
        } else if (this.results && this.results.Media) {
            this.media = this.results.Media;
            this.allMediaCount = this.media.length;
            this.allResourcesCount = 0;
            this.resources = null;
            if(this.hideResources) {
                this.resLength = this.media.length;   
            } else if(this.hideMedia) {
                this.resLength = this.resources.length;
            } else {
                this.resLength = this.media.length;
            }
        } else {
            this.resources = null;
            this.allResourcesCount = 0;
            this.media = null;
            this.allMediaCount = 0;
            this.resLength = 0;
        }
        if(this.resources && this.resources.length) {
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
        }
        let count = 0;
        let tempResource = [];
        if (this.resources && this.resources.length) {
            this.resources.forEach(element => {
                if (count < this.resourceLength) {
                    tempResource.push(element);
                    count++;
                    this.resourceLoadMore = false;
                } else {
                    this.resourceLoadMore = true;
                }
            });
            this.resources = tempResource;
        }
        this.getCollectionInfo();
        let mediaCount = 0;
        let tempMedia = [];
        if (this.media && this.media.length) {
            this.media.forEach(element => {
                if (mediaCount < this.mediaLength) {
                    tempMedia.push(element);
                    mediaCount++;
                    this.mediaLoadMore = false;
                } else {
                    this.mediaLoadMore = true;
                }
            });
            this.media = tempMedia;
        }
        if (this.resources) {
            this.resources.forEach(element => {
                element.showpopup = false;
                element.collections = this.collectionsList;
            });
        }
        if (this.media) {
            this.media.forEach(element => {
                element.showpopup = false;
                element.collections = this.collectionsList;
            });
            this.updateThumbnail();
        }
        this.spinner = false;
    }
    getCollectionInfo() {
        this.spinner = true;
        getAllCollections()
            .then(result => {
                this.collectionsList = [];
                result = JSON.parse(result);
                this.fullCollections = result;
                result.forEach(element => {
                    this.collectionsList.push({
                        "value": element.collection.Name,
                        "id": element.collection.Id,
                        "label": element.collection.Name
                    })
                })
                this.getSelectedHeart();
                this.spinner = false;
            })
            .catch((error) => {
                this.spinner = false;
                ComponentErrorLoging(this.compName, 'getAllCollections', '', '', 'High', error.message);
            });
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
    
    showMoreResourceKey(event) {
        if (event.keyCode == 13) {
            this.showMoreResource();
        }
    }
    showMoreResource() {
        this.resourceLength = this.resourceLength + 6;
        let count = 0;
        let tempResource = [];
        this.resources = this.results.Resource;
        if (this.resources && this.resources.length) {
            this.resources.forEach(element => {
                if (count < this.resourceLength) {
                    tempResource.push(element);
                    count++;
                }
            });
            if (tempResource.length === this.resources.length) {
                this.resourceLoadMore = false;
            } else {
                this.resourceLoadMore = true;
            }
            this.resources = JSON.parse(JSON.stringify(tempResource));
        }
    }
    showMoreMediaKey(event) {
        if (event.keyCode == 13) {
            this.showMoreMedia();
        }
    }
    showMoreMedia() {
        this.mediaLength = this.mediaLength + 2;
        let mediaCount = 0;
        let tempMedia = [];
        this.media = this.results.Media;
        if (this.media && this.media.length) {
            this.media.forEach(element => {
                if (mediaCount < this.mediaLength) {
                    tempMedia.push(element);
                    mediaCount++;
                    this.mediaLoadMore = false;
                } else {
                    this.mediaLoadMore = true;
                }
            });
            this.media = tempMedia;
            this.updateThumbnail();
        }
    }

    updateThumbnail() {
        this.media = JSON.parse(JSON.stringify(this.media));    
        this.media.forEach(element => {
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
    }

    handleFilterChange(event) {
        this.filterType = event.detail;
        let tempMedia = [];
        let tempResource = [];
        if(this.results) {
            if(this.results.Media) {
                tempMedia = this.results.Media; 
            }
            if(this.results.Resource) {
                tempResource = this.results.Resource;
            }
        }
        let resourceString = rc_resource;
        let mediaString = rc_Media;
        this.filterType = this.filterType.toLowerCase();
        resourceString = resourceString.toLowerCase();
        mediaString = mediaString.toLowerCase();
        if (this.filterType === mediaString) {
            this.hideResources = true;
            this.hideMedia = false;
            this.resLength = tempMedia.length;
        } else if (this.filterType === resourceString) {
            this.hideMedia = true;
            this.hideResources = false;
            this.resLength = tempResource.length;
        } else if (this.filterType === 'clearfilters') {
            this.hideMedia = false;
            this.hideResources = false;
            this.resLength = tempMedia.length + tempResource.length;
        }
    }
    handleCategoryResult(event) {
        this.resourceLength = 6;
        this.mediaLength = 2;
        this.categoryResult = event.detail;
        this.results = JSON.parse(this.categoryResult);
        this.updateResult();
    }
    NavigateToCollectionPageKey(event) {
        if (event.keyCode == 13) {
            this.NavigateToCollectionPage();
        }
    }
    NavigateToCollectionPage() {
        if (isGuestUser) {
            this.showModal = true;
        } else {
            window.location = 'mycollections';
        }
    }
    handleModalClose() {
        this.showModal = false;
    }
    NavigateToAllTopics(event) {
        window.scrollTo({
            top: 0,
            behavior: "smooth"
        });
        if (event.detail) {
            this.collectionspage = false
            this.resultspage = false;
            this.homepage = false;
            this.allTopicsPage = true;

            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "rclanding__c"
                },
                state: {
                    language: this.language,
                    search: 'alltopics'
                }
            });
        } else {
            this.collectionspage = false
            this.resultspage = false;
            this.homepage = false;
            this.allTopicsPage = true;
        }

    }

    gotoTopic(event) {
        this.spinner=true;
        this.allTopicsPage = false;
        if(event.detail) {
            this.indTopicName = event.detail.name;
            var topicId = event.detail.id;
            this.searchString = this.indTopicName;
            this.searchId = topicId;
        } else {
            this.indTopicName = this.searchString;
            var topicId = this.searchId;
        }
        getKnowledgeByTopicANDCategory({
                TopicID: topicId,
                categoryList: [],
                language: this.language
            })
            .then(result => {
                if(result) {
                    result = JSON.parse(result);
                    this.handleSearch(result);
                }
                window.scrollTo({
                    top: 0,
                    behavior: "smooth"
                });
                this.spinner=false;
            })
            .catch((error) => {
                this.spinner = false;
                ComponentErrorLoging(this.compName, 'getKnowledgeByTopicANDCategory', '', '', 'High', error.message);
                window.location.reload();
            });
    }

    reloadMyCollections(event) {
        if (event && event.detail && event.detail.result) {
            this.collectionsList = event.detail.result;
            this.Popresources.forEach(element => {
                element.collections = event.detail.result;
            });
            this.mediaResources.forEach(element => {
                element.collections = event.detail.result;
            });
            if (this.resources && this.resources.length) {
                this.resources = JSON.parse(JSON.stringify(this.resources));
               this.resources.forEach(element => {
                element.collections = this.collectionsList;
            });
            }
            if (this.media && this.media.length) {
            this.media.forEach(element => {
                element.collections = this.collectionsList;
            }); 
            }
            if (event.detail.isResource) {
            this.showMediaResources = false;
            } else {
            this.showPopResources = false;
        }
        }

        this.showMyCollections = false;
        this.spinner = true;
        setTimeout(() => {
            this.showMyCollections = true;
            this.spinner = false;
            if (event && event.detail.result) {
                if (event.detail.isResource) {
                this.showMediaResources = true;
                } else {
                this.showPopResources = true;
                }
            }
        }, 0);
    }

    languageChangeHandler(event) {
        let section = event.detail;
        this.language = section;
        this.link = this.ForgeRock_End_URL;
        const paramValue = new URL(window.location.href).searchParams.get(this.param);  
        var urlParam = window.location.href;
        urlParam = urlParam.replace(this.param+'='+paramValue,this.param+'='+section);
        location.href=urlParam;
    }
}
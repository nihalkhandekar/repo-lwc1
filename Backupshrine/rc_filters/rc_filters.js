import {
    LightningElement,
    track,
    api
} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";

import getCategory from "@salesforce/apex/BOS_KnowledgeResources.businessDataCategoryStructure";
import getResultType from "@salesforce/apex/ResourceGlobalSearch.getResultType";
import getFilterResult from "@salesforce/apex/ResourceGlobalSearch.getSearch";
import getKnowledgeByTopicANDCategory from "@salesforce/apex/BOS_KnowledgeResources.getKnowledgeByTopicANDCategory";
import rc_Filters_label from '@salesforce/label/c.rc_Filters_label';
import rc_Result_type from '@salesforce/label/c.rc_Result_type';
import rc_Clear_Filters from '@salesforce/label/c.rc_Clear_Filters';
import rc_Category from '@salesforce/label/c.rc_Category';
import isGuestUser from '@salesforce/user/isGuest';
import { ComponentErrorLoging } from "c/formUtility";

export default class Rc_filters extends LightningElement {
    @track libraryIcon = assetFolder + "/icons/RC/library-outline.svg";
    @track filterIcon = assetFolder + "/icons/RC/filter-outline.svg";
    @track closeIcon = assetFolder + "/icons/closeIcon.png";
    @track upArrow = assetFolder + "/icons/RC/triangle-up-circle.svg";
    @track downArrow = assetFolder + "/icons/RC/triange-down-circle.svg";
    @track showFilter = true;
    @track options = [];
    @track selectedFilters = [];
    @track selectedCategories = [];
    @track selectedCategoryList = [];
    @track selectedFilterList = [];
    @track filter = true;
    @track expandFilter = true;
    @track showSelectedFilter = false;
    @api searchString;
    @track categoryOptions = [];
    @track spinner = false;
    @track language;
    @track param = 'language';
    @track toggleFilter = true;
	@api topicId;

    label ={
        rc_Filters_label,
        rc_Result_type,
        rc_Clear_Filters,
        rc_Category
    };

    connectedCallback() {
        getCategory()
            .then(result => {
                result = JSON.parse(result);
                result.forEach(element => {
                    this.categoryOptions.push({
                        label: element.label,
                        value: element.name,
                        id: element.name
                    })
                });
            })
            .catch((errpr) => {
                ComponentErrorLoging("rc_filters", 'getCategory', '', '', 'High', error.message);
            });
        getResultType()
            .then(result => {
                result = JSON.parse(result);
                result.forEach(element => {
                    this.options.push({
                        label: element.label,
                        value: element.value,
                        id: element.value
                    })
                });
            })
            .catch((error) => {
                ComponentErrorLoging("rc_filters", 'getResultType', '', '', 'High', error.message);
            });
        if(isGuestUser){
            var url_string = document.location.href;
            var url = new URL(url_string);
    
            var arr = url_string.split("?");
            if (url_string.length > 1 && arr[1] !== "") {
                var URLParams = url.searchParams;
                this.language = URLParams.get(this.param);
            }
        }
    }
    getCategoryResult() {
        this.spinner = true;
        if(this.topicId) {
            getKnowledgeByTopicANDCategory({
                TopicID: this.topicId,
                categoryList: JSON.stringify(this.selectedCategories),
                language: this.language
            }).then(result => {
                const filterTypeEvent = new CustomEvent("categoryselection", {
                    detail: result
                });
                this.dispatchEvent(filterTypeEvent);
                this.spinner = false;
            })
            .catch((error) => {
                ComponentErrorLoging("rc_filters", 'getKnowledgeByTopicANDCategory', '', '', 'High', error.message);
            });
        } else {
            getFilterResult({
                searchTerm: this.searchString,
                categoryFilters: JSON.stringify(this.selectedCategories),
                language: this.language
            }).then(result => {
                const filterTypeEvent = new CustomEvent("categoryselection", {
                    detail: result
                });
                this.dispatchEvent(filterTypeEvent);
                this.spinner = false;
            })
            .catch((error) => {
                ComponentErrorLoging("rc_filters", 'getFilterResult', '', '', 'High', error.message);
            });
        }
    }
    handlecheckboxResult(event) {
        try {
            this.selectedCategories = event.detail.result;
            if (this.selectedCategories.length) {
                this.showSelectedFilter = true;
            }
            let tempCategory = [];
            this.selectedCategories.forEach(element => {
                this.categoryOptions.forEach(el => {
                    if (el.value === element) {
                        tempCategory.push({
                            "label": el.label,
                            "value": el.value
                        });
                    }
                })
            });
            this.selectedCategoryList = tempCategory;
            this.getCategoryResult();
        } catch (error) {
            ComponentErrorLoging("rc_filters", 'handlecheckboxResult', '', '', 'High', error.message);
        }
    }
    getResultRefined() {
        if (this.selectedFilters.length === 1) {
            const filterTypeEvent = new CustomEvent("filterselection", {
                detail: this.selectedFilters[0]
            });
            this.dispatchEvent(filterTypeEvent);
        } else {
            const filterTypeEvent = new CustomEvent("filterselection", {
                detail: 'clearFilters'
            });
            this.dispatchEvent(filterTypeEvent);
        }
    }
    handleFiltercheckboxResult(event) {
        try {
            this.selectedFilters = event.detail.result;
            if (this.selectedFilters.length) {
                this.showSelectedFilter = true;
            }
            let tempOpts = [];
            this.selectedFilters.forEach(element => {
                this.options.forEach(el => {
                    if (el.value === element) {
                        tempOpts.push({
                            "label": el.label,
                            "value": el.value
                        });
                    }
                })
            });
            this.selectedFilterList = tempOpts;
            this.getResultRefined();
        } catch (error) {
            ComponentErrorLoging("rc_filters", 'handleFiltercheckboxResult', '', '', 'High', error.message);
        }
    }

    handleShowFilter() {
        this.expandFilter = !this.expandFilter;
    }
    handleClearFilters() {
        this.selectedFilters = [];
        this.selectedCategories = [];
        this.selectedCategoryList = [];
        this.selectedFilterList = [];
        this.getCategoryResult();
    }
    handleCategoryClose(event) {
        let targetId = event.target.id;
        let dataId = event.currentTarget.dataset.id;
        let temp = targetId.split("-");
        targetId = temp[0];
        let tempList = [];
        this.selectedCategoryList.forEach(element => {
            if (element.label != targetId) {
                tempList.push(element);
            }
        });
        let tempListValue = [];
        this.selectedCategories.forEach(element => {
            if (element != dataId) {
                tempListValue.push(element);
            }
        });
        this.selectedCategoryList = tempList;
        this.selectedCategories = tempListValue;
        this.getCategoryResult();


    }
    handleFilterClose(event) {
        let targetId = event.target.id;
        let dataId = event.currentTarget.dataset.id;
        let temp = targetId.split("-");
        targetId = temp[0];
        let tempList = [];
        this.selectedFilterList.forEach(element => {
            if (element.label != targetId) {
                tempList.push(element);
            }
        });
        let tempListValue = [];
        this.selectedFilters.forEach(element => {
            if (element != dataId) {
                tempListValue.push(element);
            }
        });
        this.selectedFilterList = tempList;
        this.selectedFilters = tempListValue;
        this.getResultRefined();
    }

    @api
    resetFilter() {
        this.toggleFilter = false;
        setTimeout(() => {
            this.toggleFilter = true;
            this.selectedCategories = [];
            this.selectedFilters = [];
        }, 0);
        
    }
}
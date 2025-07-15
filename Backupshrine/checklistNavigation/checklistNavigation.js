/**
 * @File Name          : checklistNavigation.js
 * @Description        : Displays Navigation progressItem
 * @Author             : Rahul Bussa
 * @Last Modified By   : Rahul Bussa
 * @Last Modified On   : 17.05.2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    14.05.2020        Rahul Bussa             Initial Version
 * 2.0    17.05.2020        Rahul Bussa             Added Comments/modified css
 **/

import { LightningElement, track, api } from 'lwc';
//Importing Static Resources
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
//Importing Custom Labels, Static Resources
import checklistStaticText from "@salesforce/label/c.checklistStaticText";
import qnaError from "@salesforce/label/c.QnA_Error";
import answerAllQuestions from "@salesforce/label/c.QnA_Answer_all_the_questions";
import businessChecklist from "@salesforce/label/c.businessChecklist";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import toastVariants from "c/appConstants";
import ReviewSectionName from "@salesforce/label/c.ReviewSectionName";
//Error logging
import { ComponentErrorLoging } from "c/formUtility";

export default class ChecklistNavigation extends LightningElement {
    activeIcon = assetFolder + '/icons/caret-down-outline.svg#caretdown';
    successIcon = assetFolder + '/icons/checkmark-outline.svg#checkmarkwhite';
    forwardActiveIcon = assetFolder + '/icons/caret-forward-circle-outline-active.svg#carecircleforwardactive';
    forwardPassiveIcon = assetFolder + '/icons/caret-forward-circle-outline-passive.svg#carecircleforwardpassive';
    backwardActiveIcon = assetFolder + '/icons/caret-back-circle-outline-active.svg#caretcirclebackactive';
    backwardPassiveIcon = assetFolder + '/icons/caret-back-circle-outline-passive.svg#caretcirclebackpassive';


    @track activeObj;
    @track _progress=[];


    label={
        checklistStaticText,
        answerAllQuestions,
        qnaError,
        businessChecklist
    }
    @api
    changeFocus(shiftFocus) {
    if (shiftFocus) {
      setTimeout(() => {
        let tab = this.template.querySelectorAll(".slds-is-active");
        tab[0].setAttribute("tabindex", "0");
        tab[0].focus();
      }, 100);
    }
    }
    get setprogress(){
        return this._progress;
    }

    @api 
    set setprogress(value){
        try {
            let list = [];
        
            if(value){
                for(let i=0;i<value.length;i++){
                    let obj={};
                    obj.title = value[i].title;
                    if(value[i].hasOwnProperty('isSectionComplete')){
                        obj.isSectionComplete = value[i].isSectionComplete;
                    }
                    if(value[i].hasOwnProperty('isCurrentTab')){
                        obj.isCurrentTab = value[i].isCurrentTab;
                    }
                    if(value[i].hasOwnProperty('isInProgress')){
                        obj.isInProgress = value[i].isInProgress;
                    }
                    if(value[i].hasOwnProperty('isStarted')){
                        obj.isStarted = value[i].isStarted;
                    }
                    obj.id = value[i].id;
                        
                    if (value[i].title === ReviewSectionName) {
                        obj.activeIconPath = assetFolder+"/icons/review-active.svg#reviewactive";
                        obj.passiveIconPath = assetFolder+"/icons/review-passive.svg#reviewpassive";
                    }else{
                        let icon = value[i].image;
                        if(icon){
                            icon = icon.split(".");
                            if(icon.length){
                                obj.activeIconPath = assetFolder+"/icons/"+icon[0]+"-active.svg#"+icon[0]+"active";
                                obj.passiveIconPath = assetFolder+"/icons/"+icon[0]+"-passive.svg#"+icon[0]+"passive";
                            }
                        }
                    }
                    obj.statusIcon = assetFolder + '/icons/caret-down-outline.svg#caretdown';
                    list.push(obj);
                }
                this._progress = list;
            }
        }catch(error){
            ComponentErrorLoging(
                "checklistNavigation",
                "getTranslationCodes",
                "",
                "",
                "High",
                error.message
            );
        }
    }
    connectedCallback() {
        document.addEventListener('keydown', function () {
            document.documentElement.classList.remove('mouseClick');
        });
        document.addEventListener('mousedown', function () {
            document.documentElement.classList.add('mouseClick');
        });
    }
    /**
     * Handles focus on navigation item
     * @param {*} e
     */
    handleFocus(event) {
        if (event.keyCode === 13 || event.keyCode === 32) {
        let id = event.target.id;
        let temp = id.split("-");
        id = temp[0];
        this.template.querySelectorAll("button")[id].click();
        }
    }
    
    /**
     * Handles click on navigation item
     * @param {*} e 
     */
    handleClick(e) {
        try{
            let element = e.currentTarget;
            let elements = this._progress;
            if (element) {
                let title = element.getAttribute('data-id');
                let activeItemIndex = this.findItemByTitle(title);
                if (title && activeItemIndex>-1) {
                    //check whether path is valid;
                    let item = elements[activeItemIndex];
                    if(item.isSectionComplete || item.isCurrentTab || item.isInProgress || item.isStarted ){
                        this.throwEvent(title);
                    }else {
                        this.toastError(
                            this.label.qnaError,
                            this.label.answerAllQuestions
                        );
                    }
                }
            }
        }catch(error){
            ComponentErrorLoging(
                "checklistNavigation",
                "handleClick",
                "",
                "",
                "Medium",
                error.message
            );
        }
    }
    /**
     * Handles click of previous icon in mobile mode
     */
    handleLeftClick() {
        let elements = this._progress;
        try{
            if(elements){
                // Get the Left element title of active element
                let activeIndex = this.findActiveIndex();
                if(activeIndex>0){
                    //get the title of activeIndex-1
                    let prevTitle = elements[activeIndex-1].title;
                    if(prevTitle){
                        this.throwEvent(prevTitle);
                    }
                }
            }
        }catch(err){
            ComponentErrorLoging(
                "checklistNavigation",
                "handleLeftClick",
                "",
                "",
                "High",
                error.message
            );
        }
    }
    /**
     * Reusable function to throw active event on click of navigation Item
     * @param {*} title 
     */
    throwEvent(title){
        if(title){
            const evt = new CustomEvent('active', {
                detail:{
                    title: title
                }
            });
            this.dispatchEvent(evt);
        }
    }
    /**
     * Handles click of next icon in mobile mode
     */
    handleRightClick() {
        let elements = this._progress;
        try{
            if(elements){
                // Get the Left element title of active element
                let activeIndex = this.findActiveIndex();
                if(activeIndex>=0 && activeIndex<elements.length){
                    //get the title of activeIndex-1
                    let nextTitle = elements[activeIndex+1].title;
                    if(nextTitle){
                        this.throwEvent(nextTitle);
                    }
                }
            }
        }catch(error){
            ComponentErrorLoging(
                "checklistNavigation",
                "handleRightClick",
                "",
                "",
                "High",
                error.message
            );
        }
    }

   /**
    * This method return active tab title in mobile mode.
    */
    get activeLabel() {
        if (this._progress) {
            let active = '';
            try {
                for (let i = 0; i < this._progress.length; i++) {
                    if (this._progress[i].isCurrentTab) {
                        active = this._progress[i].title;
                        break;
                    }
                }
            } catch(error) {
                ComponentErrorLoging(
                    "checklistNavigation",
                    "activeLabel",
                    "",
                    "",
                    "High",
                    error.message
                );
            }
            return active;

        }
        return '';
    }
    /**
    * This method return previous Icon value either active or passive in mobile mode.
    */
    get prevIcon() {
        if(this._progress){
            let index = this.findActiveIndex();
            if(index>0){
                //find if prev index is visited
                if(this._progress[index-1].isStarted){
                    return this.backwardActiveIcon;
                }
                return this.backwardPassiveIcon;
            }else{
                //return passive
                return this.backwardPassiveIcon;
            }
        }
        return this.backwardPassiveIcon;
    }

    /**
    * This method return next Icon value either active or passive in mobile mode.
    */
    get nextIcon() {
        if(this._progress){
            let index = this.findActiveIndex();
            if(index>=0 && index<this._progress.length){
                //find if prev index is visited
                if(this._progress[index+1] && (this._progress[index+1].isStarted || 
                    this._progress[index+1].isCurrentTab ||
                    this._progress[index+1].isInProgress ||
                    this._progress[index+1].isStarted)){
                    return this.forwardActiveIcon;
                }
                return this.forwardPassiveIcon;
            }else{
                //return passive
                return this.forwardPassiveIcon;
            }
        }
        return this.forwardPassiveIcon;
    }

    /**
     * Reusable method to return the index of active Tab 
     */
    findActiveIndex(){
        let index = -1;
        for(let i=0;i<this._progress.length;i++){
            if (this._progress[i].isCurrentTab) {
                index = i;
                break;
            }
        }
        return index;
    }

    findItemByTitle(title){
        let elements = this._progress;
        let found  = -1;
        if(title){
            for(let i=0;i<elements.length;i++){
                if(elements[i].title === title){
                    found = i;
                    break;
                }
            }
        }
        return found;
    }

    /**
     * Handle error in the component
     * @param {*} err 
     * @param {*} stack 
     */
    errorCallback(error) {
        ComponentErrorLoging('checklistNavigation', 'errorCallback', '', '', 'Low', error.message);
    }

    /**
     * Reusable method to fire toast event
     * @param {*} error 
     * @param {*} title 
     */
    toastError(error, title) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: title,
            message: error,
            variant: toastVariants.error
          })
        );
    }
}
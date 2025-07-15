/**
 * @File Name          : checklistAddressItem.js
 * @Description        : Displays City/Town address content in checklist page
 * @Author             : Rahul Bussa
 * @Last Modified By   : Rahul Bussa
 * @Last Modified On   : 12.05.2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    12.05.2020        Rahul Bussa             Initial Version
**/
import { LightningElement, api } from 'lwc';
import { insertRecord } from "c/genericAnalyticsRecord";
import { isUndefinedOrNull } from "c/appUtility";
//Importing Static Resources
import assetFolder from "@salesforce/resourceUrl/CT_Assets";

export default class ChecklistAddressItem extends LightningElement {

    @api address;
    questionnaireId;
    linkIcon = assetFolder + "/icons/open-outline-blue.svg#open-outline-blue";

    get newaddress(){
        return this.address;
    }

    get dynamicData(){
        return this.address.dynamicData? this.address.dynamicData: [];
    }

    connectedCallback() {
        this.questionnaireId = new URL(document.location.href).searchParams.get("c__parentObjId");

        setTimeout(() => {
			this.renderRTEText(); 
		}, 800);
    }

    renderRTEText() {
		let ele = this.template.querySelector('.'+this.address.subsectionId);
		
		if(ele) {
            ele.innerHTML = this.address.rteText;
            ele.classList.add('itemText large checklistaddress__static-contenet');
        }
    }

    handleRichTextClick(event) {
        if(!isUndefinedOrNull(event.target.getAttribute("href"))) {
			this.insertAnalyticsEvent("Before you register", event.target.getAttribute("href"), event.target.textContent);
		} else if(!isUndefinedOrNull(event.target.parentNode.getAttribute("href"))) {
			this.insertAnalyticsEvent("Before you register", event.target.parentNode.getAttribute("href"), event.target.textContent);
      	}
    }

    renderedCallback() {
		let self = this;
		const temp = this.template.querySelectorAll('a');
			
		if(temp && temp.length) {		
			temp.forEach(element => {
				element.addEventListener("click", function(event) {
					event.preventDefault();
			
					setTimeout((function(ev) {
						let targetLink = ev.target.getAttribute("href");
						self.insertAnalyticsEvent(self.sectiontitle, targetLink, ev.target.textContent);
					
						window.open(targetLink, '_blank');
					})(event), 2000);
				});
			
				element.addEventListener("contextmenu", function(event) {
					setTimeout((function(ev) {
						self.insertAnalyticsEvent(self.sectiontitle, ev.target.getAttribute("href"), ev.target.textContent);
					})(event), 2000);
				});
			});                
		} 
	}
	
	insertAnalyticsEvent(sectiontitle, targetLink, targetText) {
		let startTime = new Date().getTime();
		insertRecord(
			this.questionnaireId, 
			"Checklist Generated Page", 
			sectiontitle, 
			"",
			"BusinessChecklist",
			"Link Click",
			targetLink,
			targetText,
			startTime,
			""
		);
	}
}
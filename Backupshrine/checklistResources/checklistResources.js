/**
 * @File Name          : checklistResources.js
 * @Description        : Displays Resources content in checklist page
 * @Author             : Rahul Bussa
 * @Last Modified By   : Rahul Bussa
 * @Last Modified On   : 11.05.2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    11.05.2020        Rahul Bussa             Initial Version
**/
import { LightningElement, api } from 'lwc';
//Importing Static Resources
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
//Importing Custom Labels, Static Resources
import Checklist_Item_Resources_Description from "@salesforce/label/c.Checklist_Item_Resources_Description";
import { insertRecord } from "c/genericAnalyticsRecord";
import { isUndefinedOrNull } from "c/appUtility";

export default class ChecklistResources extends LightningElement {
    @api title;
    @api resources;
    @api sectiontitle;

    label = {
        Checklist_Item_Resources_Description
    };

    questionnaireId;
    linkIcon = assetFolder + "/icons/open-outline-blue.svg#open-outline-blue";
    
    connectedCallback() {
        this.questionnaireId = new URL(document.location.href).searchParams.get("c__parentObjId");
        this.resources = JSON.parse(JSON.stringify(this.resources));
        this.resources.dynamicData.forEach(element => {
            element.resources.forEach(item => {
                item.resourceTel = "tel:"+item.resourceNumber;
            });
        });

        setTimeout(() => {
			this.renderRTEText(); 
		}, 800);
    }
    
    get dynamicData(){
        return this.resources?this.resources.dynamicData:[];
    }

    renderRTEText() {
    	let ele = this.template.querySelector('.'+this.resources.subsectionId);
		  
		if(ele) {
        	ele.innerHTML = this.resources.rteText;
        	ele.classList.add('itemText large');
        }
          
        setTimeout(() => {
			this.renderRTEText(); 
		}, 800);
    }

    handleRichTextClick(event){
		let targetLink;

		if(event.target.getAttribute("href")) {
			targetLink = event.target.getAttribute("href");
		} else if(event.target.parentNode.getAttribute("href")) {
			targetLink = event.target.parentNode.getAttribute("href");
		} else if(event.target.parentNode.parentNode.getAttribute("href")) {
			targetLink = event.target.parentNode.parentNode.getAttribute("href");
		}

		if(targetLink) {
			this.insertAnalyticsEvent("Resources", targetLink, event.target.textContent);
		}	
    }

    renderedCallback() {
		let self = this;
		const temp = this.template.querySelectorAll('a');
			
		if(temp && temp.length) {
			this.isLoaded = true;
			
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
		insertRecord(
			this.questionnaireId, 
			"Checklist Generated Page", 
			sectiontitle, 
			"",
			"BusinessChecklist",
			"Link Click",
			targetLink,
			targetText,
			null,
			""
		);
	}
}
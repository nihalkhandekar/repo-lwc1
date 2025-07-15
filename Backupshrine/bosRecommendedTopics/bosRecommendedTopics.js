import {
    LightningElement,
    track,
    api
} from 'lwc';
// import getResources from "@salesforce/apex/BOS_Topics.getRecommendedArticles";
import getFeaturedTopics from "@salesforce/apex/BOS_Topics.getRecommendedTopics";
import getPopTopics from "@salesforce/apex/BOS_KnowledgeResources.getFeaturedPopularTopicRecords";
import getAllTopics from "@salesforce/apex/BOS_TopicController.getAllTopics";

import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import isGuestUser from '@salesforce/user/isGuest';
import FORM_FACTOR from '@salesforce/client/formFactor'
import Popular_topics from "@salesforce/label/c.Popular_topics";
import rc_View_All_Topics from "@salesforce/label/c.rc_View_All_Topics";
import rc_Recommended_topics from "@salesforce/label/c.rc_Recommended_topics";
import rc_All_topics from "@salesforce/label/c.rc_All_topics";
import rc_Show_more_topics from "@salesforce/label/c.rc_Show_more_topics";
import HelpfulResourceTopics from "@salesforce/label/c.HelpfulResourceTopics";
import GoToResourceCenter from "@salesforce/label/c.GoToResourceCenter";
import { NavigationMixin } from 'lightning/navigation';
import { insertRecord } from "c/genericAnalyticsRecord";
import { ComponentErrorLoging } from "c/formUtility";

// getFeaturedTopics1
export default class bosRecommendedTopics extends NavigationMixin(LightningElement) {
    @track featuredTopics = [];
    @track popTopics = [];
    @track popCardArr = [];
    @track topicCardArr = [];
    @track recCardArr = [];
    @track alltopicCardArr = [];
    @track blueArrow = assetFolder + "/icons/RC/arrow-forward-outline.svg";
    @track showMore = assetFolder + "/icons/RC/show-more.svg";
    @track isLoggedIn = false;
    @track topicsCount = 0;
    @track spinner = false;
    @track isMob = false
    @api alltopics;
    @api dashboard;
    @track startTime;
    @track language;
    @track param = 'language';
    @track showMoreCards = true;
    label = {
        Popular_topics,
        rc_View_All_Topics,
        rc_Recommended_topics,
        rc_All_topics,
        rc_Show_more_topics,
        HelpfulResourceTopics,
        GoToResourceCenter
    };
    detectMob() {
        return ((window.innerWidth <= 800) && (window.innerHeight <= 600));
    }
    connectedCallback() {
		this.startTime = new Date().getTime();
        if(isGuestUser){
            var url_string = document.location.href;
            var url = new URL(url_string);  
            var arr = url_string.split("?");
            if (url_string.length > 1 && arr[1] !== "") {
              var URLParams = url.searchParams;
              this.language = URLParams.get(this.param);
            }
        }
        if (this.alltopics) {
            this.spinner = true;
            getAllTopics({
                language: this.language
            }).then(result => {
                this.alltopics = JSON.parse(result);
                if (this.alltopics && this.alltopics.length) {
                    this.alltopics.forEach(element => {
                        this.alltopicCardArr.push({
                            "name": element.topicRec.Name,
                            "imgSrc": element.imgSrc,
                            "id": element.topicRec.Id
                        })
                    });
                }
                this.isMob = this.detectMob();
                if (FORM_FACTOR === "Small" || FORM_FACTOR === "Medium") {
                    this.isMob = true;
                    let temp = [];
                    if (this.alltopics && this.alltopics.length) {
                        // let count = 0;
                        this.alltopics.forEach(element => {
                            if (this.topicsCount < 4) {
                                temp.push({
                                    "name": element.topicRec.Name,
                                    "imgSrc": element.imgSrc,
                                    "id": element.topicRec.Id
                                })
                                this.topicsCount++;
                            }
                        });
                        this.alltopicCardArr = temp;
                    }
                }
                this.topicCardArr = this.alltopicCardArr;
                this.spinner = false;
            })
            .catch(error => {
                this.spinner = false;
                ComponentErrorLoging('bosRescommendedTopics', 'getAllTopics', '', '', 'High', error);
                window.location.reload();
            });
        } else {
            if (isGuestUser) {
                this.spinner = true;
                this.isLoggedIn = false;
                getPopTopics({
                    language: this.language
                })
                .then(result => {
                    this.popTopics = JSON.parse(result);
                    if (this.popTopics && this.popTopics.length) {
                        this.popTopics.forEach(element => {
                            this.popCardArr.push({
                                "name": element.topicRec.Name,
                                "imgSrc": element.imgSrc,
                                "id": element.topicRec.Id
                            })
                        });
                    }
                        this.spinner = false;
                })
                .catch(error => {
					this.spinner = false;
                    ComponentErrorLoging(
                        "bosRecommendedTopics",
                        "getPopTopics",
                        "",
                        "",
                        "High",
                        error.message
                    );
                });
            } else {
                this.isLoggedIn = true;
                this.spinner = true;
                getFeaturedTopics()
                .then(result => {
                    this.featuredTopics = JSON.parse(result);
                    if (this.featuredTopics && this.featuredTopics.length) {
                        this.featuredTopics.forEach(element => {
                            this.recCardArr.push({
                                "name": element.topicRec.Name,
                                "imgSrc": element.imgSrc,
                                "id": element.topicRec.Id
                            })
                        });
                    }
                        this.spinner = false;
                })
                .catch(error => {
					this.spinner = false;
                    ComponentErrorLoging(
                        "bosRecommendedTopics",
                        "getFeaturedTopics",
                        "",
                        "",
                        "High",
                        error.message
                    );
                });
            }

            if (this.isLoggedIn) {
                this.topicCardArr = this.recCardArr;
            } else {
                this.topicCardArr = this.popCardArr;
            }
        }
    }

    showMoreTopics() {
        this.topicsCount = this.topicsCount + 8;
        let count = 0;
        let temp = [];
        this.showMoreCards = true;
        if (this.alltopics && this.alltopics.length) {
            this.alltopics.forEach(element => {
                if (count < this.topicsCount) {
                    temp.push({
                        "name": element.topicRec.Name,
                        "imgSrc": element.imgSrc,
                        "id": element.topicRec.Id
                    })
                    count++;
                }
            });
            this.alltopicCardArr = temp;
            if (this.alltopics.length === this.alltopicCardArr.length) {
                this.showMoreCards = false;
            }
        }
        this.topicCardArr = this.alltopicCardArr;
    }
    showLessTopics() {
        this.topicsCount = 0;
        this.showMoreTopics();
    }
    showLessTopicsKey(event) {
        if (event.keyCode == 13) {
            this.showLessTopics();
        }
    }
    showMoreTopicsKey(event) {
        if (event.keyCode == 13) {
            this.showMoreTopics();
        }
    }
    NavigateToAllTopics() {
        const searchEvent = new CustomEvent("gotoalltopics", {
            detail: true
        });
        this.dispatchEvent(searchEvent);
    }
    NavigateToRC() {
        window.location = "ResourceCenter";
    }
    navigateTopicPageKey(event) {
        if (event.keyCode == 13) {
            this.navigateTopicPage(event);
        }
    }
    navigateTopicPage(event) {
        let topicId = event.currentTarget.dataset.id;
        let topicName = event.currentTarget.dataset.name;
		let targetText = event ? event.target.textContent : "Topic card";
        this.insertAnalyticsEvent("Popular/Recommened Topics", "", targetText);
        const topicEvent = new CustomEvent("gototopic", {
            detail: {
                id: topicId,
                name: topicName
            }
        });
        this.dispatchEvent(topicEvent);
        if(this.dashboard){
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: "rclanding__c"
            },
            state: {
                language: "en_US",
                search: topicName,
                id:topicId
            }
        });
    }

        //window.location = "rclanding?search=" + topicName + "&id=" + topicId;
        // https://bosdev003-service-ct.cs32.force.com/business/s/rclanding?search=Planning%20my%20new%20business&id=0TOr0000000GmlJGAS 
    }
	 insertAnalyticsEvent(sectiontitle, targetVal, targetText) {    
        insertRecord(null, "rclanding", sectiontitle, "", sectiontitle, 
          "Topic tile click", targetVal, targetText, this.startTime, new Date().getTime()
        );
      }
}
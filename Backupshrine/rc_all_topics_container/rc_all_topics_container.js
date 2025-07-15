import {
    LightningElement,
    track
} from 'lwc';

export default class Rc_all_topics_container extends LightningElement {
    @track alltopicspage = true;

    navigateTopicPage(event) {
        let topicId = event.detail.id;
        let topicName = event.detail.name;
        const topicEvent = new CustomEvent("gototopic", {
            detail: {
                id: topicId,
                name: topicName
            }
        });
        this.dispatchEvent(topicEvent);
    }
}
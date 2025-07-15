import { LightningElement } from 'lwc';

export default class TopicSearchBar extends LightningElement {
    handleSearchChange(event) {
        let searchKey = event.target.value;
        
        if(searchKey && searchKey.length >= 3) {
            this.dispatchEvent(new CustomEvent('searchchange', { detail : searchKey }));
        }
    }
}